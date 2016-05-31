//
//  Schedule.swift
//  nmf
//
//  Created by Daniel Pagan on 4/6/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding {
    var objectId: String?
    
    var artist: String?
    var starttime: NSDate?
    var endtime: NSDate?
    var stage: String?
    
    var starred: Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObjectForKey("oid") as? String
        
        artist = aDecoder.decodeObjectForKey("artist") as? String
        starttime = aDecoder.decodeObjectForKey("start") as? NSDate
        stage = aDecoder.decodeObjectForKey("stage") as? String
        
        starred = aDecoder.decodeBoolForKey("starred")
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectId, forKey: "oid")

        aCoder.encodeObject(artist, forKey: "artist")
        aCoder.encodeObject(starttime, forKey: "start")
        aCoder.encodeObject(stage, forKey: "stage")
        
        aCoder.encodeBool(starred, forKey: "starred")
    }
    
    // MARK: - Custom methods

    func update(otherItem: Schedule) {
        guard objectId == otherItem.objectId else {
            return
        }

        artist = otherItem.artist
        starttime = otherItem.starttime
        stage = otherItem.stage
        
        // we don't merge starred
    }
    
    //MARK: - date formatting
    
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
}
