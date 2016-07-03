//
//  RadialChart.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/13/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit

class RadialChart: UIView {
	

	var endArc:CGFloat = 0.0{   // in range of 0.0 to 1.0
		didSet{
			setNeedsDisplay()
			UIView.transitionWithView(self, duration: 0.1, options: .TransitionCrossDissolve, animations: {
				self.layer.displayIfNeeded()
				}, completion: nil)
		}
	}
	
	@IBInspectable var arcWidth : CGFloat = 5.0
	
	var arcColor = UIColor(red: 0.914, green: 0.443, blue: 0.129, alpha: 1.00)
	var arcBackgroundColor = UIColor.clearColor()

    override func drawRect(rect: CGRect) {
		let fullCircle = 2.0 * CGFloat(M_PI)
		let start:CGFloat = -0.25 * fullCircle
		let end:CGFloat = endArc * fullCircle + start
		let centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
		var radius:CGFloat = 0.0
		if CGRectGetWidth(rect) > CGRectGetHeight(rect){
			radius = (CGRectGetWidth(rect) - arcWidth) / 2.0
		}else{
			radius = (CGRectGetHeight(rect) - arcWidth) / 2.0
		}
		
		let context = UIGraphicsGetCurrentContext()
		_ = CGColorSpaceCreateDeviceRGB()
		
		CGContextMoveToPoint(context, centerPoint.x, centerPoint.y)
		CGContextSetFillColorWithColor(context, arcColor.colorWithAlphaComponent(1.0/3.0).CGColor)
		CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, end, start, 0)
		CGContextFillPath(context)
		
		CGContextSetLineWidth(context, arcWidth)
		CGContextSetStrokeColorWithColor(context, arcColor.colorWithAlphaComponent(2.0/3.0).CGColor)
		CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, end, start, 0)
		CGContextStrokePath(context)

    }

}
