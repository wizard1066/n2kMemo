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
    
    public func saveZone(zone2U: String, notificationReference: CKRecord.Reference, stationNames:[String], stationSelected:CKRecord.Reference) {
        let customZone = CKRecordZone(zoneName: zone2U)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("\(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 35)
            } else {
//                print("customZoneID \(customZone.zoneID)")
                self.parentZone = customZone
                self.saveShare(lineName: zone2U, zone2ID: customZone.zoneID, notificationLink: notificationReference, station2Save: stationNames, stationSelected: stationSelected)
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
        
    }
    
    var parentRecord: CKRecord!
    var parentZone: CKRecordZone!
    
    public func saveShare(lineName: String, zone2ID: CKRecordZone.ID, notificationLink: CKRecord.Reference, station2Save:[String], stationSelected: CKRecord.Reference) {
//        parentRecord = CKRecord(recordType: remoteRecords.notificationShare, zoneID: zoneID)

        let customID = CKRecord.ID(recordName: remoteRecords.notificationShare, zoneID: zone2ID)
        parentRecord = CKRecord(recordType: remoteRecords.notificationShare, recordID: customID)
        parentRecord[remoteAttributes.lineName] = lineName
        parentRecord[remoteAttributes.stationNames] = station2Save
        parentRecord[remoteAttributes.lineReference] = notificationLink
        parentRecord[remoteAttributes.stationReference] = stationSelected
        //        parentRecord[remoteAttributes.zoneID] = (parentZone.zoneID as! CKRecordValue)
        // fuck
        let share = CKShare(rootRecord: parentRecord)
//        let thumb = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("work_in_progress").dataRepresentation
        
        
        share[CKShare.SystemFieldKey.title] = "Shared Parent" as CKRecordValue
//        share[CKShare.SystemFieldKey.thumbnailImageData] = thumb as CKRecordValue
//        share[CKShare.SystemFieldKey.shareType] = "ch.cqd.m2kMemo" as CKRecordValue
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
//            print("record completion \(record) and \(error)")
        }
        modifyOperation.modifyRecordsCompletionBlock = {records, recordIDs, error in
            if error != nil {
                print("modifyOperation error \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 86)
            }
//            print("share url \(share.url) \(share.participants)")
            url2Share = share.url?.absoluteString
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
//                self.redo(lineName: lineName, shareName: (share.url?.absoluteString)!, gogo: .now() + 15)
//                self.updateLineURL(line2U: lineName, url2U: url2Share!)
//            }
        }
        cloudDB.share.privateDB.add(modifyOperation)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func reduceImage(inImage:UIImage?) -> UIImage {
        var outImage: UIImage!
        if inImage != nil {
            outImage = inImage?.resize(size: CGSize(width: 1080, height: 1920))
//            image2D = UIImageJPEGRepresentation(newImage!, 1.0)
        }
//        else {
//            image2D = UIImageJPEGRepresentation(UIImage(named: "noun_1348715_cc")!, 1.0)
//        }
        return outImage
    }
    
    public func saveImage2File(file2Save: UIImage)-> URL {
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("image2Post")
        let data2Save = file2Save.pngData()
        try? data2Save?.write(to: filename)
        return filename
    }
    
    
    public func saveImage2Share(image2Save: UIImage) {
        if selectedLine == nil { return }
//        let sizedImage = reduceImage(inImage: image2Save)
        let zone2D = CKRecordZone(zoneName: selectedLine)
//        let customRecord = CKRecord(recordType: remoteRecords.notificationMedia, zoneID: zone2D.zoneID)
        let customID = CKRecord.ID(recordName: remoteRecords.notificationMedia, zoneID: zone2D.zoneID)
        let customRecord = CKRecord(recordType: remoteRecords.notificationMedia, recordID: customID)
//        let fileURL = Bundle.main.bundleURL.appendingPathComponent("Marley.png")
        let fileURL = saveImage2File(file2Save: image2Save)
        let ckAsset = CKAsset(fileURL: fileURL)
        
        customRecord[remoteAttributes.mediaFile] = ckAsset
        let share = CKShare(rootRecord: customRecord)
        share[CKShare.SystemFieldKey.title] = "Marley" as CKRecordValue
//        share[CKShare.SystemFieldKey.shareType] = "ch.cqd.m2kMemo" as CKRecordValue
        
//        let imageData = image2Save.pngData()!
//        let options = [
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
//        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
//        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
//        let thumbnail = UIImage(cgImage: imageReference).pngData()
//
//        thumbImage = UIImage(cgImage: imageReference)
//        let peru = Notification.Name("thumb")
//        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
        
//        share[CKShare.SystemFieldKey.thumbnailImageData] = thumbnail! as CKRecordValue
        
        share.publicPermission = .readOnly
        //        customRecord.setParent(parentRecord)
        let modifyOperation: CKModifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [customRecord, share], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .allKeys
        modifyOperation.perRecordCompletionBlock = {record, error in
            if error != nil {
                print("record completion \(record) and \(error)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 151)
            }
        }
        modifyOperation.modifyRecordsCompletionBlock = {records, recordIDs, error in
            if error != nil {
                print("modifyOperation error \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 151)
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                media2Share = share.url?.absoluteString
//            }
//            let peru = Notification.Name("enablePost")
//            NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            
        }
        cloudDB.share.privateDB.add(modifyOperation)
    }
    
    public func accessShare(URL2D: String) {
        let URL2C = URL(string: URL2D)
        let metadataOperation = CKFetchShareMetadataOperation.init(shareURLs: [URL2C!])
        metadataOperation.perShareMetadataBlock = {url, metadata, error in
            if error != nil {
                print("record completion \(url) \(metadata) \(error)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 168)
                return
            }
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [metadata!])
            acceptShareOperation.qualityOfService = .background
            acceptShareOperation.perShareCompletionBlock = {meta, share, error in
                print("meta \(meta) share \(share) error \(error)")
                if error != nil {
                    self.parseCloudError(errorCode: error as! CKError, lineno: 173)
                }
                self.getShare(meta)
            }
            acceptShareOperation.acceptSharesCompletionBlock = {error in
                print("error in accept share completion \(error)")
                if error != nil {
                    self.parseCloudError(errorCode: error as! CKError, lineno: 173)
                }
                
            }
            CKContainer.default().add(acceptShareOperation)
        }
        metadataOperation.fetchShareMetadataCompletionBlock = { error in
            if error != nil {
                print("metadata error \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 187)
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
                self.parseCloudError(errorCode: error as! CKError, lineno: 203)
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
                self.parseCloudError(errorCode: error as! CKError, lineno: 217)
                return
            }
        }
        CKContainer.default().sharedCloudDatabase.add(op)
    }
    
    public func saveLine(lineName: String, stationNames:[String], stationSelected: String, linePassword:String) {
        let customRecord = CKRecord(recordType: remoteRecords.notificationLine)
        
        customRecord[remoteAttributes.lineName] = lineName
        customRecord[remoteAttributes.linePassword] = linePassword
//        customRecord[remoteAttributes.stationNames] = stationNames
        customRecord[remoteAttributes.lineOwner] = tokenReference
        cloudDB.share.publicDB.save(customRecord, completionHandler: ({returnRecord, error in
            if error != nil {
                
                print("saveLine error \(error)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 235)
            } else {
                let defaults = UserDefaults.standard
                defaults.set(lineName, forKey: remoteAttributes.lineName)
                defaults.set(linePassword, forKey: remoteAttributes.linePassword)
                defaults.set(stationNames, forKey: remoteAttributes.stationNames)
                linesRead.append(lineName)
                //                linesGood2Go = !linesGood2Go
                let peru = Notification.Name("confirmPin")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                let newReference = CKRecord.Reference(record: customRecord, action: .none)
                self.saveStations(lineName: lineName, lineReference: newReference, stationNames: stationNames, stationSelected: stationSelected)
            }
        }))
    }
    
    private func saveStations(lineName: String, lineReference: CKRecord.Reference, stationNames: [String], stationSelected: String) {
        
        var stationRex:[CKRecord] = []
        var stationDict:[String:CKRecord.Reference] = [:]
        
        for stationName in stationNames {
            let customRecord = CKRecord(recordType: remoteRecords.notificationStation)
            customRecord[remoteAttributes.stationName] = stationName
            customRecord[remoteAttributes.lineReference] = lineReference
            stationRex.append(customRecord)
            let newReference = CKRecord.Reference(record: customRecord, action: .none)
            stationDict[stationName] = newReference
        }
        let operation = CKModifyRecordsOperation(recordsToSave: stationRex, recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("modify error\(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 316)
            } else {
//                self.saveZone(zone2U: lineName, notificationReference: lineReference, stationNames: stationNames, stationSelected: stationDict[stationSelected]!)
                self.saveZone(zone2U: lineName, notificationReference: lineReference, stationNames: stationNames, stationSelected: stationDict[stationSelected]!)
//                self.updateTokenWithID(record: self.tokenReference, link2Save: lineReference, lineOwner: lineName, stationSelected: stationDict[stationSelected]!)
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
    
    public func deleteLine(lineName: String, linePassword: String) {
        // Need to delete SHARE too!!
        //        let recordID2Access = linesDictionary[lineName + linePassword]
        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", lineName)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 305)
            } else {
                if records!.count > 0 {
                    cloudDB.share.publicDB.delete(withRecordID: (records!.first?.recordID)!) { (recordID, error) in
                        if error != nil {
                            self.parseCloudError(errorCode: error as! CKError, lineno: 270)
                        }
//                        print("Record \(recordID) was successfully deleted")
                    }
                    let zone2Zap = CKRecordZone(zoneName: lineName)
                    CKContainer.default().privateCloudDatabase.delete(withRecordZoneID: zone2Zap.zoneID) { (zoneDeleted, error) in
                        if error != nil {
                            self.parseCloudError(errorCode: error as! CKError, lineno: 270)
                        }
                        let defaults = UserDefaults.standard
                        defaults.set(nil, forKey: remoteAttributes.lineName)
                        defaults.set(nil, forKey: remoteAttributes.linePassword)
                        defaults.set(nil, forKey: remoteAttributes.stationNames)
//                        print("Zone \(lineName) was successfully deleted")
                    }
                }
            }
        }
    }
    
//    public func modifyStations(lineName: String, stationName: String) {
//
//    }
    
//    public func readLines() -> [String] {
//        let linesRead:[String]!
//        return linesRead
//    }
    
    var tokenReference: CKRecord.Reference!
    
    public func saveToken(token2Save: String, line2Save: CKRecord.Reference?, station2Save: CKRecord.Reference?, line2U: String?) {
        
        let customRecord = CKRecord(recordType: remoteRecords.devicesLogged)
        customRecord[remoteAttributes.deviceRegistered] = token2Save
        if line2U != nil {
            customRecord[remoteAttributes.lineOwner] = line2U
        } else {
            customRecord[remoteAttributes.lineOwner] = line2U
        }
        //        let rex2D = CKRecordID(recordName: line2Save)
        //        let token2D = CKReference(recordID: rex2D, action: .none)
        if line2Save != nil {
            customRecord[remoteAttributes.lineReference] = line2Save
        }
        if station2Save != nil {
            customRecord[remoteAttributes.stationReference] = station2Save
        }
        cloudDB.share.publicDB.save(customRecord, completionHandler: ({returnRecord, error in
            if error != nil {
                print("saveLine error \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 292)
            } else {
                self.tokenReference = CKRecord.Reference(record: customRecord, action: CKRecord_Reference_Action.none)
                tokensRead.append(ownerToken)
            }
        }))
    }
    
    public func updateLineURL(line2U: String?, url2U: String?) {
        if url2U == nil || line2U == nil { return }
        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", line2U!)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 305)
            } else {
                if records!.count > 0 {
                    let customRecord = records!.first
                    // Cannot change the name of a line once created
                    //                  customRecord![remoteAttributes.lineName] = lineName
                    customRecord![remoteAttributes.lineURL] = url2U
                    let operation = CKModifyRecordsOperation(recordsToSave: [customRecord!], recordIDsToDelete: nil)
                    operation.savePolicy = .allKeys
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            print("modify error\(error!.localizedDescription)")
                            self.parseCloudError(errorCode: error as! CKError, lineno: 316)
                        } else {
                            //                        print("record Updated \(savedRecords)")
                        }
                    }
                    CKContainer.default().publicCloudDatabase.add(operation)
                } else {
                    print("URL not updated")
                }
            }
        }
                
    }
    
    public func getLine(lineName: String, linePassword: String) {
        let predicate = NSPredicate(format: "%K = %@",remoteAttributes.lineName,lineName)
//        let predicate2 = NSPredicate(format: "%K = %@",remoteAttributes.linePassword,linePassword)
//        let predicate3 = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 333)
            } else {
                if records?.count == 0 {
                    let peru = Notification.Name(localObservers.newLine)
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                } else {
                    let newReference = CKRecord.Reference(record: records!.first!, action: .none)
                    lineLink = newReference
                    let passwordOnfile = records!.first?.object(forKey: remoteAttributes.linePassword) as! String
                    if passwordOnfile == linePassword {
                        linesRead = [records!.first?.object(forKey: remoteAttributes.lineName) as! String]
//                        stationsRead = records!.first?.object(forKey: remoteAttributes.stationNames) as! [String]
                        let newReference = CKRecord.Reference(record: records!.first!, action: .none)
                        self.returnStationsOnLine(line2Seek: newReference)
//                        let peru = Notification.Name("stationPin")
//                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                        selectedLine = linesRead.first
                        selectedStation = stationsRead.first
                        if records!.first?.object(forKey: remoteAttributes.lineURL) != nil {
                            let pass2U = records!.first?.object(forKey: remoteAttributes.lineURL) as! String
                            let peru2 = Notification.Name("showURL")
                            let dict = [remoteAttributes.lineURL:pass2U]
                            NotificationCenter.default.post(name: peru2, object: nil, userInfo: dict)
                        }
                    } else {
                        let peru = Notification.Name(localObservers.noLineFound)
                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                    }
                }
            }
        }
    }
    
    public func returnLine(lineName: String) {
        let predicate = NSPredicate(format: "%K = %@",remoteAttributes.lineName,lineName)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 333)
            } else {
                if records?.count == 0 {
                    // report error
                } else {
                    let newReference = CKRecord.Reference(record: records!.first!, action: .none)
                    lineLink = newReference
                    self.returnStationsOnLine(line2Seek: newReference)
//                    linesRead = [records!.first?.object(forKey: remoteAttributes.lineName) as! String]
//                    stationsRead = records!.first?.object(forKey: remoteAttributes.stationNames) as! [String]
//                    let peru = Notification.Name("stationPin")
//                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
//                    selectedLine = linesRead.first
//                    selectedStation = stationsRead.first
//                    if records!.first?.object(forKey: remoteAttributes.lineURL) != nil {
//                        let pass2U = records!.first?.object(forKey: remoteAttributes.lineURL) as! String
//                        let peru2 = Notification.Name("showURL")
//                        let dict = [remoteAttributes.lineURL:pass2U]
//                        NotificationCenter.default.post(name: peru2, object: nil, userInfo: dict)
//                    }
                }
            }
        }
    }
    
    
    public func updateLine(lineName: String, stationNames:[String], stationSelected:String, linePassword:String) {
        //        let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", lineName)
        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 362)
            } else {
                if records?.count == 0 {
                    self.saveLine(lineName: lineName, stationNames: stationNames, stationSelected: stationSelected, linePassword: linePassword)
                } else {
                    let customRecord = records!.first
                    customRecord![remoteAttributes.linePassword] = linePassword
//                    customRecord![remoteAttributes.stationNames] = stationNames
                    if url2Share != nil {
                        customRecord![remoteAttributes.lineURL] = url2Share
                    }
                    if records!.first?.object(forKey: remoteAttributes.lineURL) != nil {
                        let pass2U = records!.first?.object(forKey: remoteAttributes.lineURL) as! String
//                        url2ShareDictionary[lineName] = records!.first?.object(forKey: remoteAttributes.lineURL) as? String
                        let peru = Notification.Name("showURL")
                        let dict = [remoteAttributes.lineURL:pass2U]
                        NotificationCenter.default.post(name: peru, object: nil, userInfo: dict)
                    }
                    
                    let operation = CKModifyRecordsOperation(recordsToSave: [customRecord!], recordIDsToDelete: nil)
                    operation.savePolicy = .changedKeys
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            print("modify error\(error) \(error!.localizedDescription)")
                            self.parseCloudError(errorCode: error as! CKError, lineno: 383)
                        } else {
                            print("record Updated \(savedRecords)")
                        }
                    }
                    CKContainer.default().publicCloudDatabase.add(operation)
                    self.updateTokenOwner(line2U: lineName, token2U:ownerToken, recordID:(records!.first?.recordID)!)
                    tokenOwner[lineName] = ownerToken
                }
                
            }
        }
    }
    
