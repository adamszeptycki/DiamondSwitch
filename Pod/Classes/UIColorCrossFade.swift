//
//  UIColorCrossFade.swift
//  test
//
//  Created by Adam Szeptycki on 14/02/15.
//  Copyright (c) 2015 Adam Szeptycki. All rights reserved.
//

import UIKit

extension UIColor{
    
    class func colorForFade(firstColor : UIColor, secondColor : UIColor,var ratio :CGFloat, compareColorSpaces : Bool = false) -> UIColor?{
        ratio = min(max(0,ratio), 1)
        
        
        let firstColorComponents = CGColorGetComponents(firstColor.CGColor)
        let secondColorComponents = CGColorGetComponents(secondColor.CGColor)
        
        var interpolatedComponents : [CGFloat] = []
        for i in 0...CGColorGetNumberOfComponents(firstColor.CGColor){
            let interpolatedComponent = firstColorComponents[Int(i)] * (1-ratio) + secondColorComponents[Int(i)]*ratio
            interpolatedComponents.append(interpolatedComponent)
        }
        
        let interpolatedCGColor = CGColorCreate(CGColorGetColorSpace(firstColor.CGColor), interpolatedComponents)
        if let interpolatedCGColor = interpolatedCGColor{
            let interpolatedColor = UIColor(CGColor: interpolatedCGColor)
            return interpolatedColor
        }
        return nil
    }
    
}