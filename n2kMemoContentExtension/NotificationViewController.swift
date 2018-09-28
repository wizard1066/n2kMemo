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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
//        bodyLabel.text = content.body
        let userInfo = content.userInfo as! [String:Any]
        print("access \(userInfo)")
        if let urlString = userInfo["image-url"]{
//            let url = URL(string: urlString as! String)
            accessShare(URL2D: urlString as! String)
            print("access \(urlString)")
//            let data = try? Data(contentsOf: url!)
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: data!)
//            }
        }
        
    }
    
    public func accessShare(URL2D: String) {
        let URL2C = URL(string: URL2D)
        let metadataOperation = CKFetchShareMetadataOperation.init(shareURLs: [URL2C!])
        metadataOperation.perShareMetadataBlock = {url, metadata, error in
            if error != nil {
                print("record completion \(url) \(metadata) \(error)")
                return
            }
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [metadata!])
            acceptShareOperation.qualityOfService = .background
            acceptShareOperation.perShareCompletionBlock = {meta, share, error in
                print("meta \(meta) share \(share) error \(error)")
                self.getShare(meta)
            }
            acceptShareOperation.acceptSharesCompletionBlock = {error in
                print("error in accept share completion \(error)")
                /// Send your user to wear that need to go in your app
                
                
            }
            let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
            container.add(acceptShareOperation)
//            CKContainer.default().add(acceptShareOperation)
        }
        metadataOperation.fetchShareMetadataCompletionBlock = { error in
            if error != nil {
                print("metadata error \(error!.localizedDescription)")
            }
        }
        let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
        container.add(metadataOperation)
//        CKContainer.default().add(metadataOperation)
        
    }
    
    var imageRex: CKRecord!
    
    private func getShare(_ cloudKitShareMetadata: CKShare.Metadata) {
        let op = CKFetchRecordsOperation(
            recordIDs: [cloudKitShareMetadata.rootRecordID])
        
        op.perRecordCompletionBlock = { record, _, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                return
            }
            self.imageRex = record
            if let asset = self.imageRex["mediaFile"] as? CKAsset {
                let data = NSData(contentsOf: asset.fileURL)
//                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
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
                return
            }
        }
        let container = CKContainer(identifier: "iCloud.ch.cqd.n2kMemo")
        container.sharedCloudDatabase.add(op)
//        CKContainer.default().sharedCloudDatabase.add(op)
    }

}
