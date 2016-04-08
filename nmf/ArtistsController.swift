//
//  ArtistsController.swift
//  nmf
//
//  Created by Julia Pagan on 3/20/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit

class ArtistsController: UIViewController{
    
    @IBOutlet weak var ArtistImage: UIImageView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var ArtistBio: UILabel!
    @IBOutlet weak var ArtistName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless.data.of(Artists.ofClass())
        let foundArtist = dataStore.findFirst() as! Artists
        let url = NSURL(string: foundArtist.picture!)
        ArtistName.text = foundArtist.artistName
        ArtistBio.text = foundArtist.bio
        ArtistImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
    }
    
    
}
