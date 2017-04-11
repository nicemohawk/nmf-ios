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
        objectId = aDecoder.decodeObject(forKey: "oid") as? String
        
        artistName = aDecoder.decodeObject(forKey: "artist") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
        picture = aDecoder.decodeObject(forKey: "picture") as? String
        
        URL = aDecoder.decodeObject(forKey: "url") as? String
        YouTube = aDecoder.decodeObject(forKey: "youtube") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(objectId, forKey: "oid")

        aCoder.encode(artistName, forKey: "name")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(picture, forKey: "picture")
        
        aCoder.encode(URL, forKey: "url")
        aCoder.encode(YouTube, forKey: "youtube")
    }
    
    func update(_ otherItem: Artists) {
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
