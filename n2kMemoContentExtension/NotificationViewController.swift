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
import CloudKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
//        bodyLabel.text = content.body
        let userInfo = content.userInfo as! [String:Any]
        print("access URL \(userInfo["image-url"])")
        if let urlString = userInfo["image-url"]{
//            let url = URL(string: urlString as! String)
            print("access URL\(urlString)")
            accessShare(URL2D: urlString as! String)
            
//            let data = try? Data(contentsOf: url!)
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: data!)
//            }
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        
    }
    
//    var lineName: String!
//    var stationName: String!
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo as! [String:Any]
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
//        if let stationFired = userInfo["station"] as? String {
////            if let stationFired = "default" as? String {
//            //            print("stationFired == selectedStation <\(stationFired)> == <\(selectedStation)>")
//            if stationFired == stationName {
//                if let lineFired = userInfo["line"] as? String {
//                    //                    print("lineFired == selectedline <\(lineFired)> == <\(selectedLine)>")
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
    
    public func accessShare(URL2D: String) {
        DispatchQueue.main.async {
        let URL2C = URL(string: URL2D)
        let metadataOperation = CKFetchShareMetadataOperation.init(shareURLs: [URL2C!])
        metadataOperation.perShareMetadataBlock = {url, metadata, error in
            if error != nil {
                print("record completion \(url) \(metadata) \(error)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 93)
                return
            }
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [metadata!])
            acceptShareOperation.qualityOfService = .background
            acceptShareOperation.perShareCompletionBlock = {meta, share, error in
                print("meta \(meta) share \(share) error \(error)")
                if error != nil {
                    self.parseCloudError(errorCode: error as! CKError, lineno: 101)
                }
                self.getShare(meta)
            }
            acceptShareOperation.acceptSharesCompletionBlock = {error in
                print("error in accept share completion \(error)")
                /// Send your user to wear that need to go in your app
                if error != nil {
                    self.parseCloudError(errorCode: error as! CKError, lineno: 109)
                }
                
                
            }
            let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
            container.add(acceptShareOperation)
//            CKContainer.default().add(acceptShareOperation)
        }
        metadataOperation.fetchShareMetadataCompletionBlock = { error in
            if error != nil {
                print("metadata error \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 121)
            }
        }
        let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
        container.add(metadataOperation)
//        CKContainer.default().add(metadataOperation)
        }
    }
    
    var imageRex: CKRecord!
    
    private func getShare(_ cloudKitShareMetadata: CKShare.Metadata) {
        DispatchQueue.main.async {
        let op = CKFetchRecordsOperation(
            recordIDs: [cloudKitShareMetadata.rootRecordID])
        
        op.perRecordCompletionBlock = { record, _, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 139)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                return
            }
            self.imageRex = record
            if let asset = self.imageRex["mediaFile"] as? CKAsset {
                let data = NSData(contentsOf: asset.fileURL)
//                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.imageView.image = UIImage(data: data! as Data)
                }
//                image2D = UIImage(data: data! as Data)
//                let peru = Notification.Name("doImage")
//                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            }
        }
        op.fetchRecordsCompletionBlock = { records, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 163)
                return
            }
        }
        let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
        container.sharedCloudDatabase.add(op)
//        CKContainer.default().sharedCloudDatabase.add(op)
        }
    }
    
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
            
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            
            let alert = UIAlertController(title:"Attention", message:message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
