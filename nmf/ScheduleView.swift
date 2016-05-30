//
//  ScheduleView.swift
//  nmf
//
//  Created by Ben Lachman on 5/30/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ScheduleView: UIView {
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stage: UILabel!
    @IBOutlet weak var starButton: UIButton!

    weak var scheduleTime: Schedule?
}
