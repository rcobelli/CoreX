//
//  PreviousDay.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit

class PreviousDay: UIView {
	

	func configView(day: String, workedOut: Bool) {
	
		let label = UILabel(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
		label.textAlignment = NSTextAlignment.Center
		label.adjustsFontSizeToFitWidth = true
		label.text = day
		self.addSubview(label)
	
		if workedOut {
			self.backgroundColor = UIColor(red: 0.353, green: 0.773, blue: 0.314, alpha: 1.00)
		}
		else {
			self.backgroundColor = UIColor(red: 0.992, green: 0.373, blue: 0.306, alpha: 1.00)
		}
		
	}

}
