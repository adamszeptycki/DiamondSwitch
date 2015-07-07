//
//  DiamondSwitch.swift
//  test
//
//  Created by Adam Szeptycki on 14/02/15.
//  Copyright (c) 2015 Adam Szeptycki. All rights reserved.
//

import UIKit


enum ToggleState{
    case On
    case Off
}

prefix func ! (inout toggleState : ToggleState) -> ToggleState{
    switch toggleState{
    case .On:
        return .Off
    case .Off:
        return .On
    }
}

@IBDesignable class DiamondSwitch: UIControl {

    
    var thumbOryginalPoint : CGPoint?
    var thumb : UIImageView!
    
    @IBInspectable var toggleState : ToggleState = .Off
    @IBInspectable var thumbnailImage : UIImage?
    @IBInspectable var backgroundImage : UIImage?
    @IBInspectable var onImage : UIImage?
    @IBInspectable var offImage : UIImage?
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup(){
        if let backgroundImage = backgroundImage{
            let backgroundImage = UIImageView(image: backgroundImage)
            backgroundImage.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
            self.addSubview(backgroundImage)
            self.sendSubviewToBack(backgroundImage)
        }
        if let offImage = offImage{
            let offImageView = UIImageView(image: offImage)
            
            offImageView.frame = CGRectMake(self.frame.width - 25 - 44, 0, 44, 44)
            offImageView.center = CGPointMake(offImageView.center.x, self.frame.height / 2)
            self.addSubview(offImageView)
        }
        if let onImage = onImage{
            let onImageView = UIImageView(image: onImage)
            onImageView.frame =  CGRectMake(25,0,44,44)
            onImageView.center = CGPointMake(onImageView.center.x, self.frame.height / 2)
            self.addSubview(onImageView)
        }
        if let thumbnailImage = thumbnailImage{
            thumb = UIImageView(image: thumbnailImage)
            thumb.userInteractionEnabled = true
            thumb.frame = CGRectMake(-1.0 * getMargin(), -1.0 * getMargin(), 1.42 * self.frame.height , 1.42 * self.frame.height)

            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
            thumb.addGestureRecognizer(panGestureRecognizer)
            self.addSubview(thumb)

            self.bringSubviewToFront(thumb)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.addGestureRecognizer(tapGestureRecognizer)

    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer){
        thumbOryginalPoint = self.thumb.center
        toggle()
    }
    
    var superViewOryginalColor : UIColor!
    
    func handlePan(recognizer:UIPanGestureRecognizer){

        let xDelta = recognizer.translationInView(self).x
        switch recognizer.state{
        case .Began:
            superViewOryginalColor = self.superview!.backgroundColor!
            thumbOryginalPoint = self.thumb.center
        case .Changed:
            let newX = getNewX(xDelta)
            let percentage = getSwipePercentage(newX)

            self.thumb.center = CGPointMake(newX, thumbOryginalPoint!.y)
            let transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI)/2 * percentage)
            
            let targetColor = UIColor(red: 27.0/256.0, green: 161.0/256.0, blue: 134.0/256.0, alpha: 1.0)
            let startColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            let crossFadeColor = UIColor.colorForFade(startColor,
                                                    secondColor: targetColor,
                                                          ratio: percentage,
                                             compareColorSpaces: false)
            
            
            self.superview?.backgroundColor = crossFadeColor
            self.thumb.transform = transform
        case .Ended:
            let newX = getNewX(xDelta)
            let percentage = getSwipePercentage(newX)
            if(percentage < 0.5){
                turn(.Off)
            }else{
                turn(.On)
            }
        case .Cancelled:()
        case .Possible:()
        case .Failed:()
        }
    }
    
    func toggle(){
        let newState : ToggleState = !toggleState
        turn(newState)
    }
    
    func turn(toState : ToggleState){
        var finalX : CGFloat!
        var percentage : CGFloat!
        switch toState{
        case .On:
            finalX = getMaxX()
            percentage = 1.0
        case .Off:
            finalX = getMinX()
            percentage = 0.0
        }
        toggleState = !toggleState
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.thumb.center = CGPointMake(finalX, self.thumbOryginalPoint!.y)
            let transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI)/2 * percentage)
            if percentage == 1.0{
                self.superview?.backgroundColor = UIColor(red: 27.0/256.0, green: 161.0/256.0, blue: 134.0/256.0, alpha: 1.0)
            }else{
                self.superview?.backgroundColor = UIColor.whiteColor()
            }
            self.thumb.transform = transform
        })
    }
    
    
    

    func getSwipePercentage(xTranslation : CGFloat) -> CGFloat{
        return ((xTranslation - getMinX() ) * 100 / (getMaxX() + (getMargin()) - self.thumb.frame.width/2)) / 100.0
    }
    
    func getMargin() -> CGFloat{
        return 0.21 * self.frame.height
    }
    

    func getNewX(xTranslation : CGFloat) -> CGFloat{
        
        let newX = thumbOryginalPoint!.x + xTranslation
        
        if(newX > getMaxX()){
            return getMaxX()
        }else if (newX < getMinX()){
            return getMinX()
        }else{
            return newX
        }
    }
    
    func getMinX() -> CGFloat{
        return -1.42 * getMargin() + self.thumb.frame.width / 2
    }
    
    func getMaxX() -> CGFloat{
        return (self.frame.width + 1.42 * getMargin()) - self.thumb.frame.width/2
    }

    func getXRange() -> CGFloat{
        return getMaxX() - getMinX()
    }
    
}
