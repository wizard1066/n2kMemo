//
//  CloudKitMethods.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import Foundation

class cloudDB: NSObject {
    
    static let share = cloudDB()
    
    var publicDB:CKDatabase!
    var privateDB: CKDatabase!
    var sharedDB: CKDatabase!
    
    private override init() {
        let container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        sharedDB = container.sharedCloudDatabase
    }
    
    public func saveZone(zone2U: String, notificationReference: CKRecord.Reference) {
        let customZone = CKRecordZone(zoneName: zone2U)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("\(error!.localizedDescription)")
            } else {
                print("customZoneID \(customZone.zoneID)")
                self.parentZone = customZone
                self.saveShare(lineName: zone2U, zoneID: customZone.zoneID, notificationLink: notificationReference)
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    var parentRecord: CKRecord!
    var parentZone: CKRecordZone!
    
    public func saveShare(lineName: String, zoneID: CKRecordZone.ID, notificationLink: CKRecord.Reference) {
        parentRecord = CKRecord(recordType: remoteRecords.notificationShare, zoneID: zoneID)
        parentRecord[remoteAttributes.lineName] = lineName
        parentRecord[remoteAttributes.stationNames] = ["default"]
        parentRecord[remoteAttributes.lineReference] = notificationLink
        //        parentRecord[remoteAttributes.zoneID] = (parentZone.zoneID as! CKRecordValue)
        let share = CKShare(rootRecord: parentRecord)
        share[CKShare.SystemFieldKey.title] = "Shared Parent" as CKRecordValue
        //        // PUBLIC permission
        share.publicPermission = .readOnly
        //        let saveOperation = CKModifyRecordsOperation(recordsToSave: [parentRecord, share], recordIDsToDelete: nil)
        // could also use phone or cloudkit user record ID
        
        //        let search = CKUserIdentityLookupInfo.init(emailAddress: "mona.lucking@gmail.com")
        //        let person2ShareWith = CKFetchShareParticipantsOperation(userIdentityLookupInfos: [search])
        //        person2ShareWith.fetchShareParticipantsCompletionBlock = { error in
        //            if error != nil {
        //                print("fetchShareParticipantsCompletionBlock \(error)")
        //            }
        //        }
        //        person2ShareWith.shareParticipantFetchedBlock = {participant in
        //            print("participant \(participant)")
        //            participant.permission = CKShareParticipantPermission.readOnly
        //
        //            share.addParticipant(participant)
        
        let modifyOperation: CKModifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [self.parentRecord, share], recordIDsToDelete: nil)
        
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        modifyOperation.perRecordCompletionBlock = {record, error in
            print("record completion \(record) and \(error)")
        }
        modifyOperation.modifyRecordsCompletionBlock = {records, recordIDs, error in
            if error != nil {
                print("modifyOperation error \(error!.localizedDescription)")
            }
            print("share url \(share.url) \(share.participants)")
            url2Share = share.url?.absoluteString
            let peru = Notification.Name("sharePin")
            NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            //                self.saveImage2Share(zone2U: zoneID)
            
            
            
            
            //                let metadataOperation = CKFetchShareMetadataOperation.init(share: [share.url!])
            //                metadataOperation.perShareMetadataBlock = {url, metadata, error in
            //                    print("record completion \(url) \(metadata) \(error)")
            //                    let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [metadata!])
            //                    acceptShareOperation.qualityOfService = .background
            //                    acceptShareOperation.perShareCompletionBlock = {meta, share, error in
            //                        print("meta \(meta) share \(share) error \(error)")
            //                    }
            //                    acceptShareOperation.acceptSharesCompletionBlock = {error in
            //                        print("error in accept share completion \(error)")
            //                        /// Send your user to wear that need to go in your app
            //
            //                    }
            //                    CKContainer.default().add(acceptShareOperation)
            //                    self.saveImage2Share(zone2U: zoneID)
            //                }
            //                metadataOperation.fetchShareMetadataCompletionBlock = { error in
            //                    if error != nil {
            //                        print("metadata error \(error!.localizedDescription)")
            //                    }
            //                }
            //                CKContainer.default().add(metadataOperation)
            
            
        }
        cloudDB.share.privateDB.add(modifyOperation)
        //        }
        //        CKContainer.default().add(person2ShareWith)
    }
    
