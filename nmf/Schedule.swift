//
//  Schedule.swift
//  nmf
//
//  Created by Daniel Pagan on 4/6/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding {
    var objectId: String?
    
    var artist: String?
    var starttime: Date?
    var endtime: Date?
    var stage: String?
    
    var starred: Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObject(forKey: "oid") as? String
        
        artist = aDecoder.decodeObject(forKey: "artist") as? String
        starttime = aDecoder.decodeObject(forKey: "start") as? Date
        stage = aDecoder.decodeObject(forKey: "stage") as? String
        
        starred = aDecoder.decodeBool(forKey: "starred")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(objectId, forKey: "oid")

        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(starttime, forKey: "start")
        aCoder.encode(stage, forKey: "stage")
        
        aCoder.encode(starred, forKey: "starred")
    }
    
    // MARK: - Custom methods

    func update(_ otherItem: Schedule) {
        guard objectId == otherItem.objectId else {
            return
        }

        artist = otherItem.artist
        starttime = otherItem.starttime
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
        if let startDate = starttime {
            let components = Calendar.current.dateComponents([.hour,.minute], from: startDate)
            
            if let hour = components.hour, let minute = components.minute {
                switch (hour, minute) {
                case (11, 59):
                    return "12:00 AM"
                default:
                    return Schedule.hourFormatter.string(from: startDate)
                }
            }
        }
        
        return ""
    }
    
    func dateString() -> String {
        if let startDate = starttime {
            return Schedule.dateFormatter.string(from: startDate)
        }
        
        return ""
    }
}
