//
//  DataStore.swift
//  nmf
//
//  Created by Daniel Pagan on 4/15/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import Foundation
import SwiftSDK

private let dataStoreSingleton = DataStore()

//extension Fault : Error {
//
//}

class DataStore: NSObject {
    static let archiveURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    lazy var scheduleItems: [ScheduleItem] = {
        NSKeyedUnarchiver.setClass(ScheduleItem.self, forClassName: "NMF.Schedule")

        return NSKeyedUnarchiver.unarchiveObject(withFile: DataStore.archiveURL.appendingPathComponent("schedule").path) as? [ScheduleItem] ?? [ScheduleItem]()
    }()
    
    lazy var artistItems: [Artist] = {
        NSKeyedUnarchiver.setClass(Artist.self, forClassName: "NMF.Artists")

        return NSKeyedUnarchiver.unarchiveObject(withFile: DataStore.archiveURL.appendingPathComponent("artists").path) as? [Artist] ?? [Artist]()
    }()
    
    class var sharedInstance: DataStore {
        return dataStoreSingleton
    }

    func saveData() {
        print( "saved schedule: \(NSKeyedArchiver.archiveRootObject(scheduleItems, toFile: DataStore.archiveURL.appendingPathComponent("schedule").path))")
        
        print("saved artists: \(NSKeyedArchiver.archiveRootObject(artistItems, toFile: DataStore.archiveURL.appendingPathComponent("artists").path))")
    }
    
    func updateScheduleItems(_ completion: @escaping (Error?) -> Void) -> Void {
        let backendless = Backendless.shared

        func pageAllScheduleData(queryBuilder: DataQueryBuilder) {

            backendless.data.of(ScheduleItem.self).find(queryBuilder: queryBuilder, responseHandler: { (scheduleItemsCollection: [Any]?) in
                if scheduleItemsCollection?.count != 0 {
                    guard let items = scheduleItemsCollection as? [ScheduleItem] else {
                        print("Unable to convert scheduleItemsCollection (type: \(type(of:scheduleItemsCollection?.first))) to \(type(of:ScheduleItem.self)) array.")
                        
                        return
                    }
                    
                    self.mergeScheduleItems(items)
                    
                    queryBuilder.prepareNextPage()
                    pageAllScheduleData(queryBuilder: queryBuilder)
                } else {
                    // finished paging results
                    completion(nil)
                }
            }, errorHandler: { (fault) in
                print(fault)

                completion(fault)
            })
        }

        self.removeOldItems()

        let scheduleBuilder = DataQueryBuilder()
        scheduleBuilder.pageSize = 100

        pageAllScheduleData(queryBuilder: scheduleBuilder)
    }
    
    func updateArtistItems(_ completion:  @escaping (Error?) -> Void) -> Void {
        let backendless = Backendless.shared

        func pageAllArtistData(queryBuilder: DataQueryBuilder) {

            backendless.data.of(Artist.self).find(
                queryBuilder: queryBuilder,
                responseHandler: { (artistsItemsCollection: [Any]?) in
                    if artistsItemsCollection?.count != 0 {
                        guard let artists = artistsItemsCollection as? [Artist] else {
                            print("unable to convert artistsItemsCollection to Artist array")
                            
                            return
                        }
                        
                        //                    artists.forEach { $0.updated = true }
                        
                        self.mergeArtists(artists)
                        
                        queryBuilder.prepareNextPage()
                        pageAllArtistData(queryBuilder: queryBuilder)
                    } else {
                        completion(nil)
                    }
                }, errorHandler: { (fault) in
                    print(fault)

                completion(fault)
            })
        }

        let artistBuilder = DataQueryBuilder()
        artistBuilder.pageSize = 100

        pageAllArtistData(queryBuilder: artistBuilder)
    }
    
    func getArtistByName(_ artistName: String, completion: @escaping (Artist?, Error?) -> Void) -> Void {
        let backendless = Backendless.shared
        
        let artistsQueryBuilder = DataQueryBuilder()
        artistsQueryBuilder.whereClause = "ArtistName = '\(artistName)'"

        backendless.data.of(Artist.self).find(queryBuilder: artistsQueryBuilder, responseHandler: { (artistsItemsCollection: [Any]?) in
            let foundArtist = artistsItemsCollection?.first as? Artist
            
            completion(foundArtist, nil)
        }, errorHandler: { (fault) in
            self.artistItems = []
            print(fault)
            
            completion(nil, fault)
        })
    }

    func removeOutOfDateScheduleItems() {
        // remove schedule items that have not been updated
        scheduleItems = scheduleItems.filter { item in
            if item._updated {
                item._updated = false
                return true
            }
            return false
        }
    }

    func removeOutOfDateArtists() {
        // remove artists that haven't been updated
        artistItems = artistItems.filter { item in
            if item._updated {
                item._updated = false
                return true
            }
            return false
        }
    }

    func removeOldItems() {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        var itemsToRemove = [ScheduleItem]()
        
        for item in scheduleItems {
            if let date = item.startTime, Calendar.current.component(.year, from: date) < currentYear {
                itemsToRemove.append(item)
            }
        }

        scheduleItems = scheduleItems.filter { itemsToRemove.contains($0) == false }
    }
    
    func mergeScheduleItems(_ newItems: [ScheduleItem]) {
        for newItem in newItems {
            var foundItem = false
            
            for item in scheduleItems where newItem.objectId == item.objectId {
                item.update(newItem)
                foundItem = true
                
                break
            }
            
            if foundItem == false {
                newItem._updated = true
                scheduleItems.append(newItem)
            }
        }
    }
    
    func mergeArtists(_ newArtists: [Artist]) {
        for newArtist in newArtists  {
            var foundItem = false

            for artist in artistItems where newArtist.objectId == artist.objectId {
                artist.update(newArtist)
                foundItem = true
                
                break
            }
            
            if foundItem == false {
                newArtist._updated = true
                artistItems.append(newArtist)
            }
        }
    }
}
