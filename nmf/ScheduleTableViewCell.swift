//
//  ScheduleTableViewCell.swift
//  nmf
//
//  Created by Daniel Pagan on 4/8/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stage: UILabel!
    
    @IBOutlet weak var starButton: UIButton!

    @IBOutlet var startTimeBottomConstraint: NSLayoutConstraint!
    @IBOutlet var startTimeVerticalCenterConstraint: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()

        starButton.isHidden = false
        stage.isHidden = false

        startTimeBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        startTimeVerticalCenterConstraint.priority = UILayoutPriority(rawValue: 1)
    }

    func centerStartTime() {
        startTimeBottomConstraint.priority = UILayoutPriority(rawValue: 1)
        startTimeVerticalCenterConstraint.priority = UILayoutPriority(rawValue: 999)

        startTime.superview?.setNeedsUpdateConstraints()
    }
}

