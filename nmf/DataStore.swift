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
    var scheduleItems: BackendlessCollection?
    var artistsItems: [Artists]?
    
    
    class var sharedInstance: DataStore {
        return dataStoreSingleton
    }
    
    func updateScheduleItems(completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Schedule.ofClass())
        
        dataStore.find({ (scheduleItemsCollection) in
            self.scheduleItems = scheduleItemsCollection
            
            completion(nil)
        }) { (fault) in
            self.scheduleItems = nil
            print(fault)
            
            completion(fault)
        }
    }
    
    func updateArtistsItems(artistName: String, completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        
        dataStore.find({ (artistsItemsCollection) in
            self.artistsItems = artistsItemsCollection.data as? [Artists]
            
            completion(nil)
        }) { (fault) in
            self.artistsItems = nil
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
            self.artistsItems = nil
            print(fault)
            
            completion(nil, fault)
        }
    }
}
