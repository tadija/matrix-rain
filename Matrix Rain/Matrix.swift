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
    
    var containerView: UIView
    var type: LaneType
    var position: Double
    var wideness: Double
    
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
    
    func setInitialPositionForView(contentView: UIView) {
        let padding = self.frame.size.width - contentView.frame.width
        contentView.frame = CGRect(x: self.frame.origin.x + (padding / 2), y: -contentView.frame.size.height, width: contentView.frame.width, height: contentView.frame.height)
    }
    
}

class MatrixRainDrop: UILabel {
    
    var parentLane: Lane?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init(frame: CGRectZero)
        numberOfLines = 0
        
//        textAlignment = .Center
//        backgroundColor = UIColor.blackColor()
//        textColor = UIColor.redColor()
//        font = UIFont.boldSystemFontOfSize(20)
//        text = randomMatrixString()
//        sizeToFit()
        
        var at = NSMutableAttributedString(string: randomMatrixString())
        at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(20), range: NSMakeRange(0, countElements(at.string) - 1))
        at.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, countElements(at.string) - 1))
        at.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor(), range: NSMakeRange(0, countElements(at.string) - 2))
        at.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(countElements(at.string) - 2, 1))
        attributedText = at
        sizeToFit()
        
        layer.opaque = true
        layer.masksToBounds = false
        layer.shouldRasterize = true
    }
    
    func randomize(completion: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//            self.text = self.randomMatrixString()
            var at = NSMutableAttributedString(string: self.randomMatrixString())
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                at.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(20), range: NSMakeRange(0, countElements(at.string) - 1))
                at.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, countElements(at.string) - 1))
                at.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor(), range: NSMakeRange(0, countElements(at.string) - 2))
                at.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(countElements(at.string) - 2, 1))
                self.attributedText = at
                self.sizeToFit()
                
//                self.backgroundColor = UIColor.blackColor()
//                self.opaque = true
//                self.layer.masksToBounds = false
//                self.layer.shouldRasterize = true
                
                completion()
            })
        })
    }
    
    // half width katakana + latin numerics + new line \n\n\n\n\n\n\n
    lazy var chars = Array("ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789\n\n\n")
    
    func randomMatrixString() -> String {
        var randomString = String()
        var randomLength = Int.random(min: 8, max: 21)
        var charsCount = chars.count
        
        for i in 0...randomLength {
            var randomIndex = Int.random(min: 0, max: charsCount - 1)
            var char = chars[randomIndex]
            randomString += String(char) + "\n"
        }
        
        return randomString
    }

}

class MatrixRainBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    let gravity: UIGravityBehavior = UIGravityBehavior()
//    let animationOptions: UIDynamicItemBehavior = UIDynamicItemBehavior()
    let collision: UICollisionBehavior = UICollisionBehavior()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
//        gravity.gravityDirection = CGVectorMake(0.0, 0.1)
        gravity.magnitude = 0.1
        
//        addChildBehavior(animationOptions)
//        animationOptions.allowsRotation = false
//        animationOptions.resistance = CGFloat(Double.random(min: 0, max: 3))
//        animationOptions.density = 0.5
//        animationOptions.friction = 0.5
//        animationOptions.elasticity = 0.5
        
        addChildBehavior(collision)
        collision.collisionDelegate = self
    }
    
    func addItem(item: UIDynamicItem) {
        if let rainDrop = item as? MatrixRainDrop {
            gravity.addItem(rainDrop)
//            animationOptions.addItem(rainDrop)
            collision.addItem(rainDrop)
            createCollisionBoundaryForRainDrop(rainDrop)
        }
    }
    
    func removeItem(item: UIDynamicItem) {
        gravity.removeItem(item)
//        animationOptions.removeItem(item)
        collision.removeItem(item)
        collision.removeBoundaryWithIdentifier(item.hash)
    }
    
    func createCollisionBoundaryForRainDrop(rainDrop: MatrixRainDrop) {
        if let matrixView = dynamicAnimator?.referenceView {
            if let lane = rainDrop.parentLane {
                let fromPoint = CGPoint(x: CGFloat(lane.position), y: matrixView.frame.size.height + rainDrop.frame.size.height + 100);
                let toPoint = CGPoint(x: CGFloat(lane.position + lane.wideness), y: matrixView.frame.size.height + rainDrop.frame.size.height + 100)
                collision.addBoundaryWithIdentifier(rainDrop.hash, fromPoint: fromPoint, toPoint: toPoint)
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if let rainDrop = item as? MatrixRainDrop {
            if let animator = dynamicAnimator? {
                rainDrop.randomize({ () -> Void in
                    rainDrop.parentLane?.setInitialPositionForView(rainDrop)
                    self.collision.removeBoundaryWithIdentifier(rainDrop.hash)
                    self.createCollisionBoundaryForRainDrop(rainDrop)
                    animator.updateItemUsingCurrentState(rainDrop)
                })
            }
        }
    }
}

class BackgroundLayer {
    
    class func darkGreyGradient() -> CAGradientLayer {
        let colorOne = UIColor(white: 0, alpha: 0.4)
        let colorMid = UIColor(white: 0, alpha: 0.1)
        let colorMid0 = UIColor(white: 0, alpha: 0.0)
        let colorMid2 = UIColor(white: 0, alpha: 0.1)
        let colorTwo = UIColor(white: 0, alpha: 0.4)
        
        let colors = NSArray(objects: colorOne.CGColor, colorMid.CGColor, colorMid0.CGColor, colorMid2.CGColor, colorTwo.CGColor)
        let locations = NSArray(objects: NSNumber(double: 0.1), NSNumber(double: 0.2), NSNumber(double: 0.5), NSNumber(double: 0.8), NSNumber(double: 0.9))
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        return gradientLayer
    }

}




