//
//  NotificationViewController.swift
//  n2kMemoContentExtension
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        bodyLabel.text = content.body
        let userInfo = content.userInfo as! [String:Any]
        if let urlString = userInfo["image-url"]{
            let url = URL(string: urlString as! String)
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data!)
            }
        }
        
    }

}
