//
//  AppDelegate.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//
// a85fdfcf2006f9e91de28336fd6887374cd051dca961a04e71a7a8ceed951708

import UIKit
import UserNotifications
import CloudKit
import SafariServices



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var colorZet = Set<String>()
    var tagZet = Set<String>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setCategories()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if !granted {
                // ask permission
                permission2SendNotifications = false
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    permission2SendNotifications = true
                }
            }
        }
        return true
    }
    
    func tokenString(_ deviceToken:Data) -> String {
        let bytes = [UInt8](deviceToken)
        var token = ""
        for byte in bytes {
            token += String(format:"%02x", byte)
        }
        return token
    }
    
    func setCategories(){
        let webAction = UNNotificationAction(identifier: "web.action", title: "Web", options: [])
        let webCategory = UNNotificationCategory(identifier: "web.category", actions: [webAction], intentIdentifiers: [], options: [])
        let photoAction = UNNotificationAction(identifier: "photo.action", title: "Photo", options: [])
        let photoCategory = UNNotificationCategory(identifier: "photo.category", actions: [photoAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([webCategory, photoCategory])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successful registration. Token is:")
        print(tokenString(deviceToken))
        ownerToken = tokenString(deviceToken)
        let defaults = UserDefaults.standard
        let previousToken = defaults.string(forKey: localdefault.tokentab)
        if previousToken == nil {
            defaults.set(ownerToken, forKey:localdefault.tokentab)
            cloudDB.share.logToken(token2Save: ownerToken, lineLink: nil, lineName: nil)
        } else {
            if previousToken != ownerToken {
                cloudDB.share.deleteToken(token2Delete: previousToken!)
                defaults.set(ownerToken, forKey:localdefault.tokentab)
                let line2U = defaults.string(forKey: remoteAttributes.lineName)
                cloudDB.share.logToken(token2Save: ownerToken, lineLink: nil, lineName: line2U)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let acceptSharing: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        
        acceptSharing.qualityOfService = .userInteractive
        acceptSharing.perShareCompletionBlock = {meta, share, error in
            print("successfully shared \(meta) \(share) \(error)")
        }
        acceptSharing.acceptSharesCompletionBlock = {
            error in
            guard (error == nil) else{
                print("Error \(error?.localizedDescription ?? "")")
                return
            }
            
            //            let viewController: AddItemViewController =
            //                self.window?.rootViewController as! AddItemViewController
            self.fetchShare(cloudKitShareMetadata)
            
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharing)
    }
    
    var item: CKRecord!
    
    func fetchShare(_ cloudKitShareMetadata: CKShare.Metadata){
        let op = CKFetchRecordsOperation(
            recordIDs: [cloudKitShareMetadata.rootRecordID])
        
        op.perRecordCompletionBlock = { record, _, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                return
            }
            self.item = record
        }
        op.fetchRecordsCompletionBlock = { records, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                return
            }
            print("record \(self.item)")
            let line2S = self.item.object(forKey: remoteAttributes.lineName) as! String
            let station2S = self.item.object(forKey: remoteAttributes.stationNames) as! [String]
            let line2Link = self.item.object(forKey: remoteAttributes.lineReference) as! CKRecord.Reference
            lineZoneID = self.item.object(forKey: remoteAttributes.zoneID) as? String
            linesRead = [line2S]
            stationsRead = station2S
            selectedLine = linesRead.first
            selectedStation = stationsRead.first
            let defaults = UserDefaults.standard
            defaults.set(selectedStation, forKey: remoteAttributes.stationName)
            defaults.set(selectedLine, forKey: remoteAttributes.lineName)
            let peru = Notification.Name("stationPin")
            NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            let peru2 = Notification.Name("showPin")
            NotificationCenter.default.post(name: peru2, object: nil, userInfo: nil)
            cloudDB.share.logToken(token2Save: ownerToken, lineLink: line2Link, lineName: selectedLine)
            let peru3 = Notification.Name("hidePostingNConfig")
            NotificationCenter.default.post(name: peru3, object: nil, userInfo: nil)
            
        }
        CKContainer.default().sharedCloudDatabase.add(op)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var urlString: String?
    var urlSeek: String?
    
    // Mark: Delegates
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo as! [String:Any]
        
        if let urlString = userInfo["http-url"] as? String {
            urlSeek = urlString
        }
        
        if let stationFired = userInfo["station"] as? String {
            print("stationFired == selectedStation <\(stationFired)> == <\(selectedStation)>")
            if stationFired == selectedStation {
                if let lineFired = userInfo["line"] as? String {
                    print("lineFired == selectedline <\(lineFired)> == <\(selectedLine)>")
                    if lineFired == selectedLine {
                        completionHandler([.alert,.sound,.badge])
                    } else {
                        completionHandler([])
                    }
                } 
            }
        } else {
            completionHandler([])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        let request = response.notification.request
        
        if action == "web.action"{
            var dict:[String:Any] = [:]
            dict["http-url"] = urlSeek
            let peru = Notification.Name("showWeb")
            NotificationCenter.default.post(name: peru, object: nil, userInfo: dict)
        }
        completionHandler()
    }

}

