//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/19/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import SafariServices


class ArtistsViewController: UIViewController {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistImageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataStore = DataStore.sharedInstance
        
        dataStore.getArtistByName("Randy Newman") { (artist, error) in
            if let foundArtist = artist {
                let url = NSURL(string: foundArtist.picture!)
                self.artistName.text = foundArtist.artistName
                self.artistBio.text = foundArtist.bio
                self.artistImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
            }
        }
        
        super.viewDidLoad()
        
        // Clear background colors from labels and buttons
        for view in backgroundColoredViews {
            view.backgroundColor = UIColor.clearColor()
        }
        
        // Set the kerning to 1 to increase spacing between letters
        headingLabels.forEach { $0.attributedText = NSAttributedString(string: $0.text!, attributes: [NSKernAttributeName: 1]) }
    }
    
    
    
    /// old code
    
    
    var vacationSpot: AnyObject!
    
    @IBOutlet var backgroundColoredViews: [UIView]!
    @IBOutlet var headingLabels: [UILabel]!
    
    @IBOutlet weak var whyVisitLabel: UILabel!
    @IBOutlet weak var whatToSeeLabel: UILabel!
    @IBOutlet weak var weatherInfoLabel: UILabel!
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var weatherHideOrShowButton: UIButton!
    @IBOutlet weak var submitRatingButton: UIButton!
    
    var shouldHideWeatherInfoSetting: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("shouldHideWeatherInfo")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "shouldHideWeatherInfo")
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Clear background colors from labels and buttons
//        for view in backgroundColoredViews {
//            view.backgroundColor = UIColor.clearColor()
//        }
//        
//        // Set the kerning to 1 to increase spacing between letters
//        headingLabels.forEach { $0.attributedText = NSAttributedString(string: $0.text!, attributes: [NSKernAttributeName: 1]) }
//        
////        title = vacationSpot.name
//        
////        whyVisitLabel.text = vacationSpot.whyVisit
////        whatToSeeLabel.text = vacationSpot.whatToSee
////        weatherInfoLabel.text = vacationSpot.weatherInfo
////        userRatingLabel.text = String(count: vacationSpot.userRating, repeatedValue: Character("★"))
//        
////        updateWeatherInfoViews(hideWeatherInfo: shouldHideWeatherInfoSetting, animated: false)
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        let currentUserRating = NSUserDefaults.standardUserDefaults().integerForKey("currentUserRating-\(vacationSpot.identifier)")
        
//        if currentUserRating > 0 {
//            submitRatingButton.setTitle("Update Rating (\(currentUserRating))", forState: .Normal)
//        } else {
//            submitRatingButton.setTitle("Submit Rating", forState: .Normal)
//        }
    }
    
    @IBAction func weatherHideOrShowButtonTapped(sender: UIButton) {
        let shouldHideWeatherInfo = sender.titleLabel!.text! == "Hide"
        updateWeatherInfoViews(hideWeatherInfo: shouldHideWeatherInfo, animated: true)
        shouldHideWeatherInfoSetting = shouldHideWeatherInfo
    }
    
    func updateWeatherInfoViews(hideWeatherInfo shouldHideWeatherInfo: Bool, animated: Bool) {
        let newButtonTitle = shouldHideWeatherInfo ? "Show" : "Hide"
        weatherHideOrShowButton.setTitle(newButtonTitle, forState: .Normal)
        
        if animated {
            UIView.animateWithDuration(0.3) {
                self.weatherInfoLabel.hidden = shouldHideWeatherInfo
            }
        } else {
            weatherInfoLabel.hidden = shouldHideWeatherInfo
        }
    }
    
    @IBAction func wikipediaButtonTapped(sender: UIButton) {
        let safariVC = SFSafariViewController(URL: NSURL(string:"http://google.com")!)
        safariVC.delegate = self
        presentViewController(safariVC, animated: true, completion: nil)
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

extension ArtistsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
