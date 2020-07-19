//
//  ViewController.swift
//  Matrix Rain
//
//  Created by Marko Tadic on 9/18/14.
//  Copyright (c) 2014 ae. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    var lanes: [Lane]?
    var animator: UIDynamicAnimator!
    lazy var matrixRainBehavior = MatrixRainBehavior()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        let lanesCount = Int(view.bounds.width / CGFloat(20.0))
        lanes = Lane.splitView(view: view, intoLanesOfType: .Vertical, count: lanesCount)
        
//        for lane in lanes! as [Lane] {
//            let backgroundView = UIView(frame: lane.frame)
//            backgroundView.backgroundColor = UIColor.gray
//            backgroundView.alpha = CGFloat( CGFloat(arc4random_uniform(UInt32(lanes!.count))) / CGFloat(lane.wideness) )
//            view.addSubview(backgroundView)
//        }
        
        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(matrixRainBehavior)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeItRain()
    }
    
    func makeItRain() {
        matrixRainBehavior.addGradientLayer()
        for lane in lanes! {
            let randomDelay = Double.random(min: 0.0, max: 5.0)
            Timer.scheduledTimer(timeInterval: randomDelay,
                                                   target: self, selector: #selector(addRainDropToLane(_:)),
                                                   userInfo: lane, repeats: false)
        }
    }
    
    @objc func addRainDropToLane(_ sender: Timer) {
        if let lane = sender.userInfo as? Lane {
            let rainDrop = MatrixRainDrop()
            rainDrop.parentLane = lane
            lane.setInitialPositionForView(contentView: rainDrop)
            view.addSubview(rainDrop)
            matrixRainBehavior.addItem(item: rainDrop)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
