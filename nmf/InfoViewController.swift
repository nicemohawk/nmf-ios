//
//  InfoViewController.swift
//  nmf
//
//  Created by Ben Lachman on 5/30/16.
//  Copyright © 2016 Nelsonville Music Festival. All rights reserved.
//

import UIKit
import SafariServices


class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buyTixAction(sender: UIButton) {
        openLink(NSURL(string: "http://nelsonvillefest.org/tickets/"))
    }

    @IBAction func moreInfoAction(sender: UIButton) {
        openLink(NSURL(string: "http://nelsonvillefest.org/faq/"))
    }
    
    func openLink(linkURL: NSURL?) {
        if let url = linkURL {
            let safariVC = SFSafariViewController(URL: url)
            safariVC.delegate = self
            
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InfoViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

