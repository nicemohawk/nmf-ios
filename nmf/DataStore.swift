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
    static let archiveURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    lazy var scheduleItems: [Schedule] = {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.URLByAppendingPathComponent("schedule").path!) as? [Schedule] ?? [Schedule]()
    }()
    
    lazy var artistItems: [Artists] = {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.URLByAppendingPathComponent("artists").path!) as? [Artists] ?? [Artists]()
    }()
    
    class var sharedInstance: DataStore {
        return dataStoreSingleton
    }
    
    
    func saveData() {
        print( "saved schedule: \(NSKeyedArchiver.archiveRootObject(scheduleItems, toFile: DataStore.archiveURL.URLByAppendingPathComponent("schedule").path!))")
        
        print("saved artists: \(NSKeyedArchiver.archiveRootObject(artistItems, toFile: DataStore.archiveURL.URLByAppendingPathComponent("artists").path!))")
    }
    
    func updateScheduleItems(completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Schedule.ofClass())
        
        dataStore.find({ (scheduleItemsCollection) in
            if let items = scheduleItemsCollection.data as? [Schedule] {
                let sortedItems = items.sort { $0.starttime?.compare($1.starttime ?? NSDate.distantFuture()) != .OrderedDescending }
                
                self.mergeScheduleItems(sortedItems)
            }
            
            completion(nil)
        }, error: { (fault) in
            print(fault)
            
            completion(fault)
        })
    }
    
    func updateArtistItems(completion: (ErrorType?) -> Void) -> Void {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        
        dataStore.find({ (artistsItemsCollection) in
            if let artists = artistsItemsCollection.data as? [Artists] {
                self.mergeArtists(artists)
            }
            
            completion(nil)
        }, error: { (fault) in
            print(fault)
            
            completion(fault)
        })
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
    
    func mergeScheduleItems(newItems: [Schedule]) {
        
        for newItem in newItems {
            var foundItem = false
            
            for item in scheduleItems where newItem.objectId == item.objectId {
                item.update(newItem)
                foundItem = true
                
                break
            }
            
            if foundItem == false {
                scheduleItems.append(newItem)
            }
        }
        
    }
    
    func mergeArtists(newArtists: [Artists]) {
        for newArtist in newArtists  {
            var foundItem = false

            for artist in artistItems where newArtist.objectId == artist.objectId {
                artist.update(newArtist)
                foundItem = true
                
                break
            }
            
            if foundItem == false {
                artistItems.append(newArtist)
            }
        }
    }
}
