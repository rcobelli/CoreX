//
//  WorkoutCell.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit

class WorkoutCell: UITableViewCell {

	@IBOutlet weak var exerciseWidth: NSLayoutConstraint!
	@IBOutlet weak var restWidth: NSLayoutConstraint!
	@IBOutlet weak var exerciseLabelWidth: NSLayoutConstraint!
	@IBOutlet weak var restLabelWidth: NSLayoutConstraint!
	@IBOutlet weak var secWidth1: NSLayoutConstraint!
	@IBOutlet weak var secWidth2: NSLayoutConstraint!
	
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var workoutList: UITextView!
	@IBOutlet weak var exerciseDuration: UITextField!
	@IBOutlet weak var restDuration: UITextField!
	@IBOutlet weak var itemCount: UILabel!
	@IBOutlet weak var itemLabel: UILabel!
	
	@IBOutlet weak var button: UIButton! {
		didSet {
			button.layer.cornerRadius = 8
			button.titleLabel?.adjustsFontSizeToFitWidth = true
		}
	}
	
	internal var completion : () -> Void = {}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.clipsToBounds = true
		
		#if os(iOS)
			exerciseWidth.constant = 70
			restWidth.constant = 70
			exerciseLabelWidth.constant = 0
			restLabelWidth.constant = 0
			secWidth1.constant = 0
			secWidth2.constant = 0
		#endif
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	@IBAction func start(_ sender: AnyObject) {
		completion()
	}
	
	@IBAction func editingBegan(_ sender: AnyObject) {
		exerciseWidth.constant = 100
		restWidth.constant = 100
		exerciseLabelWidth.constant = 80
		restLabelWidth.constant = 80
		secWidth1.constant = 38
		secWidth2.constant = 38
		UIView.animate(withDuration: 0.2, animations: {
			self.layoutIfNeeded()
		}) 
	}
	
	@IBAction func editingEnded(_ sender: AnyObject) {
		exerciseWidth.constant = 70
		restWidth.constant = 70
		exerciseLabelWidth.constant = 0
		restLabelWidth.constant = 0
		secWidth1.constant = 0
		secWidth2.constant = 0
		UIView.animate(withDuration: 0.2, animations: {
			self.layoutIfNeeded()
		}) 
	}
	
}
