//
//  UIColorExtension.swift
//  Travel Companion
//
//  Created by Dov Royal on 3/6/20.
//  Copyright © 2020 Dov Royal. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let universalGreen = UIColor().colourFromHex("#10B054")
    
    func colourFromHex(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") { // remove # at beginning of string
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 { // error
            return UIColor.black
        }
        
        var rgb: UInt32 = 0
        
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        // convert rgb to hex and move to a scale of 0 - 1
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                            blue: CGFloat(rgb & 0x0000FF) / 255.0,
                            alpha: 1.0)
    }
}
