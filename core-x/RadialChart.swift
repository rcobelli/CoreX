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
		}
	}
//	var arcWidth:CGFloat = 20.0
	
	@IBInspectable var arcWidth : CGFloat = 20.0
	
	var arcColor = UIColor(red: 0.000, green: 0.624, blue: 0.706, alpha: 1.00)
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
		CGContextSetLineWidth(context, arcWidth)
		CGContextSetLineCap(context, .Round)
		CGContextSetStrokeColorWithColor(context, arcBackgroundColor.CGColor)
		CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, 0, fullCircle, 0)
		CGContextStrokePath(context)
		CGContextSetStrokeColorWithColor(context, arcColor.CGColor)

		CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, start, end, 0)
		CGContextStrokePath(context)

    }

}
