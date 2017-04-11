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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let foundArtist = artist {
            self.artistName.text = foundArtist.artistName
            self.artistBio.text = foundArtist.bio
            
            if let pictureURLString = foundArtist.picture,
                let imageURL = URL(string: pictureURLString) {
                
                self.artistImageView.kf_setImageWithURL(imageURL)
            }

            if let urlString = foundArtist.URL,
                let _ = URL(string: urlString) {
                websiteButton.isEnabled = true
            } else {
                websiteButton.isEnabled = false
            }
            
            if let urlString = foundArtist.YouTube,
                let _ = URL(string: urlString) {
                youTubeButton.isEnabled = true
            } else {
                youTubeButton.isEnabled = false
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
            let filePath = Bundle.main.path(forResource: "ScheduleView", ofType: "nib"),
            let nibData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            scheduleStackView.isHidden = true
            
            return
        }
        
        scheduleStackView.isHidden = false
        
        for item in times.sorted(by: { $0.starttime?.compare($1.starttime ?? Date.distantFuture) != .orderedDescending }) {
            UINib(data: nibData, bundle: nil).instantiate(withOwner: self, options: nil)
            
            setupScheduleView(scheduleNIBView, scheduledTime: item)
            scheduleNIBView = nil
        }
    }
    
    func setupScheduleView(_ scheduleView: ScheduleView, scheduledTime: Schedule) {
        scheduleView.scheduleTime = scheduledTime
        
        scheduleView.startTime.text = scheduledTime.dateString()
        scheduleView.stage.text = scheduledTime.stage
        scheduleView.starButton.isSelected = scheduledTime.starred
        
        scheduleView.widthAnchor.constraint(equalToConstant: scheduleStackView.bounds.width).isActive = true
        scheduleView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        scheduleStackView.addArrangedSubview(scheduleView)
        
        self.view.setNeedsLayout()
    }
    
    @IBAction func starButtonAction(_ sender: UIButton) {
        guard let index = scheduleStackView.subviews.index(where: { sender.isDescendant(of: $0) }) else {
            return
        }
        
        var scheduleItem: Schedule? = nil
        
        if let scheduledTimes = scheduledTimes where scheduledTimes.count > index {
            scheduleItem = scheduledTimes[index]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.isSelected = !sender.isSelected
            foundScheduleItem.starred = sender.isSelected
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: UIButton) {
        if let urlString = artist?.URL,
            let websiteURL = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: websiteURL)
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
    }

    @IBAction func youtubeButtonTapped(_ sender: UIButton) {
        if let urlString = artist?.YouTube,
            let youTubeURL = URL(string: urlString) where
            UIApplication.shared.canOpenURL(youTubeURL) {
            UIApplication.shared.openURL(youTubeURL)
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
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