//    public func returnAllLines() {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
//        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//                self.parseCloudError(errorCode: error as! CKError, lineno: 403)
//            } else {
//                for record in records! {
//                    linesRead.append(record[remoteAttributes.lineName]!)
//                    linesDictionary[record[remoteAttributes.lineName]! + record[remoteAttributes.linePassword]!] = record.recordID
//                    let point = record[remoteAttributes.lineOwner] as? CKRecord.Reference
//
//                    lineOwner[record[remoteAttributes.lineName]!] = point?.recordID.recordName
//                    if url2ShareDictionary[record[remoteAttributes.lineName]!] != nil {
//                        url2ShareDictionary[record[remoteAttributes.lineName]!] = record[remoteAttributes.lineURL]!
//                    }
//                }
//                let peru = Notification.Name("showPin")
//                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
//
//                if linesRead.count > 0 {
////                    self.returnStationsOnLine(line2Seek: linesRead[0])
//                }
//                //                let peru2 = Notification.Name("refresh")
//                //                NotificationCenter.default.post(name: peru2, object: nil, userInfo: nil)
//            }
//        }
//    }
    
    public func returnStationsOnLine(line2Seek: CKRecord.Reference) {
        let predicate = NSPredicate(format:  "lineReference = %@", line2Seek)
        let query = CKQuery(recordType: remoteRecords.notificationStation, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 443)
            } else {
                if records!.count > 0 {
                    for record in records! {
                        let stationName = record.object(forKey: remoteAttributes.stationName) as? String
                        stationsRead.append(stationName!)
                        var rex = stationRecord()
                        rex.name = stationName!
                        rex.recordRecord = record
                        station2T.append(rex)
                    }
                    let newReference = CKRecord.Reference(record: records!.first!, action: .none)
                    stationLink = newReference
                    let peru = Notification.Name("stationPin")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                    }
                }
            }
    }
    
    public func updateStationsBelongingTo(line2Seek: CKRecord.Reference, stations2D:[stationRecord?], stations2U:[stationRecord?]) {
        let predicate = NSPredicate(format:  "lineReference = %@", line2Seek)
        let query = CKQuery(recordType: remoteRecords.notificationStation, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 443)
            } else {
                if records!.count > 0 {
                    var rex2D:[CKRecord.ID] = []
                    var rex2A:[CKRecord] = []
                    for rex in stations2D {
                        rex2D.append((rex?.recordRecord.recordID)!)
                    }
                    for rex in stations2U {
                        if rex?.recordRecord == nil {
                            let bar = CKRecord(recordType: remoteRecords.notificationStation)
                            bar.setObject(line2Seek, forKey: remoteAttributes.lineReference)
                            bar.setObject(rex?.name as __CKRecordObjCValue?, forKey: remoteAttributes.stationName)
                            rex2A.append(bar)
                            let s2A = stationRecord(name: rex?.name, recordRecord: bar)
                            station2T.append(s2A)
                            stationsRead.append((rex?.name)!)
                        } else {
                            if let foo = records!.first(where: {$0.recordID == rex?.recordRecord.recordID}) {
                                foo.setObject(rex!.name as __CKRecordObjCValue?, forKey: remoteAttributes.stationName)
                                rex2A.append(foo)
                            }
                        }
                    }
                    let operation = CKModifyRecordsOperation(recordsToSave: rex2A, recordIDsToDelete: rex2D)
                    operation.savePolicy = .allKeys
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            print("modify error\(error!.localizedDescription)")
                            self.parseCloudError(errorCode: error as! CKError, lineno: 476)
                        } else {
                            print("record Updated \(savedRecords)")
                            
                        }
                    }
                    CKContainer.default().publicCloudDatabase.add(operation)
                }
            }
        }
    }
    
