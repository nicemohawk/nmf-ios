//
//  Artists.swift
//  nmf
//
//  Created by Daniel Pagan on 3/30/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation
import Kingfisher


@objcMembers class Artist : NSObject, NSCoding, Resource {
    var objectId: String?
    
    var artistName: String?
    var bio: String?
    var picture: String?
    
    var url: String?
    var youTube: String?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObject(forKey: "oid") as? String
        
        artistName = aDecoder.decodeObject(forKey: "name") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
        picture = aDecoder.decodeObject(forKey: "picture") as? String
        
        url = aDecoder.decodeObject(forKey: "url") as? String
        youTube = aDecoder.decodeObject(forKey: "youtube") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(objectId, forKey: "oid")

        aCoder.encode(artistName, forKey: "name")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(picture, forKey: "picture")
        
        aCoder.encode(url, forKey: "url")
        aCoder.encode(youTube, forKey: "youtube")
    }
    
    func update(_ otherItem: Artist) {
        guard objectId == otherItem.objectId else {
            return
        }
        
        artistName = otherItem.artistName
        bio = otherItem.bio
        picture = otherItem.picture

        url = otherItem.url
        youTube = otherItem.youTube
    }
    
    var downloadURL: URL {
        get {
            guard let pictureURLString = picture, let picturURL = Foundation.URL(string: pictureURLString) else {
                return Foundation.URL(string: "https://api.backendless.com/19C02337-07D4-7BF5-FFD0-FCC0E93A1700/832D9A9C-39B2-3993-FF36-2217A956EA00/files/images-2018/empty.jpg")!
            }
            
            return picturURL
        }
    }
    
    var cacheKey: String {
        return downloadURL.absoluteString
    }
}
