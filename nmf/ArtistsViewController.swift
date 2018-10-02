//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/19/16.
//  Copyright © 2017 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import SafariServices
import Kingfisher


class ArtistViewController: UIViewController {
    var artist: Artist?
    var scheduledTimes: [ScheduleItem]?
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    
    @IBOutlet weak var artistImageView: UIImageView!
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var youTubeButton: UIButton!
    
    @IBOutlet weak var scheduleStackView: UIStackView!
    @IBOutlet weak var scheduleNIBView: ScheduleView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let foundArtist = artist {
            self.artistName.text = foundArtist.artistName
            self.artistBio.text = foundArtist.bio
            
            if let pictureURLString = foundArtist.picture,
                let imageURL = URL(string: pictureURLString) {
                
                self.artistImageView.kf.setImage(with: imageURL)
            }

            if let urlString = foundArtist.url,
                let _ = URL(string: urlString) {
                websiteButton.isEnabled = true
            } else {
                websiteButton.isEnabled = false
            }
            
            if let urlString = foundArtist.youTube,
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
        
        for item in times.sorted(by: { $0.startTime?.compare($1.startTime ?? Date.distantFuture) != .orderedDescending }) {
            UINib(data: nibData, bundle: nil).instantiate(withOwner: self, options: nil)
            
            setupScheduleView(scheduleNIBView, scheduledTime: item)
            scheduleNIBView = nil
        }
    }
    
    func setupScheduleView(_ scheduleView: ScheduleView, scheduledTime: ScheduleItem) {
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
        
        var scheduleItem: ScheduleItem? = nil
        
        if let scheduledTimes = scheduledTimes, scheduledTimes.count > index {
            scheduleItem = scheduledTimes[index]
        }
        
        if let foundScheduleItem = scheduleItem {
            sender.isSelected = !sender.isSelected
            foundScheduleItem.starred = sender.isSelected
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: UIButton) {
        if let urlString = artist?.url,
            let websiteURL = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: websiteURL)
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
    }

    @IBAction func youtubeButtonTapped(_ sender: UIButton) {
        if let urlString = artist?.youTube,
            let youTubeURL = URL(string: urlString),
            UIApplication.shared.canOpenURL(youTubeURL) {
            UIApplication.shared.openURL(youTubeURL)
        }
    }
}

// MARK: - SFSafariViewControllerDelegate

extension ArtistViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
