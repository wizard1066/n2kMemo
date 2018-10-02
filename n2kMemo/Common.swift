//
//  Common.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

var permission2SendNotifications: Bool = false

enum segueNames {
    static let posting = "posting"
    static let principle = "principle"
    static let configuration = "configuration"
}

enum remoteRecords {
    static let notificationLine = "notificationLine"
    static let devicesLogged = "devicesLogged"
    static let notificationShare = "notificationShare"
    static let notificationMedia = "notificationMedia"
}

enum remoteAttributes {
    static let stationNames = "stationNames"
    static let linePassword = "linePassword"
    static let lineName = "lineName"
    static let lineOwner = "lineOwner"
    //    static let tokenReference = "tokenreference"
    static let deviceRegistered = "deviceRegistered"
    static let mediaFile = "mediaFile"
    static let notificationsregistered = "notificationsregistered"
    static let lineRecordID = "lineRecordID"
    static let lineReference = "lineReference"
    static let zoneID = "zoneID"
    static let lineURL = "lineURL"
}

var ownerToken: String!
var tokensRead:[String] = []
var linesRead:[String] = []
var stationsRead:[String] = []
var linesGood2Go: Bool = false

var linesDictionary:[String:CKRecord.ID] = [:]
var controller:UICloudSharingController!
var url2Share: String?
var image2D: UIImage!
var lineZoneID: String!

var stationDictionary:[String:[String]?] = [:]
var lineOwner:[String: String] = [:]
var tokenOwner:[String: String?] = [:]

var selectedLine: String!
var selectedStation: String!
var url2ShareDictionary:[String:String] = [:]
var webSite2Send: URL?
var urlSeek: URL?
