//
//  Schedule.swift
//  nmf
//
//  Created by Daniel Pagan on 4/6/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import Foundation

class Schedule: NSObject {
    var artist: String?
    var starttime: NSDate?
    var endtime: NSDate?
    var stage: String?
    
    static let hourFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mma"
        
        return formatter
    }()
    
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE h:mma"
        
        return formatter
    }()

    
    func timeString() -> String {
        if let startDate = starttime {
            return Schedule.hourFormatter.stringFromDate(startDate)
        }
        
        return ""
    }
    
    func dateString() -> String {
        if let startDate = starttime {
            return Schedule.dateFormatter.stringFromDate(startDate)
        }
        
        return ""
    }

//    class func dateFormatter() -> NSDateFormatter {
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "h:mma"
//        
//        return formatter
//    }
    
}