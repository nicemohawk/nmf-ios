//
//  ScheduleTableViewController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/5/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import TwitterKit
import BBBadgeBarButtonItem


class ScheduleTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var searchController = UISearchController(searchResultsController: nil)
    
    var scheduleItems = [[ScheduleItem](),[ScheduleItem](), [ScheduleItem](), [ScheduleItem]()]
    var filteredScheduleItems = [ScheduleItem]()


    @IBOutlet weak var localNotificationsSwitch: UISwitch!
    @IBOutlet weak var localNotificationsLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if DataStore.sharedInstance.scheduleItems.count == 0 {
            DataStore.sharedInstance.updateScheduleItems() { _ in
                self.tableView.reloadData()
                
                self.sortScheduleItems(starredOnly: false)
                
                self.scrollToNearestCell()

                (UIApplication.shared.delegate as? AppDelegate)?.lastScheduleFetched = Date()
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
        button.setImage(image, for: UIControl.State())
        button.tintColor = UIColor.scheduleTextColor()
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(ScheduleTableViewController.notificationsAction), for: .touchUpInside)
        
        
        guard let barButton = BBBadgeBarButtonItem(customUIButton: button) else {
            return
        }
        
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

        sortScheduleItems(starredOnly: showingStarredOnly)

        localNotificationsSwitch.isOn = LocalNotificationController.shared.notificationsEnabled

        for scheduleCell in tableView.visibleCells.filter({ $0 is ScheduleTableViewCell }) as! [ScheduleTableViewCell] {
            guard let indexPath = tableView.indexPath(for: scheduleCell) else {
                return
            }
            
            var scheduleItem: ScheduleItem? = nil
            
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
    
    private lazy var setupTableView: Void = {
        if self.tableView.numberOfRows(inSection: 0) > 0 {
            self.scrollToNearestCell()
        }
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        _ = setupTableView
        
        super.viewDidAppear(animated)
    }
    
    func scrollToNearestCell() {
        if searchController.isActive && searchController.searchBar.text != "" {
            if filteredScheduleItems.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
            }
            
            return
        }
        
        var lastPath = IndexPath(row: 0, section: 0)

        let oneHourAgo = Date(timeIntervalSinceNow: -(1*60*60))
//        let oneHourAgo = Date(timeIntervalSinceNow: ((4*24-5)*60*60)) // for time debugging
//
//        print("One hour ago: \(oneHourAgo.description(with: .current))")

        for (section, sectionArray) in scheduleItems.enumerated().reversed() {
            for (row, scheduleItem) in sectionArray.enumerated().reversed() {
                let indexPath = IndexPath(row: row, section: section)
                
                if let time = scheduleItem.startTime, time > oneHourAgo {
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
        if searchController.isActive {
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
            return "Unknown Day"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredScheduleItems.count
        }

        if scheduleItems[section].count > 0 {
            return scheduleItems[section].count
        }

        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var scheduleItem: ScheduleItem? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)

            guard let scheduleCell = cell as? ScheduleTableViewCell else {
                return cell
            }

            let finalStartTime = foundScheduleItem.timeString()
            
            // Configure the cell...
            scheduleCell.artist.text = foundScheduleItem.artistName
            scheduleCell.stage.text = foundScheduleItem.stage
            
            let oneHourAgo = Date(timeIntervalSinceNow: -(1*60*60))
            let fifteenMinutesFromNow = Date(timeIntervalSinceNow:15*60)
//            let oneHourAgo = Date(timeIntervalSinceNow: ((4*24-5)*60*60)) // for time debugging
//            let fifteenMinutesFromNow = Date(timeInterval: (60+15)*60, since: oneHourAgo) // for time debugging
//
//            print("One hour ago: \(oneHourAgo.description(with: .current))")
//            print("15 minutes from now: \(fifteenMinutesFromNow.description(with: .current))")

            if let showTime = foundScheduleItem.startTime,
                showTime < fifteenMinutesFromNow, showTime > oneHourAgo {
                scheduleCell.startTime.text = "Now"
                scheduleCell.startTime.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
                scheduleCell.startTime.textColor = UIColor.hightlightColor()
            } else {
                scheduleCell.startTime.text = "\(finalStartTime)"
                scheduleCell.startTime.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                 scheduleCell.startTime.textColor = UIColor.lightCharcoal()
            }
            
            scheduleCell.starButton.isSelected = foundScheduleItem.starred

            if foundScheduleItem.stage == nil {
                scheduleCell.starButton.isHidden = true
                scheduleCell.centerStartTime()
            }

            return scheduleCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "NoStarsCells", for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Remove seperator inset
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var scheduleItem: ScheduleItem? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }

        guard let artistName = scheduleItem?.artistName,
            DataStore.sharedInstance.artistItems.filter({$0.artistName == artistName}).count > 0 else {
            return nil
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
        var scheduleItemsForArtist = [ScheduleItem]()
        
        if searchController.isActive {
            artistName = filteredScheduleItems[indexPath.row].artistName
            
        } else {
            if scheduleItems.count > indexPath.section && scheduleItems[indexPath.section].count > indexPath.row {
                artistName = scheduleItems[indexPath.section][indexPath.row].artistName
            }
        }
        
        if let artistName = artistName {
            scheduleItemsForArtist = DataStore.sharedInstance.scheduleItems.filter({ (item) -> Bool in
                if let name = item.artistName, name == artistName {
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
        
        var scheduleItem: ScheduleItem? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            scheduleItem = filteredScheduleItems[indexPath.row]
        } else if scheduleItems[indexPath.section].count > indexPath.row {
            scheduleItem = scheduleItems[indexPath.section][indexPath.row]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.isSelected = !sender.isSelected
            foundScheduleItem.starred = sender.isSelected

            if sender.isSelected {
                LocalNotificationController.shared.scheduleNotification(for: foundScheduleItem)
            } else {
                LocalNotificationController.shared.clearNotification(for: foundScheduleItem)
            }
        }
    }
    
    @IBAction func notificationsAction(_ sender: AnyObject) {
        // Create an API client and data source to fetch Tweets for the timeline
        let client = TWTRAPIClient()
        
        let searchQuery = "from:nelsonvillefest"
        
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: searchQuery, apiClient: client)
        
        // Create the timeline view controller
        let timelineViewControlller = TWTRTimelineViewController(dataSource: dataSource)
        
        // Create done button to dismiss the view controller
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissTimeline))
        button.tintColor = UIColor.scheduleTextColor()
        
        timelineViewControlller.navigationItem.leftBarButtonItem = button
        
        // Create a navigation controller to hold the
        let navigationController = UINavigationController(rootViewController: timelineViewControlller)
        navigationController.navigationBar.barTintColor = UIColor.hightlightColor()
        
        if let button = navigationItem.leftBarButtonItem as? BBBadgeBarButtonItem {
            button.badgeValue = nil
        }

        showDetailViewController(navigationController, sender: self)
    }

    @IBAction func localShowNotifications(_ sender: UISwitch) {
        LocalNotificationController.shared.notificationsEnabled = sender.isOn
    }

    @objc func dismissTimeline() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Search & Sort
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText != "" {
            filteredScheduleItems = filterScheduleItemsWithText(searchText)
        } else {
            filteredScheduleItems = [ScheduleItem]()
        }
        
        tableView.reloadData()
    }
    
    func filterScheduleItemsWithText(_ text: String) -> [ScheduleItem] {
        return DataStore.sharedInstance.scheduleItems.filter({ (item: ScheduleItem) -> Bool in
            let containsString = (item.artistName?.localizedStandardRange(of: text) != nil)
            
            return containsString
        })
    }
    
    func sortScheduleItems(starredOnly: Bool) {
        var thursdayShows = [ScheduleItem](), fridayShows = [ScheduleItem](), saturdayShows = [ScheduleItem](), sundayShows = [ScheduleItem]()
        
        for item in DataStore.sharedInstance.scheduleItems {
            if starredOnly && item.starred == false {
                continue
            }
            
            if let weekday = item.day {
                switch weekday {
                case "Thursday": // Thursday
                    thursdayShows.append(item)
                case "Friday": // Friday
                    fridayShows.append(item)
                case "Saturday": // Saturday
                    saturdayShows.append(item)
                case "Sunday": // Sunday
                    sundayShows.append(item)
                default:
                    print("Unable to find correct date")
                }
            }
        }
        
        let timeSort: (ScheduleItem, ScheduleItem) -> Bool = { $0.startTime?.compare($1.startTime ?? Date.distantFuture) != .orderedDescending }
        
        thursdayShows.sort(by: timeSort)
        fridayShows.sort(by: timeSort)
        saturdayShows.sort(by: timeSort)
        sundayShows.sort(by: timeSort)
        
        scheduleItems = [thursdayShows, fridayShows, saturdayShows, sundayShows]
        
        self.tableView.reloadData()
    }
}
