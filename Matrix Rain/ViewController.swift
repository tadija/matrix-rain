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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        let lanesCount = Int(view.bounds.width / CGFloat(20.0))
        lanes = Lane.splitView(view, intoLanesOfType: .Vertical, count: lanesCount)
        
//        for lane in lanes! as [Lane] {
//            let backgroundView = UIView(frame: lane.frame)
//            backgroundView.backgroundColor = UIColor.grayColor()
//            backgroundView.alpha = CGFloat( CGFloat(arc4random_uniform(UInt32(lanes!.count))) / CGFloat(lane.wideness) )
//            view.addSubview(backgroundView)
//        }
        
        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(matrixRainBehavior)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        makeItRain()
    }
    
    func makeItRain() {
        matrixRainBehavior.addGradientLayer()
        for lane in lanes! {
            let randomDelay = Double.random(min: 0.0, max: 5.0)
            NSTimer.scheduledTimerWithTimeInterval(randomDelay, target: self, selector: "addRainDropToLane:", userInfo: lane, repeats: false)
        }
    }
    
    func addRainDropToLane(sender: NSTimer) {
        if let lane = sender.userInfo as? Lane {
            let rainDrop = MatrixRainDrop()
            rainDrop.parentLane = lane
            lane.setInitialPositionForView(rainDrop)
            view.addSubview(rainDrop)
            matrixRainBehavior.addItem(rainDrop)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}