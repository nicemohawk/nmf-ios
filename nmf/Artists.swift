//
//  Artists.swift
//  nmf
//
//  Created by Daniel Pagan on 3/30/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import Foundation


class Artists : NSObject, NSCoding {
    var objectId: String?
    
    var artistName: String?
    var bio: String?
    var picture: String?
    
    var URL: String?
    var YouTube: String?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObjectForKey("oid") as? String
        
        artistName = aDecoder.decodeObjectForKey("artist") as? String
        bio = aDecoder.decodeObjectForKey("bio") as? String
        picture = aDecoder.decodeObjectForKey("picture") as? String
        
        URL = aDecoder.decodeObjectForKey("url") as? String
        YouTube = aDecoder.decodeObjectForKey("youtube") as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectId, forKey: "oid")

        aCoder.encodeObject(artistName, forKey: "name")
        aCoder.encodeObject(bio, forKey: "bio")
        aCoder.encodeObject(picture, forKey: "picture")
        
        aCoder.encodeObject(URL, forKey: "url")
        aCoder.encodeObject(YouTube, forKey: "youtube")
    }
    
    func update(otherItem: Artists) {
        guard objectId == otherItem.objectId else {
            return
        }
        
        artistName = otherItem.artistName
        bio = otherItem.bio
        picture = otherItem.picture

        URL = otherItem.URL
        YouTube = otherItem.YouTube
    }
}