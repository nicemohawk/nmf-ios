//
//  DataStore.swift
//  nmf
//
//  Created by Daniel Pagan on 4/15/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import Foundation

private let dataStoreSingleton = DataStore()

extension Fault : ErrorType {
    
}

class DataStore: NSObject {
    var scheduleItems = [Schedule]()
    var artistItems = [Artists]()
    
    class var sharedInstance: DataStore {
        return dataStoreSingleton
    }
    
    func updateScheduleItems(completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Schedule.ofClass())
        
        dataStore.find({ (scheduleItemsCollection) in
            if let items = scheduleItemsCollection.data as? [Schedule] {
                self.scheduleItems = items.sort { $0.starttime?.compare($1.starttime ?? NSDate.distantFuture()) != .OrderedDescending }
            } else {
                self.scheduleItems = []
            }
            
            completion(nil)
        }) { (fault) in
            self.scheduleItems = []
            print(fault)
            
            completion(fault)
        }
    }
    
    func updateArtistItems(completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        
        dataStore.find({ (artistsItemsCollection) in
            if let items = artistsItemsCollection.data as? [Artists] {
                self.artistItems = items
            } else {
                self.artistItems = []
            }
            
            completion(nil)
        }) { (fault) in
            self.artistItems = []
            print(fault)
            
            completion(fault)
        }
    }
    
    func getArtistByName(artistName: String, completion: (Artists?, ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        
        let artistsQuery = BackendlessDataQuery()
        artistsQuery.whereClause = "ArtistName = '\(artistName)'"
        
        dataStore.find(artistsQuery, response: { (artistsItemsCollection) in
            let foundArtist = artistsItemsCollection.data.first as? Artists
            
            completion(foundArtist, nil)
        }) { (fault) in
            self.artistItems = []
            print(fault)
            
            completion(nil, fault)
        }
    }
}
