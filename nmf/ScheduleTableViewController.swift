//
//  ScheduleTableViewController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/5/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    var searchController = UISearchController(searchResultsController: nil)
    
    var filteredScheduleItems = [Schedule]()
    var scheduleItems = [[Schedule]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataStore = DataStore.sharedInstance
        
        dataStore.updateScheduleItems() { _ in
            self.tableView.reloadData()
            
            self.sortItems()
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    
//        searchController.searchBar.scopeButtonTitles = ["Starred", "All", "Today"]
        searchController.searchBar.tintColor = UIColor.lightCharcoal()
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        
        self.definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            return 1
        } else {
            return 4
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Thursday"
        case 1:
            return "Friday"
        case 2:
            return "Saturday"
        case 3:
            return "Sunday"
        default:
            return "Other"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.active {
            return filteredScheduleItems.count
        } else {
            if scheduleItems.count > section {
                return scheduleItems[section].count
            }
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath)
        guard let scheduleCell = cell as? ScheduleTableViewCell else {
            return cell
        }
        
        if scheduleItems.count > indexPath.section && scheduleItems[indexPath.section].count > indexPath.row {
            let foundScheduleItem = scheduleItems[indexPath.section][indexPath.row]
            let finalStartTime = foundScheduleItem.timeString()
            
            // Configure the cell...
            scheduleCell.artist.text = foundScheduleItem.artist
            scheduleCell.startTime.text = "\(finalStartTime)"
            scheduleCell.stage.text = foundScheduleItem.stage
        }
        
        return scheduleCell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Remove seperator inset
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
//        super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let artistViewController = segue.destinationViewController as? ArtistViewController,
            let indexPath = tableView.indexPathForSelectedRow else {
                return
        }
        
        var artistName: String? = nil
        var scheduleItemsForArtist = [Schedule]()
        
        if searchController.active {
            artistName = filteredScheduleItems[indexPath.row].artist
            
        } else {
            if scheduleItems.count > indexPath.section && scheduleItems[indexPath.section].count > indexPath.row {
                artistName = scheduleItems[indexPath.section][indexPath.row].artist
            }
        }
        
        if let artistName = artistName {
            scheduleItemsForArtist = DataStore.sharedInstance.scheduleItems.filter({ (item) -> Bool in
                if let name = item.artist where name == artistName {
                    return true
                }
                
                return false
            })
            
            for artist in DataStore.sharedInstance.artistItems {
                if artist.artistName == artistName {
                    artistViewController.artist = artist
                    artistViewController.scheduledTimes = scheduleItemsForArtist
                    
                    break
                }
            }
        }
    }
    
    // MARK: - Search & Sort
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredScheduleItems = filterScheduleItemsWithText(searchText)
        } else {
            filteredScheduleItems = [Schedule]()
        }
    }
    
    func filterScheduleItemsWithText(text: String) -> [Schedule] {
        return DataStore.sharedInstance.scheduleItems.filter({ (item: Schedule) -> Bool in
            return item.artist?.containsString(text) ?? false
        })
    }
    
    func sortItems() {
        var thursdayShows: [Schedule] = [], fridayShows: [Schedule] = [], saturdayShows: [Schedule] = [], sundayShows: [Schedule] = []

        for item in DataStore.sharedInstance.scheduleItems {
            if let time = item.starttime {
                switch NSCalendar.currentCalendar().components(.Weekday, fromDate: time).weekday {
                case 5: // Thursday
                    thursdayShows.append(item)
                case 6: // Friday
                    fridayShows.append(item)
                case 7: // Saturday
                    saturdayShows.append(item)
                case 1: // Sunday
                    sundayShows.append(item)
                default:
                    print("Unable to find correct date")
                }
            }
        }
        
        scheduleItems.append(thursdayShows)
        scheduleItems.append(fridayShows)
        scheduleItems.append(saturdayShows)
        scheduleItems.append(sundayShows)
        
        self.tableView.reloadData()
    }
}
