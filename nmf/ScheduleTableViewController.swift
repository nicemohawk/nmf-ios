//
//  ScheduleTableViewController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/5/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import TwitterKit
import BBBadgeBarButtonItem


class ScheduleTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    // FIXME?
    private static var __once: () = {
            if ScheduleTableViewController.tableView.numberOfRows(inSection: 0) > 0 {
                self.scrollToNearestCell()
            }
        }()
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
        
        let button = UIButton(type: .custom)
        let image = UIImage(named: "bell")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: UIControlState())
        button.tintColor = UIColor.creamText()
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(ScheduleTableViewController.notificationsAction), for: .touchUpInside)
        
        let barButton = BBBadgeBarButtonItem(customUIButton: button)
        barButton.badgeBGColor = UIColor.lightCharcoal()
        barButton.badgeOriginX = 2
        barButton.badgeOriginY = 0
        
        navigationItem.leftBarButtonItem = barButton

        // testing
//        if let button = navigationItem.leftBarButtonItem as? BBBadgeBarButtonItem {
//            button.badgeValue = "?"
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        for scheduleCell in tableView.visibleCells as! [ScheduleTableViewCell] {
            guard let indexPath = tableView.indexPath(for: scheduleCell) else {
                return
            }
            
            var scheduleItem: Schedule? = nil
            
            if searchController.isActive && searchController.searchBar.text != "" {
                scheduleItem = filteredScheduleItems[indexPath.row]
            } else if scheduleItems[indexPath.section].count > indexPath.row {
                scheduleItem = scheduleItems[indexPath.section][indexPath.row]
            }
            
            if let foundScheduleItem = scheduleItem {
                scheduleCell.starButton.isSelected = foundScheduleItem.starred
            }
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    // FIXME?
    static var once: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        _ = ScheduleTableViewController.__once
        
        super.viewDidAppear(animated)
    }
    
    func scrollToNearestCell() {
        if searchController.isActive && searchController.searchBar.text != "" {
            if filteredScheduleItems.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
            
            return
        }
        
        var lastPath = IndexPath(row: 0, section: 0)
        let oneHourAgo = Date(timeIntervalSinceNow: -(1*60*60)) // NSDate(timeIntervalSinceNow: (2*24-6)*60*60) // test by adding 4 days
        
        for (section, sectionArray) in scheduleItems.enumerated().reversed() {
            for (row, scheduleItem) in sectionArray.enumerated().reversed() {
                let indexPath = IndexPath(row: row, section: section)
                
                if let time = scheduleItem.starttime, (time as NSDate).earlierDate(oneHourAgo) == oneHourAgo {
                    lastPath = indexPath
                    continue
                }
                
                if scheduleItems.count > lastPath.section && scheduleItems[lastPath.section].count > lastPath.row {
                    self.tableView.scrollToRow(at: lastPath, at: .top, animated: true)
                }
                
                return
            }
        }
        
        if scheduleItems.count > 0 && scheduleItems[0].count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        
        return scheduleItems.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredScheduleItems.count
        }
        
        return scheduleItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)
        
        guard let scheduleCell = cell as? ScheduleTableViewCell else {
            return cell
        }
        
        var scheduleItem: Schedule? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            let finalStartTime = foundScheduleItem.timeString()
            
            // Configure the cell...
            scheduleCell.artist.text = foundScheduleItem.artist
            scheduleCell.stage.text = foundScheduleItem.stage
            
            let oneHourAgo = Date(timeIntervalSinceNow: -(1*60*60))
            let fifteenMinutesFromNow = Date(timeIntervalSinceNow:15*60)
            
            if let showTime = foundScheduleItem.starttime,
                (showTime as NSDate).earlierDate(fifteenMinutesFromNow) == showTime, (showTime as NSDate).earlierDate(oneHourAgo) == oneHourAgo {
                scheduleCell.startTime.text = "Now"
                scheduleCell.startTime.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
                scheduleCell.startTime.textColor = UIColor.coral()
            } else {
                scheduleCell.startTime.text = "\(finalStartTime)"
                scheduleCell.startTime.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                 scheduleCell.startTime.textColor = UIColor.lightCharcoal()
            }
            
            scheduleCell.starButton.isSelected = foundScheduleItem.starred
        }
        
        return scheduleCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Remove seperator inset
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var scheduleItem: Schedule? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            guard let stage = foundScheduleItem.stage,
                stage != "" else {
                return nil
            }

            guard let artistName = scheduleItem?.artist,
                DataStore.sharedInstance.artistItems.filter({$0.artistName == artistName}).count > 0 else {
                return nil
            }
        }
        
        return indexPath
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let artistViewController = segue.destination as? ArtistViewController,
            let indexPath = tableView.indexPathForSelectedRow else {
                return
        }
        
        var artistName: String? = nil
        var scheduleItemsForArtist = [Schedule]()
        
        if searchController.isActive {
            artistName = filteredScheduleItems[indexPath.row].artist
            
        } else {
            if scheduleItems.count > indexPath.section && scheduleItems[indexPath.section].count > indexPath.row {
                artistName = scheduleItems[indexPath.section][indexPath.row].artist
            }
        }
        
        if let artistName = artistName {
            scheduleItemsForArtist = DataStore.sharedInstance.scheduleItems.filter({ (item) -> Bool in
                if let name = item.artist, name == artistName {
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
    
    @IBAction func toggleStarredOnlyAction(_ sender: UIBarButtonItem) {
        showingStarredOnly = !showingStarredOnly
        
        if showingStarredOnly {
            sender.image = UIImage(named: "star")
        } else {
            sender.image = UIImage(named: "star-empty")
        }
        
        sortScheduleItems(starredOnly: showingStarredOnly)
    }
    
    @IBAction func starItemAction(_ sender: UIButton) {
        guard let indexPath = tableView.indexPathForRow(at: tableView.convert(sender.center, from: sender.superview)) else {
            return
        }
        
        var scheduleItem: Schedule? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.isSelected = !sender.isSelected
            foundScheduleItem.starred = sender.isSelected
        }
    }
    
    @IBAction func notificationsAction(_ sender: AnyObject) {
        // Create an API client and data source to fetch Tweets for the timeline
        let client = TWTRAPIClient()
        
        //TODO: Replace with your collection id or a different data source
        let searchQuery = "from:nelsonvillefest"
        
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: searchQuery, apiClient: client)
        
        // Create the timeline view controller
        let timelineViewControlller = TWTRTimelineViewController(dataSource: dataSource)
        
        // Create done button to dismiss the view controller
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissTimeline))
        button.tintColor = UIColor.creamText()
        
        timelineViewControlller.navigationItem.leftBarButtonItem = button
        
        // Create a navigation controller to hold the
        let navigationController = UINavigationController(rootViewController: timelineViewControlller)
        navigationController.navigationBar.barTintColor = UIColor.coral()
        
        if let button = navigationItem.leftBarButtonItem as? BBBadgeBarButtonItem {
            button.badgeValue = nil
        }
        
        
        showDetailViewController(navigationController, sender: self)
    }

    @objc func dismissTimeline() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Search & Sort
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText != "" {
            filteredScheduleItems = filterScheduleItemsWithText(searchText)
        } else {
            filteredScheduleItems = [Schedule]()
        }
        
        tableView.reloadData()
    }
    
    func filterScheduleItemsWithText(_ text: String) -> [Schedule] {
        return DataStore.sharedInstance.scheduleItems.filter({ (item: Schedule) -> Bool in
            let containsString = (item.artist?.localizedStandardRange(of: text) != nil)
            
            return containsString
        })
    }
    
    func sortScheduleItems(starredOnly: Bool) {
        var thursdayShows = [Schedule](), fridayShows = [Schedule](), saturdayShows = [Schedule](), sundayShows = [Schedule]()
        
        for item in DataStore.sharedInstance.scheduleItems {
            if starredOnly && item.starred == false {
                continue
            }
            
            if let time = item.starttime {
                switch (Calendar.current as NSCalendar).components(.weekday, from: time).weekday {
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
        
        let timeSort: (Schedule, Schedule) -> Bool = { $0.starttime?.compare($1.starttime ?? Date.distantFuture) != .orderedDescending }
        
        thursdayShows.sort(by: timeSort)
        fridayShows.sort(by: timeSort)
        saturdayShows.sort(by: timeSort)
        sundayShows.sort(by: timeSort)
        
        scheduleItems = [thursdayShows, fridayShows, saturdayShows, sundayShows]
        
        self.tableView.reloadData()
    }
}
