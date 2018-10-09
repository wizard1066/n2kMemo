//
//  NotificationService.swift
//  n2kMemoServiceExtension
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UserNotifications
import UserNotificationsUI
import CloudKit
import UIKit

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
            bestAttemptContent.title = "\(bestAttemptContent.title) -with Photo"
            
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
    
    func parseCloudError(errorCode: CKError, lineno: Int) {
        switch errorCode {
        case CKError.internalError:
            doAlert(title: "iCloudError" + String(lineno), message:  "CloudKit.framework encountered an error.  This is a non-recoverable error.")
            break
        case CKError.partialFailure:
            doAlert(title: "iCloudError" + String(lineno), message:  "Some items failed, but the operation succeeded overall.")
            break
        case CKError.networkUnavailable:
            doAlert(title: "iCloudError" + String(lineno), message:  "Network not available.")
            break
        case CKError.networkFailure:
            doAlert(title: "iCloudError" + String(lineno), message:  "Network error (available but CFNetwork gave us an error).")
            break
        case CKError.badContainer:
            doAlert(title: "iCloudError" + String(lineno), message:  "Un-provisioned or unauthorized container. Try provisioning the container before retrying the operation.")
            break
        case CKError.serviceUnavailable:
            doAlert(title: "iCloudError" + String(lineno), message:  "Service unavailable.")
            break
        case CKError.requestRateLimited:
            doAlert(title: "iCloudError" + String(lineno), message:  "Client is being rate limited.")
            break
        case CKError.missingEntitlement:
            doAlert(title: "iCloudError" + String(lineno), message:  "Missing entitlement.")
            break
        case CKError.notAuthenticated:
            doAlert(title: "iCloudError" + String(lineno), message:  "Not authenticated (writing without being logged in, no user record).")
            break
        case CKError.permissionFailure:
            doAlert(title: "iCloudError" + String(lineno), message:  "Access failure (save or fetch.  This is a non-recoverable error.")
            break
        case CKError.unknownItem:
            doAlert(title: "iCloudError" + String(lineno), message:  "Record does not exist.  This is a non-recoverable error.")
            break
        case CKError.invalidArguments:
            doAlert(title: "iCloudError" + String(lineno), message:  "Bad client request (bad record graph, malformed predicate).")
            break
        case CKError.serverRecordChanged:
            doAlert(title: "iCloudError" + String(lineno), message:  "The record was rejected because the version on the server was different.")
            break
        case CKError.serverRejectedRequest:
            doAlert(title: "iCloudError" + String(lineno), message:  "The server rejected this request.  This is a non-recoverable error.")
            break
        case CKError.assetFileNotFound:
            doAlert(title: "iCloudError" + String(lineno), message:  "Asset file was not found.")
            break
        case CKError.assetFileModified:
            doAlert(title: "iCloudError" + String(lineno), message:  "Asset file content was modified while being saved.")
            break
        case CKError.incompatibleVersion:
            doAlert(title: "iCloudError" + String(lineno), message:  "App version is less than the minimum allowed version.")
            break
        case CKError.constraintViolation: /*  */
            doAlert(title: "iCloudError" + String(lineno), message:  "The server rejected the request because there was a conflict with a unique field.")
            break
        case CKError.operationCancelled: /* */
            doAlert(title: "iCloudError" + String(lineno), message:  "A CKOperation was explicitly cancelled.")
            break
        case CKError.changeTokenExpired: /*  */
            doAlert(title: "iCloudError" + String(lineno), message:  "The previousServerChangeToken value is too old and the client must re-sync from scratch.")
            break
        case CKError.batchRequestFailed:
            doAlert(title: "iCloudError" + String(lineno), message:  "One of the items in this batch operation failed in a zone with atomic updates, so the entire batch was rejected.")
            break
        case CKError.zoneBusy:
            doAlert(title: "iCloudError" + String(lineno), message:  "The server is too busy to handle this zone operation. Try the operation again in a few seconds.")
            break
        case CKError.badDatabase:
            doAlert(title: "iCloudError" + String(lineno), message:  "Operation could not be completed on the given database. Likely caused by attempting to modify zones in the public database.")
            break
        case CKError.quotaExceeded:
            doAlert(title: "iCloudError" + String(lineno), message:  "Saving a record would exceed quota.")
            break
        case CKError.zoneNotFound:
            doAlert(title: "iCloudError" + String(lineno), message:  "The specified zone does not exist on the server.")
            break
        case CKError.limitExceeded:
            doAlert(title: "iCloudError" + String(lineno), message:  "The request to the server was too large. Retry this request as a smaller batch")
            break
        case CKError.userDeletedZone:
            doAlert(title: "iCloudError" + String(lineno), message:  "The user deleted this zone through the settings UI. Your client should either remove its local data or prompt the user before attempting to re-upload any data to this zone.")
            break
        default:
            // do nothing
            break
        }
    }
    
    
    func doAlert(title: String, message:String) {
//        let peru = Notification.Name(localObservers.showAlert)
//        let dict = [localdefault.alertMessage:message]
//        NotificationCenter.default.post(name: peru, object: nil, userInfo: dict)
        DispatchQueue.main.async {
            let alert = UIAlertController(title:"Attention", message:message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        }
    }

}
