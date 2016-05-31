//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/19/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import SafariServices
import Kingfisher


class ArtistViewController: UIViewController {
    var artist: Artists?
    var scheduledTimes: [Schedule]?
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    
    @IBOutlet weak var artistImageView: UIImageView!
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var youTubeButton: UIButton!
    
    @IBOutlet weak var scheduleStackView: UIStackView!
    @IBOutlet weak var scheduleNIBView: ScheduleView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let foundArtist = artist {
            self.artistName.text = foundArtist.artistName
            self.artistBio.text = foundArtist.bio
            
            if let pictureURLString = foundArtist.picture,
                let imageURL = NSURL(string: pictureURLString) {
                
                self.artistImageView.kf_setImageWithURL(imageURL)
            }

            if let urlString = foundArtist.URL,
                let _ = NSURL(string: urlString) {
                websiteButton.enabled = true
            } else {
                websiteButton.enabled = false
            }
            
            if let urlString = foundArtist.YouTube,
                let _ = NSURL(string: urlString) {
                youTubeButton.enabled = true
            } else {
                youTubeButton.enabled = false
            }
            
            buildScheduleStack()
        }
    }
    
    func buildScheduleStack() {
        let subviews = scheduleStackView.arrangedSubviews
        
        for view in subviews {
            scheduleStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let times = scheduledTimes,
            let filePath = NSBundle.mainBundle().pathForResource("ScheduleView", ofType: "nib"),
            let nibData = NSData(contentsOfFile: filePath) else {
            scheduleStackView.hidden = true
            
            return
        }
        
        scheduleStackView.hidden = false
        
        for item in times.sort({ $0.starttime?.compare($1.starttime ?? NSDate.distantFuture()) != .OrderedDescending }) {
            UINib(data: nibData, bundle: nil).instantiateWithOwner(self, options: nil)
            
            setupScheduleView(scheduleNIBView, scheduledTime: item)
            scheduleNIBView = nil
        }
    }
    
    func setupScheduleView(scheduleView: ScheduleView, scheduledTime: Schedule) {
        scheduleView.scheduleTime = scheduledTime
        
        scheduleView.startTime.text = scheduledTime.dateString()
        scheduleView.stage.text = scheduledTime.stage
        scheduleView.starButton.selected = scheduledTime.starred
        
        scheduleView.widthAnchor.constraintEqualToConstant(CGRectGetWidth(scheduleStackView.bounds)).active = true
        scheduleView.heightAnchor.constraintEqualToConstant(48.0).active = true
        
        scheduleStackView.addArrangedSubview(scheduleView)
        
        self.view.setNeedsLayout()
    }
    
    @IBAction func starButtonAction(sender: UIButton) {
        guard let index = scheduleStackView.subviews.indexOf({ sender.isDescendantOfView($0) }) else {
            return
        }
        
        var scheduleItem: Schedule? = nil
        
        if let scheduledTimes = scheduledTimes where scheduledTimes.count > index {
            scheduleItem = scheduledTimes[index]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.selected = !sender.selected
            foundScheduleItem.starred = sender.selected
        }
    }
    
    @IBAction func websiteButtonTapped(sender: UIButton) {
        if let urlString = artist?.URL,
            let websiteURL = NSURL(string: urlString) {
            let safariVC = SFSafariViewController(URL: websiteURL)
            safariVC.delegate = self
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }

    @IBAction func youtubeButtonTapped(sender: UIButton) {
        if let urlString = artist?.YouTube,
            let youTubeURL = NSURL(string: urlString) where
            UIApplication.sharedApplication().canOpenURL(youTubeURL) {
            UIApplication.sharedApplication().openURL(youTubeURL)
        }
    }

    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segue.identifier! {
//        case "presentMapViewController":
//            guard let navigationController = segue.destinationViewController as? UINavigationController,
//                let mapViewController = navigationController.topViewController as? MapViewController else {
//                    fatalError("Unexpected view hierarchy")
//            }
//            mapViewController.locationToShow = vacationSpot.coordinate
//            mapViewController.title = vacationSpot.name
//        case "presentRatingViewController":
//            guard let navigationController = segue.destinationViewController as? UINavigationController,
//                let ratingViewController = navigationController.topViewController as? RatingViewController else {
//                    fatalError("Unexpected view hierarchy")
//            }
//            ratingViewController.vacationSpot = vacationSpot
//        default:
//            fatalError("Unhandled Segue: \(segue.identifier!)")
//        }
//    }
}

// MARK: - SFSafariViewControllerDelegate

extension ArtistViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
