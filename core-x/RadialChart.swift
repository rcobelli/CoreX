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
			UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
				self.layer.displayIfNeeded()
				}, completion: nil)
		}
	}
	
	@IBInspectable var arcWidth : CGFloat = 5.0
	
	var arcColor = UIColor(red: 0.914, green: 0.443, blue: 0.129, alpha: 1.00)
	var arcBackgroundColor = UIColor.clear

    override func draw(_ rect: CGRect) {
		let fullCircle = 2.0 * CGFloat(M_PI)
		let start:CGFloat = -0.25 * fullCircle
		let end:CGFloat = endArc * fullCircle + start
		let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
		var radius:CGFloat = 0.0
		if rect.width > rect.height{
			radius = (rect.width - arcWidth) / 2.0
		}else{
			radius = (rect.height - arcWidth) / 2.0
		}
		
		let context = UIGraphicsGetCurrentContext()
		_ = CGColorSpaceCreateDeviceRGB()
		
		context?.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y))
		context?.setFillColor(arcColor.withAlphaComponent(1.0/3.0).cgColor)
		context?.addArc(center: centerPoint, radius: radius, startAngle: end, endAngle: start, clockwise: false)
		context?.addArc(tangent1End: centerPoint, tangent2End: centerPoint, radius: radius)
		context?.fillPath()
		
		context?.setLineWidth(arcWidth)
		context?.setStrokeColor(arcColor.withAlphaComponent(2.0/3.0).cgColor)
		context?.addArc(center: centerPoint, radius: radius, startAngle: end, endAngle: start, clockwise: false)
		context?.strokePath()

    }

}
