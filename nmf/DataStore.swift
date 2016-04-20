//
//  DataStore.swift
//  nmf
//
//  Created by Daniel Pagan on 4/15/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import Foundation

private let dataStoreSingleton = DataStore()

class DataStore: NSObject {
    var scheduleItems: BackendlessCollection?
    var artistsItems: Artists?
    
    
    class var sharedInstance: DataStore {
        return dataStoreSingleton
    }
    
    override init() {
    
        super.init()
        self.updateScheduleItems()
        
        }
    func updateScheduleItems() -> Void {
        
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Schedule.ofClass())
        dataStore.find({ (scheduleItemsCollection) in
            self.scheduleItems = scheduleItemsCollection
        }) { (fault) in
            self.scheduleItems = nil
            print(fault)
        }
        
    }
    func updateArtistsItems(artistName: String) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        let artistsQuery = BackendlessDataQuery()
        artistsQuery.whereClause = "ArtistName = '\(artistName)'"
        dataStore.find(artistsQuery, response: { (artistsItemsCollection) in
            self.artistsItems = artistsItemsCollection.data[0] as? Artists
            }) { (fault) in
                self.artistsItems = nil
                print(fault)
        }
    }

}