    public func saveImage2File(file2Save: UIImage)-> URL {
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("image2Post")
        let data2Save = file2Save.pngData()
        try? data2Save?.write(to: filename)
        return filename
    }
    
    
    public func saveImage2Share(image2Save: UIImage) {
        let zone2D = CKRecordZone(zoneName: linesRead[0])
        let customRecord = CKRecord(recordType: remoteRecords.notificationMedia, zoneID: zone2D.zoneID)
//        let fileURL = Bundle.main.bundleURL.appendingPathComponent("Marley.png")
        let fileURL = saveImage2File(file2Save: image2Save)
        let ckAsset = CKAsset(fileURL: fileURL)
        
        customRecord[remoteAttributes.mediaFile] = ckAsset
        let share = CKShare(rootRecord: customRecord)
        share[CKShare.SystemFieldKey.title] = "Marley" as CKRecordValue
        share.publicPermission = .readOnly
        //        customRecord.setParent(parentRecord)
        let modifyOperation: CKModifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [customRecord, share], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        modifyOperation.perRecordCompletionBlock = {record, error in
            print("record completion \(record) and \(error)")
        }
        modifyOperation.modifyRecordsCompletionBlock = {records, recordIDs, error in
            if error != nil {
                print("modifyOperation error \(error!.localizedDescription)")
            }
            print("Marley banked \(share.url?.absoluteURL)")
            
        }
        cloudDB.share.privateDB.add(modifyOperation)
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
            CKContainer.default().add(acceptShareOperation)
        }
        metadataOperation.fetchShareMetadataCompletionBlock = { error in
            if error != nil {
                print("metadata error \(error!.localizedDescription)")
            }
        }
        CKContainer.default().add(metadataOperation)
        
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
                image2D = UIImage(data: data! as Data)
                let peru = Notification.Name("doImage")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            }
        }
        op.fetchRecordsCompletionBlock = { records, error in
            if error != nil {
                print("error \(error?.localizedDescription)")
                return
            }
        }
        CKContainer.default().sharedCloudDatabase.add(op)
    }
    
    public func saveLine(lineName: String, stationNames:[String], linePassword:String) {
        let customRecord = CKRecord(recordType: remoteRecords.notificationLine)
        
        customRecord[remoteAttributes.lineName] = lineName
        customRecord[remoteAttributes.linePassword] = linePassword
        customRecord[remoteAttributes.stationNames] = stationNames
        customRecord[remoteAttributes.lineOwner] = tokenReference
        cloudDB.share.publicDB.save(customRecord, completionHandler: ({returnRecord, error in
            if error != nil {
                
                print("saveLine error \(error)")
            } else {
                let defaults = UserDefaults.standard
                defaults.set(lineName, forKey: remoteAttributes.lineName)
                defaults.set(linePassword, forKey: remoteAttributes.linePassword)
                defaults.set(stationNames, forKey: remoteAttributes.stationNames)
                linesRead.append(lineName)
                //                linesGood2Go = !linesGood2Go
                let peru = Notification.Name("confirmPin")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                print("didSet")
                let newReference = CKRecord.Reference(record: customRecord, action: .none)
                self.saveZone(zone2U: lineName, notificationReference: newReference)
                self.updateTokenWithID(record: self.tokenReference, link2Save: newReference)
            }
        }))
    }
    
    public func deleteLine(lineName: String, linePassword: String) {
        let recordID2Access = linesDictionary[lineName + linePassword]
        cloudDB.share.publicDB.delete(withRecordID: recordID2Access!) { (recordID, error) in
            guard let recordID = recordID else {
                print(error!.localizedDescription)
                return
            }
            print("Record \(recordID) was successfully deleted")
        }
    }
    
    public func modifyStations(lineName: String, stationName: String) {
        
    }
    
    public func readLines() -> [String] {
        var linesRead:[String]!
        return linesRead
    }
    
    var tokenReference: CKRecord.Reference!
    
    public func saveToken(token2Save: String, line2Save: CKRecord.Reference) {
        
        let customRecord = CKRecord(recordType: remoteRecords.devicesLogged)
        customRecord[remoteAttributes.deviceRegistered] = token2Save
        //        let rex2D = CKRecordID(recordName: line2Save)
        //        let token2D = CKReference(recordID: rex2D, action: .none)
        customRecord[remoteAttributes.lineReference] = line2Save
        cloudDB.share.publicDB.save(customRecord, completionHandler: ({returnRecord, error in
            if error != nil {
                
                print("saveLine error \(error)")
            } else {
                self.tokenReference = CKRecord.Reference(record: customRecord, action: CKRecord_Reference_Action.none)
            }
        }))
    }
    
    public func updateLine(lineName: String, stationNames:[String], linePassword:String) {
        //        let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", lineName)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                if records?.count == 0 {
                    self.saveLine(lineName: lineName, stationNames: stationNames, linePassword: linePassword)
                } else {
                    let customRecord = records!.first
                    // Cannot change the name of a line once created
                    //                  customRecord![remoteAttributes.lineName] = lineName
                    customRecord![remoteAttributes.linePassword] = linePassword
                    customRecord![remoteAttributes.stationNames] = stationNames
                    let operation = CKModifyRecordsOperation(recordsToSave: [customRecord!], recordIDsToDelete: nil)
                    operation.savePolicy = .changedKeys
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            print("modify error\(error!.localizedDescription)")
                        } else {
                            print("record Updated \(savedRecords)")
                        }
                    }
                    CKContainer.default().publicCloudDatabase.add(operation)
                }
            }
        }
        
    }
    
    public func returnAllLines() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for record in records! {
                    linesRead.append(record[remoteAttributes.lineName]!)
                    linesDictionary[record[remoteAttributes.lineName]! + record[remoteAttributes.linePassword]!] = record.recordID
                }
                let peru = Notification.Name("showPin")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                print("linesRead read \(linesRead)")
                if linesRead.count > 0 {
                    self.returnStationsOnLine(line2Seek: linesRead[0])
                }
                //                let peru2 = Notification.Name("refresh")
                //                NotificationCenter.default.post(name: peru2, object: nil, userInfo: nil)
            }
        }
    }
    
    public func returnStationsOnLine(line2Seek: String) {
        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", line2Seek)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if records!.count > 0 {
                    let stationsFound = records!.first!.object(forKey: remoteAttributes.stationNames)
                    //                    syntax that crashes !!
                    //                        let stationsFound = records!.first![remoteAttributes.stationNames]! as? [String]
                    if (stationsFound as? [String])!.count > 0 {
                        stationsRead = (stationsFound as? [String])!
                        let peru = Notification.Name("stationPin")
                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                    }
                    self.returnTokenWithID(record: records!.first!.object(forKey: remoteAttributes.lineOwner) as? CKRecord.Reference)
                }
            }
        }
    }
    
    public func updateTokenWithID(record: CKRecord.Reference?, link2Save: CKRecord.Reference) {
        if record == nil { return }
        cloudDB.share.publicDB.fetch(withRecordID: (record?.recordID)!) { (returnedRecord, error) in
            if error != nil {
                print("updateTokenerror \(error!.localizedDescription)")
            } else {
                returnedRecord![remoteAttributes.lineReference] = link2Save
                let operation = CKModifyRecordsOperation(recordsToSave: [returnedRecord!], recordIDsToDelete: nil)
                operation.savePolicy = .changedKeys
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if error != nil {
                        print("modify error\(error!.localizedDescription)")
                    } else {
                        print("record Updated \(savedRecords)")
                    }
                }
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
    }
    
    public func returnTokenWithID(record: CKRecord.Reference?) {
        if record == nil { return }
        cloudDB.share.publicDB.fetch(withRecordID: (record?.recordID)!) { (record, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let tokenDiscovered = record!.object(forKey: remoteAttributes.deviceRegistered) as? String
                if ownerToken == tokenDiscovered {
                    let peru = Notification.Name("enablePost")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                } else {
                    let peru = Notification.Name("disablePost")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                }
                self.tokenReference = CKRecord.Reference(record: record!, action: CKRecord_Reference_Action.none)
            }
        }
    }
    
    public func setToken(token2Set: String) {
        let predicate = NSPredicate(format: remoteAttributes.deviceRegistered + " = %@", token2Set)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if records?.count == 0 {
                    // do nothing
                } else {
                    self.tokenReference = CKRecord.Reference(record: (records?.first!)!, action: CKRecord_Reference_Action.none)
                }
            }
        }
    }
    
    public func logToken(token2Save: String, lineLink: CKRecord.Reference) {
        let predicate = NSPredicate(format: remoteAttributes.deviceRegistered + " = %@", token2Save)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if records?.count == 0 {
                    self.saveToken(token2Save: token2Save, line2Save: lineLink)
                } else {
                    self.tokenReference = CKRecord.Reference(record: (records?.first!)!, action: CKRecord_Reference_Action.none)
                }
            }
        }
    }
    
    public func fetchPublicInZone(zone2Search: String) {
        let zone2D = CKRecordZone(zoneName: zone2Search)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: remoteRecords.notificationMedia, predicate: predicate)
        
        cloudDB.share.sharedDB.perform(query, inZoneWith: zone2D.zoneID) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for record in records! {
                    if let asset = record["mediaFile"] as? CKAsset,
                        let data = NSData(contentsOf: asset.fileURL),
                        let image2D = UIImage(data: data as Data) {
                        let peru = Notification.Name("doImage")
                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                    }
                }
                print("tokens read \(tokensRead)")
            }
        }
    }
    
    
    
    public func returnAllTokens() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for record in records! {
                    tokensRead.append(record[remoteAttributes.deviceRegistered]!)
                }
                print("tokens read \(tokensRead)")
            }
        }
    }
    
}


//var keyStore = NSUbiquitousKeyValueStore()

//func icloudStatus() -> Bool?{
//    return FileManager.default.ubiquityIdentityToken != nil ? true : false
//}
//
//func returnURLgivenKey(key2search: String, typeOf: String) -> String? {
//    let searchString2U = key2search.trimmingCharacters(in: .whitespacesAndNewlines) + typeOf
//    if let storedURL = keyStore.string(forKey: searchString2U) {
//        return storedURL
//    } else {
//        return nil
//    }
//}
//
//func storeURLgivenKey(key2Store: String, URL2Store: String, pass2U: String) {
//    let URLkey2U = key2Store.trimmingCharacters(in: .whitespacesAndNewlines) + ".URL"
//    let passKey2U = key2Store.trimmingCharacters(in: .whitespacesAndNewlines) + ".PASS"
//    keyStore.set(URL2Store, forKey: URLkey2U)
//    keyStore.set(pass2U, forKey: passKey2U)
//    keyStore.synchronize()
//}