//    public func returnStationsOnLine(line2Seek: String) {
//
//        let predicate = NSPredicate(format: remoteAttributes.lineName + " = %@", line2Seek)
//        let query = CKQuery(recordType: remoteRecords.notificationLine, predicate: predicate)
//        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//                self.parseCloudError(errorCode: error as! CKError, lineno: 443)
//            } else {
//                if records!.count > 0 {
//                    let stationsFound = records!.first!.object(forKey: remoteAttributes.stationNames)
//                    //                    syntax that crashes !!
//                    //                        let stationsFound = records!.first![remoteAttributes.stationNames]! as? [String]
//                    if (stationsFound as? [String])!.count > 0 {
//                        stationsRead = (stationsFound as? [String])!
//                        let peru = Notification.Name("stationPin")
//                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
//                        stationDictionary[line2Seek] = stationsRead
//                    }
//                    self.returnTokensWithOwner(token2U: ownerToken, line2U: line2Seek)
//                }
//            }
//        }
//    }
    
    public func updateTokenWithID(record: CKRecord.Reference?, link2Save: CKRecord.Reference, lineOwner:String, stationSelected: CKRecord.Reference) {
        if record == nil { return }
        cloudDB.share.publicDB.fetch(withRecordID: (record?.recordID)!) { (returnedRecord, error) in
            if error != nil {
                print("updateTokenerror \(error!.localizedDescription)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 467)
            } else {
                returnedRecord![remoteAttributes.lineReference] = link2Save
                returnedRecord![remoteAttributes.lineOwner] = lineOwner
                returnedRecord![remoteAttributes.stationName] = stationSelected
                let operation = CKModifyRecordsOperation(recordsToSave: [returnedRecord!], recordIDsToDelete: nil)
                operation.savePolicy = .changedKeys
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if error != nil {
                        print("modify error\(error!.localizedDescription)")
                        self.parseCloudError(errorCode: error as! CKError, lineno: 476)
                    } else {
                        print("record Updated \(savedRecords)")
                    }
                }
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
    }
    
    public func returnTokensWithLinks(lineLink: CKRecord.Reference, stationLink: CKRecord.Reference) {
        print("returnTokensWithLinks \(lineLink.recordID) \(stationLink.recordID) ")
        let rightToken = NSPredicate(format: "lineReference = %@", lineLink)
        let rightLine = NSPredicate(format: "stationReference = %@", stationLink)
//        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [rightToken,rightLine])
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [rightToken,rightLine])
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicateCompound)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 494)
                return
            }
            if records!.count > 0 {
                for record in records! {
                let tokenValue = record.object(forKey: remoteAttributes.deviceRegistered) as? String
                    tokensRead.append(tokenValue!)
                }
            }
        }
    }
    
    private func returnTokensWithOwner(token2U: String, line2U: String) {
        let rightToken = NSPredicate(format: "%K = %@", remoteAttributes.deviceRegistered, token2U)
        let rightLine = NSPredicate(format: "%K = %@", remoteAttributes.lineOwner, line2U)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [rightToken, rightLine])
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 494)
                return
            }
            if records!.count > 0 {
                let peru = Notification.Name("enablePost")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            } else {
                let peru = Notification.Name("disablePost")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            }
        }
    }
    
    public func returnTokenWithID(record: CKRecord.Reference?) {
        if record == nil { return }
        cloudDB.share.publicDB.fetch(withRecordID: (record?.recordID)!) { (record, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 512)
            } else {
                let tokenDiscovered = record!.object(forKey: remoteAttributes.deviceRegistered) as? String
                if ownerToken == tokenDiscovered {
                    let peru = Notification.Name("enablePost")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                } else {
                    let peru = Notification.Name("disablePost")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                }
//                self.tokenReference = CKRecord.Reference(record: record!, action: CKRecord_Reference_Action.none)
            }
        }
    }
    
    public func updateTokenOwner(line2U: String, token2U:String, recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: remoteAttributes.deviceRegistered + " = %@", token2U)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (returnedRecords, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 533)
            } else {
                if returnedRecords?.count == 0 {
//                    self.saveToken(token2Save: token2Save, line2Save: lineLink)
                } else {
                    let returnedRecord = returnedRecords!.first
                    returnedRecord![remoteAttributes.lineReference] = CKRecord.Reference(recordID: recordID, action: .none)
                    returnedRecord![remoteAttributes.lineOwner] = line2U as CKRecordValue
                    let operation = CKModifyRecordsOperation(recordsToSave: [returnedRecord!], recordIDsToDelete: nil)
                    operation.savePolicy = .changedKeys
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            print("modify error\(error!.localizedDescription)")
                            self.parseCloudError(errorCode: error as! CKError, lineno: 546)
                        } else {
//                            print("record Updated \(savedRecords)")
                        }
                    }
                    CKContainer.default().publicCloudDatabase.add(operation)
                }
            }
        }
    }
    
    public func logToken(token2Save: String, lineLink: CKRecord.Reference?, stationLink: CKRecord.Reference?, lineName: String?) {
        let predicate = NSPredicate(format: remoteAttributes.deviceRegistered + " = %@", token2Save)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 563)
            } else {
                if records?.count == 0 {
                    self.saveToken(token2Save: token2Save, line2Save: lineLink, station2Save: stationLink, line2U: lineName)
                } else {
                    self.tokenReference = CKRecord.Reference(record: (records?.first!)!, action: CKRecord_Reference_Action.none)
                }
            }
        }
    }
    
    public func deleteToken(token2Delete: String) {
        let predicate = NSPredicate(format: remoteAttributes.deviceRegistered + " = %@", token2Delete)
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 580)
            } else {
                if records!.count > 0 {
                    cloudDB.share.publicDB.delete(withRecordID: (records!.first?.recordID)!) { (recordID, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            self.parseCloudError(errorCode: error as! CKError, lineno: 585)
                            return
                        }
                    }
                    //                    print("Record \(recordID) was successfully deleted")
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
                self.parseCloudError(errorCode: error as! CKError, lineno: 602)
            } else {
                for record in records! {
                    if let asset = record["mediaFile"] as? CKAsset,
                        let data = NSData(contentsOf: asset.fileURL),
                        let image2D = UIImage(data: data as Data) {
                        let peru = Notification.Name("doImage")
                        NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                    }
                }
//                print("tokens read \(tokensRead)")
            }
        }
    }
    
    
    
    public func returnAllTokensWithOutOwners() {
        let predicate = NSPredicate(format: "%K == %@", remoteAttributes.lineOwner, "")
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 624)
            } else {
                for record in records! {
//                      tokensRead.append(record[remoteAttributes.deviceRegistered]!)
//                    tokenOwner[record.recordID.recordName] = record[remoteAttributes.deviceRegistered]!
                    let fix = record.object(forKey: remoteAttributes.lineOwner)! as? String
                    let target = record[remoteAttributes.deviceRegistered]! as? String
                    tokenOwner[fix!] = target
                }
//                print("tokens read \(tokensRead)")
                
                let peru = Notification.Name("devices2Post")
                NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            }
        }
    }
    
    public func returnAllTokensWithOwners() {
        let predicate = NSPredicate(format: "%K != %@", remoteAttributes.lineOwner, "")
        let query = CKQuery(recordType: remoteRecords.devicesLogged, predicate: predicate)
        cloudDB.share.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.parseCloudError(errorCode: error as! CKError, lineno: 648)
            } else {
//                print("returnAllTokensWithOwners \(records!.count)")
                for record in records! {
//                   tokensRead.append(record[remoteAttributes.deviceRegistered]!)
                    if record.object(forKey: remoteAttributes.lineOwner) != nil {
                        let fix = record.object(forKey: remoteAttributes.lineOwner)! as? String
                        let target = record[remoteAttributes.deviceRegistered]! as? String
                        tokenOwner[target!] = fix
                    }
//                    print("tokens read \(tokensRead) ")
                    let peru = Notification.Name("showPin")
                    NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
                }
            }
        }
    }
    
    public func cleanUpImages(zone2U:String) {
        
        var records2Delete:[CKRecord.ID] = []
        let zone2D = CKRecordZone(zoneName: zone2U)
        // -1 to test tomorrow!!
        
        let sevenDaysBefore = Date.changeDaysBy(days: -7) as? NSDate
//        print("sevenDaysBefore \(sevenDaysBefore) \(zone2D)")
        //        let predicate = NSPredicate(format: "creationDate < %@", sevenDaysBefore!)
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: remoteRecords.notificationMedia, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.zoneID = zone2D.zoneID
        
        operation.recordFetchedBlock = { record in
            records2Delete.append(record.recordID)
        }
        operation.queryCompletionBlock = { cursor, error in
            print(records2Delete.count)
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: records2Delete)
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if error != nil {
                    print("modify error\(error!.localizedDescription)")
                    self.parseCloudError(errorCode: error as! CKError, lineno: 690)
                } else {
//                    print("record Updated \(deletedRecordIDs?.count)")
                }
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
        cloudDB.share.privateDB.add(operation)
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
        let peru = Notification.Name(localObservers.showAlert)
        let dict = [localdefault.alertMessage:message]
        NotificationCenter.default.post(name: peru, object: nil, userInfo: dict)
    }
}

extension Date {
    static func changeDaysBy(days : Int) -> Date {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.day = days
        return Calendar.current.date(byAdding: dateComponents, to: currentDate)!
    }
}

extension UIImage {
    func resize(width: CGFloat) -> UIImage {
        let height = (width/self.size.width)*self.size.height
        return self.resize(size: CGSize(width: width, height: height))
    }
    
    func resize(height: CGFloat) -> UIImage {
        let width = (height/self.size.height)*self.size.width
        return self.resize(size: CGSize(width: width, height: height))
    }
    
    func resize(size: CGSize) -> UIImage {
        let widthRatio  = size.width/self.size.width
        let heightRatio = size.height/self.size.height
        var updateSize = size
        if(widthRatio > heightRatio) {
            updateSize = CGSize(width:self.size.width*heightRatio, height:self.size.height*heightRatio)
        } else if heightRatio > widthRatio {
            updateSize = CGSize(width:self.size.width*widthRatio,  height:self.size.height*widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(updateSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: updateSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
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


