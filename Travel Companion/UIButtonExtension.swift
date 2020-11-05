//
//  UIButtonExtension.swift
//  Bubble Pop
//
//  Created by Dov Royal on 12/5/20.
//  Copyright © 2020 Dov Royal. All rights reserved.
//  Class to store all the animations
//  11995305

import Foundation
import UIKit

extension UIButton {
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.9
        pulse.toValue = 1.1
        pulse.autoreverses = false
        pulse.repeatCount = 0.0
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
    
    func shrink() {
        let shrink = CASpringAnimation(keyPath: "transform.scale")
        shrink.duration = 0.6
        shrink.fromValue = 1.0
        shrink.toValue = 0.0
        shrink.autoreverses = false
        shrink.repeatCount = 0
        shrink.initialVelocity = 0.5
        shrink.damping = 1.0
        
        layer.add(shrink, forKey: nil)
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        
        layer.add(flash, forKey: nil)
    }
}
