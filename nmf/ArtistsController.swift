//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/19/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ArtistsController: UIViewController {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let artistInstance = DataStore.sharedInstance
        artistInstance.updateArtistsItems("Randy Newman")
        if let foundArtist = artistInstance.artistsItems {
            let url = NSURL(string: foundArtist.picture!)
            artistName.text = foundArtist.artistName
            artistBio.text = foundArtist.bio
            artistImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
        }
    }

}
