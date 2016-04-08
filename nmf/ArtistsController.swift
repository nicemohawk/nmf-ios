//
//  ArtistsController.swift
//  nmf
//
//  Created by Daniel Pagan on 4/8/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ArtistsController: UIViewController {
    
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistBio: UILabel!
    @IBOutlet weak var artistName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        let foundArtist = dataStore.findFirst() as! Artists
        let url = NSURL(string: foundArtist.picture!)
        artistName.text = foundArtist.artistName
        artistBio.text = foundArtist.bio
        artistImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
    }
    override func viewWillLayoutSubviews() {
        
        
        super.viewWillLayoutSubviews()
    }

}
