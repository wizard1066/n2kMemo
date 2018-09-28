//
//  NotificationService.swift
//  n2kMemoServiceExtension
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    func changePizzaNotificationContent(content oldContent:UNNotificationContent)-> UNMutableNotificationContent{
        let content = oldContent.mutableCopy() as! UNMutableNotificationContent
        let userInfo = content.userInfo as! [String:Any]
        //add the subtitle
        if let subtitle = userInfo["subtitle"] {
            content.subtitle = subtitle as! String
        }
        
        if let orderEntry = userInfo["order"]{
            let orders = orderEntry as! [String]
            var body = ""
            for item in orders{
                body += item + ", "
            }
            content.body = body
        }
        return content
    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if bestAttemptContent?.categoryIdentifier == "photo.category" {
            bestAttemptContent = changePizzaNotificationContent(content: request.content)
        }
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) -push Photo"
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
