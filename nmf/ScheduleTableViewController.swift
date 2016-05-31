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
    
    var scheduleItems = [[Schedule](),[Schedule](), [Schedule](), [Schedule]()]
    var filteredScheduleItems = [Schedule]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataStore.sharedInstance.scheduleItems.count == 0 {
            DataStore.sharedInstance.updateScheduleItems() { _ in
                self.tableView.reloadData()
                
                self.sortScheduleItems(starredOnly: false)
                
                self.scrollToNearestCell()
            }
        } else {
            sortScheduleItems(starredOnly: false)
            
            scrollToNearestCell()
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.tintColor = UIColor.lightCharcoal()
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        
        clearsSelectionOnViewWillAppear = false
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
 
        for scheduleCell in tableView.visibleCells as! [ScheduleTableViewCell] {
            guard let indexPath = tableView.indexPathForCell(scheduleCell) else {
                return
            }
            
            var scheduleItem: Schedule? = nil
            
            if searchController.active && searchController.searchBar.text != "" {
                scheduleItem = filteredScheduleItems[indexPath.row]
            } else if scheduleItems[indexPath.section].count > indexPath.row {
                scheduleItem = scheduleItems[indexPath.section][indexPath.row]
            }
            
            if let foundScheduleItem = scheduleItem {
                scheduleCell.starButton.selected = foundScheduleItem.starred
            }
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    static var once: dispatch_once_t = 0
    
    override func viewDidAppear(animated: Bool) {
        dispatch_once(&ScheduleTableViewController.once) {
            if self.tableView.numberOfRowsInSection(0) > 0 {
                self.scrollToNearestCell()
            }
        }
        
        super.viewDidAppear(animated)
    }
    
    func scrollToNearestCell() {
        if searchController.active && searchController.searchBar.text != "" {
            if filteredScheduleItems.count > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
            
            return
        }
        
        var lastPath = NSIndexPath(forRow: 0, inSection: 0)
        let oneHourAgo = NSDate(timeIntervalSinceNow: -(1*60*60)) // NSDate(timeIntervalSinceNow: 4*24*60*60) // test by adding 4 days
        
        for (section, sectionArray) in scheduleItems.reverse().enumerate() {
            for (row, scheduleItem) in sectionArray.reverse().enumerate() {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                
                if let time = scheduleItem.starttime where time.earlierDate(oneHourAgo) == oneHourAgo {
                    lastPath = indexPath
                    continue
                }
                
                if scheduleItems.count > lastPath.section && scheduleItems[lastPath.section].count > lastPath.row {
                    self.tableView.scrollToRowAtIndexPath(lastPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                }
                
                return
            }
        }
        
        if scheduleItems.count > 0 && scheduleItems[0].count > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        
        return scheduleItems.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections == 1 {
            return "Results"
        }
        
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
            return "Error"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredScheduleItems.count
        }
        
        return scheduleItems[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath)
        
        guard let scheduleCell = cell as? ScheduleTableViewCell else {
            return cell
        }
        
        var scheduleItem: Schedule? = nil
        
        if searchController.active && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            let finalStartTime = foundScheduleItem.timeString()
            
            // Configure the cell...
            scheduleCell.artist.text = foundScheduleItem.artist
            scheduleCell.stage.text = foundScheduleItem.stage
            
            let oneHourAgo = NSDate(timeIntervalSinceNow: (3*24-2)*60*60)//NSDate(timeIntervalSinceNow: -(1*60*60))
            
            if let showTime = foundScheduleItem.starttime where
                showTime.earlierDate(NSDate(timeIntervalSinceNow:15*60)) == showTime && showTime.earlierDate(oneHourAgo) == oneHourAgo {
                scheduleCell.startTime.text = "Now"
                scheduleCell.startTime.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
                scheduleCell.startTime.textColor = UIColor.coral()
            } else {
                scheduleCell.startTime.text = "\(finalStartTime)"
                scheduleCell.startTime.font = UIFont.systemFontOfSize(UIFont.labelFontSize())
                 scheduleCell.startTime.textColor = UIColor.lightCharcoal()
            }
            
            scheduleCell.starButton.selected = foundScheduleItem.starred
        }
        
        return scheduleCell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Remove seperator inset
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var scheduleItem: Schedule? = nil
        
        if searchController.active && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            guard let stage = foundScheduleItem.stage where stage != "" else {
                return nil
            }
        }
        
        return indexPath
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
    
    // MARK: - Actions
    
    var showingStarredOnly = false
    
    @IBAction func toggleStarredOnlyAction(sender: UIBarButtonItem) {
        showingStarredOnly = !showingStarredOnly
        
        if showingStarredOnly {
            sender.image = UIImage(named: "star")
        } else {
            sender.image = UIImage(named: "star-empty")
        }
        
        sortScheduleItems(starredOnly: showingStarredOnly)
    }
    
    @IBAction func starItemAction(sender: UIButton) {
        guard let indexPath = tableView.indexPathForRowAtPoint(tableView.convertPoint(sender.center, fromView: sender.superview)) else {
            return
        }
        
        var scheduleItem: Schedule? = nil
        
        if searchController.active && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.selected = !sender.selected
            foundScheduleItem.starred = sender.selected
        }
    }
    
    
    // MARK: - Search & Sort
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text where searchText != "" {
            filteredScheduleItems = filterScheduleItemsWithText(searchText)
        } else {
            filteredScheduleItems = [Schedule]()
        }
        
        tableView.reloadData()
    }
    
    func filterScheduleItemsWithText(text: String) -> [Schedule] {
        return DataStore.sharedInstance.scheduleItems.filter({ (item: Schedule) -> Bool in
            let containsString = (item.artist?.localizedStandardRangeOfString(text) != nil)
            
            return containsString
        })
    }
    
    func sortScheduleItems(starredOnly starredOnly: Bool) {
        var thursdayShows = [Schedule](), fridayShows = [Schedule](), saturdayShows = [Schedule](), sundayShows = [Schedule]()
        
        for item in DataStore.sharedInstance.scheduleItems {
            if starredOnly && item.starred == false {
                continue
            }
            
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
        
        scheduleItems = [thursdayShows, fridayShows, saturdayShows, sundayShows]
        
        self.tableView.reloadData()
    }
}
