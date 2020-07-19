//
//  Matrix.swift
//  Matrix Rain
//
//  Created by Marko Tadić on 1.10.14..
//  Copyright (c) 2014. ae. All rights reserved.
//

import UIKit
import QuartzCore

extension Int {
    static func random(min: Int = 0, max: Int = Int.max) -> Int {
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

extension Double {
    static func random(min: Double = 0.0, max: Double = 1.0) -> Double {
        let r = Double(arc4random()) / Double(UInt32.max)
        return (r * (max - min)) + min
    }
}

class Lane {
    
    enum LaneType {
        case Horizontal, Vertical
    }
    
    let containerView: UIView
    let type: LaneType
    let position: Double
    let wideness: Double
    
    var frame: CGRect {
        switch type {
        case .Horizontal:
            return CGRect(x: 0.0, y: CGFloat(position), width: containerView.bounds.width, height: CGFloat(wideness))
        case .Vertical:
            return CGRect(x: CGFloat(position), y: 0.0, width: CGFloat(wideness), height: containerView.bounds.height)
        }
    }
    
    init(containerView: UIView, type: LaneType, position: Double, wideness: Double) {
        self.containerView = containerView
        self.type = type
        self.position = position
        self.wideness = wideness
    }
    
    class func splitView(view: UIView, intoLanesOfType type: LaneType, count: Int) -> [Lane] {
        var wideness: Double {
            switch type {
            case .Horizontal:
                return Double(view.bounds.height / CGFloat(count))
            case .Vertical:
                return Double(view.bounds.width / CGFloat(count))
                }
        }
        
        var lanes = [Lane]()
        for i in 0..<count {
            let lane = Lane(containerView: view, type: type, position: Double(i) * wideness, wideness: wideness)
            lanes.append(lane)
        }
        return lanes
    }
    
    // depends on LaneType?
    func setInitialPositionForView(contentView: UIView) {
        let padding = self.frame.size.width - contentView.frame.width
        contentView.frame = CGRect(x: self.frame.origin.x + (padding / 2), y: -contentView.frame.size.height, width: contentView.frame.width, height: contentView.frame.height)
    }
    
}

class MatrixRainDrop: UILabel {
    
    var parentLane: Lane?
    
    // half width katakana characters + latin numerics + new line characters \n
    lazy var chars = Array("ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789")
    lazy var newLineChars = Array("\n\n\n\n\n")
    
    var length: Int {
        return attributedText!.length
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: .zero)
        numberOfLines = 0
        layer.isOpaque = true
        layer.masksToBounds = false
        layer.shouldRasterize = true
        attributedText = NSMutableAttributedString(string: randomMatrixString())
        updateAttributes()
        let randomDelay = Double.random(min: 0.2, max: 0.5)
        Timer.scheduledTimer(timeInterval: randomDelay, target: self, selector: #selector(MatrixRainDrop.randomizeLastCharacter), userInfo: nil, repeats: true)
    }
    
    func randomMatrixString() -> String {
        var randomString = String()
        let randomLength = Int.random(min: 8, max: 21)
        let charsCount = chars.count + newLineChars.count
        
        for _ in 0...randomLength {
            let randomIndex = Int.random(min: 0, max: charsCount - 1)
            let matrixChars = chars + newLineChars
            let char = matrixChars[randomIndex]
            randomString += String(char) + "\n"
        }
        
        return randomString
    }
    
    @objc func randomizeLastCharacter() {
        let randomIndex = Int.random(min: 0, max: self.chars.count - 1)
        let randomChar = self.chars[randomIndex]
        let matrixString = NSMutableAttributedString(attributedString: self.attributedText!)
        matrixString.replaceCharacters(in: NSMakeRange(matrixString.string.count - 2, 1), with: String(randomChar))
        self.attributedText = matrixString
    }
    
    func updateAttributes() {
        let matrixString = NSMutableAttributedString(attributedString: attributedText!)
        matrixString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSMakeRange(0, length - 1))
        matrixString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.black, range: NSMakeRange(0, length - 1))
        matrixString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSMakeRange(0, length - 2))
        matrixString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(length - 2, 1))
        attributedText = matrixString
        sizeToFit()
    }
    
    func randomize(completion: @escaping () -> Void) {
        self.attributedText = NSMutableAttributedString(string: self.randomMatrixString())
        self.updateAttributes()
        completion()
    }

}

class MatrixRainBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    let gravity: UIGravityBehavior = UIGravityBehavior()
    let animationOptions: UIDynamicItemBehavior = UIDynamicItemBehavior()
    let collision: UICollisionBehavior = UICollisionBehavior()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(animationOptions)
        addChildBehavior(collision)
        setupBehaviors()
    }
    
    func setupBehaviors() {
//        gravity.gravityDirection = CGVectorMake(0.0, 0.1)
        gravity.magnitude = 0.1
        
        animationOptions.allowsRotation = false
//        animationOptions.resistance = CGFloat(Double.random(min: 0, max: 1))
//        animationOptions.density = 0.5
//        animationOptions.friction = 0.5
//        animationOptions.elasticity = 0.5
        
        collision.collisionDelegate = self
    }
    
    func addItem(item: UIDynamicItem) {
        if let rainDrop = item as? MatrixRainDrop {
            gravity.addItem(rainDrop)
            animationOptions.addItem(rainDrop)
            collision.addItem(rainDrop)
            createCollisionBoundaryForRainDrop(rainDrop: rainDrop)
        }
    }
    
    func removeItem(item: UIDynamicItem) {
        if let rainDrop = item as? MatrixRainDrop {
            gravity.removeItem(rainDrop)
            animationOptions.removeItem(rainDrop)
            collision.removeItem(rainDrop)
            collision.removeBoundary(withIdentifier: rainDrop.hash as NSCopying)
        }
    }
    
    func createCollisionBoundaryForRainDrop(rainDrop: MatrixRainDrop) {
        if let matrixView = dynamicAnimator?.referenceView {
            if let lane = rainDrop.parentLane {
                let fromPoint = CGPoint(x: CGFloat(lane.position), y: matrixView.frame.size.height + rainDrop.frame.size.height + 100);
                let toPoint = CGPoint(x: CGFloat(lane.position + lane.wideness), y: matrixView.frame.size.height + rainDrop.frame.size.height + 100)
                collision.addBoundary(withIdentifier: rainDrop.hash as NSCopying, from: fromPoint, to: toPoint)
            }
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let rainDrop = item as? MatrixRainDrop {
            if let animator = dynamicAnimator {
                rainDrop.randomize(completion: { () -> Void in
                    self.collision.removeBoundary(withIdentifier: rainDrop.hash as NSCopying)
                    self.createCollisionBoundaryForRainDrop(rainDrop: rainDrop)
                    rainDrop.parentLane?.setInitialPositionForView(contentView: rainDrop)
                    animator.updateItem(usingCurrentState: rainDrop)
                })
            }
        }
    }
    
    var gradientLayer: CAGradientLayer {
        let colorDark = UIColor(white: 0, alpha: 0.4).cgColor
        let colorLight = UIColor(white: 0, alpha: 0.1).cgColor
        let colorClear = UIColor(white: 0, alpha: 0.0).cgColor
            
        let colors = NSArray(objects: colorDark, colorLight, colorClear, colorLight, colorDark)
    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors as [AnyObject]
        gradientLayer.locations = [0.1, 0.2, 0.5, 0.8, 0.9]
        
        return gradientLayer
    }
    
    func addGradientLayer() {
        if let view = dynamicAnimator?.referenceView {
            let gradientView = UIView(frame: view.bounds)
            let gradient = gradientLayer
            gradient.frame = gradientView.bounds
            gradientView.layer.insertSublayer(gradient, at: 0)
            gradientView.layer.zPosition = CGFloat(MAXFLOAT)
            view.addSubview(gradientView)
        }
    }
}




