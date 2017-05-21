//
//  File.swift
//  nmf
//
//  Created by Ben Lachman on 5/9/17.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation

class Secrets {
    enum SecretsError: Error {
        case NotFound
    }
    
    class func secrets() -> Dictionary<String, Any?> {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                return dict
            }
        }
        
        print("No Secrets file found")
        return Dictionary<String, Any?>()
    }
}
