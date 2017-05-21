//
//  Artists.swift
//  nmf
//
//  Created by Daniel Pagan on 3/30/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation
import Kingfisher


class Artists : NSObject, NSCoding, Resource {
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
    
    var downloadURL: URL {
        get {
            guard let pictureURLString = picture, let picturURL = Foundation.URL(string: pictureURLString) else {
                return Foundation.URL(string: "https://api.backendless.com/49259415-337F-9D60-FFEE-023C6FD21C00/v1/files/artists/2017/empty.jpg")!
            }
            
            return picturURL
        }
    }
    
    var cacheKey: String {
        return downloadURL.absoluteString
    }
}
