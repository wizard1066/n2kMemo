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
    
    func changePhotoNotificationContent(content oldContent:UNNotificationContent)-> UNMutableNotificationContent{
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
            bestAttemptContent = changePhotoNotificationContent(content: request.content)
        }

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) -plus Photo"
            
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
    
//    var lineName: String!
//    var stationName: String!
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo as! [String:Any]
//
//
//        let defaults = UserDefaults.standard
//        lineName = defaults.string(forKey: "remoteAttributes.lineName")
//        if lineName != nil {
//            stationName = defaults.string(forKey: "remoteAttributes.stationName")
//        }
//
//        if let stationLocal = userInfo["stationName"] as? String {
//            stationName = stationLocal
//        }
//        if let lineLocal = userInfo["lineName"] as? String {
//            lineName = lineLocal
//        }
//
//
//        if let stationFired = userInfo["station"] as? String {
////             if let stationFired = "default" as? String {
////            print("stationFired == selectedStation <\(stationFired)> == <\(selectedStation)>")
//            if stationFired == stationName {
//                if let lineFired = userInfo["line"] as? String {
////                    print("lineFired == selectedline <\(lineFired)> == <\(selectedLine)>")
//                    if lineFired == lineName {
//                        completionHandler([.alert,.sound,.badge])
//                    } else {
//                        completionHandler([])
//                    }
//                }
//            }
//        } else {
//            completionHandler([])
//        }
//    }

}
