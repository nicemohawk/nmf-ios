//
//  Schedule.swift
//  nmf
//
//  Created by Daniel Pagan on 4/6/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation

@objcMembers class ScheduleItem: NSObject, NSCoding {
    var objectId: String?

    var artistName: String?
    var startTime: Date?
    var stage: String?
    var day: String?

    var starred: Bool = false

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {

        objectId = aDecoder.decodeObject(forKey: "oid") as? String
        
        artistName = aDecoder.decodeObject(forKey: "artist") as? String
        startTime = aDecoder.decodeObject(forKey: "start") as? Date
        day = aDecoder.decodeObject(forKey: "day") as? String
        stage = aDecoder.decodeObject(forKey: "stage") as? String
        
        starred = aDecoder.decodeBool(forKey: "starred")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(objectId, forKey: "oid")

        aCoder.encode(artistName, forKey: "artist")
        aCoder.encode(startTime, forKey: "start")
        aCoder.encode(day, forKey: "day")
        aCoder.encode(stage, forKey: "stage")
        
        aCoder.encode(starred, forKey: "starred")
    }
    
    // MARK: - Custom methods

    func update(_ otherItem: ScheduleItem) {
        guard objectId == otherItem.objectId else {
            return
        }

        artistName = otherItem.artistName
        startTime = otherItem.startTime
        day = otherItem.day
        stage = otherItem.stage
        
        // we don't merge starred
    }
    
    //MARK: - date formatting
    
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE h:mma"
        
        return formatter
    }()
    
    func timeString() -> String {
        if let startDate = startTime {
            let components = Calendar.current.dateComponents([.hour,.minute], from: startDate)
            
            if let hour = components.hour, let minute = components.minute {
                switch (hour, minute) {
                case (23, 59):
                    return "12:00AM"
                default:
                    return ScheduleItem.hourFormatter.string(from: startDate)
                }
            }
            
            return ScheduleItem.hourFormatter.string(from: startDate)
        }
        
        return ""
    }
    
    func dateString() -> String {
        if let startDate = startTime {
            return ScheduleItem.dateFormatter.string(from: startDate)
        }
        
        return ""
    }
    
}
