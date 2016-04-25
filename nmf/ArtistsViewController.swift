//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/19/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ArtistsViewController: UIViewController {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
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
    }

}
