//
//  ViewController.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UIKit
import SafariServices
import CloudKit

class ViewController: UIViewController, SFSafariViewControllerDelegate, UITextFieldDelegate, URLSessionDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var stationsPicker: UIPickerView!
    @IBOutlet weak var linesPicker: UIPickerView!
    @IBOutlet weak var postingButton: UIButton!
    @IBOutlet weak var configButton: UIButton!
    

    
    //    var stationsRegistered:[String] = ["English","French","Italian","German"]
    
    //    var channel4K: String?
    //    var channel4Pass: String?
    //    var channel4URL: String?
    //    var tokens:[String] = ["5effd4dfc158d922c877c1e3c99fd46296e2c1afcd080a63a2da397bce1c9bb3","f6e9345c225f508089e08a0de2480ab4cdafdebbabc8f1034f597570bc10c095"]
    
    
    
    
    
    
    //    @IBAction func showChannelWebVC(_ sender: Any) {
    //        channel4K = String(channel.text!).trimmingCharacters(in: .whitespacesAndNewlines)
    //        if channel4K != "" {
    //            appDelegate.tagZet.insert(channel4K!)
    //            let urlString = returnURLgivenKey(key2search: channel4K!, typeOf: ".URL")
    //            if urlString == nil {
    ////                channelURL.isHidden = false
    ////                channelPass.isHidden = false
    ////                doURLnPassAnimation()
    ////                channelURL.becomeFirstResponder()
    //            } else {
    //                doSafariVC(url2U: urlString!)
    //
    //            }
    //        }
    //    }
    
    //    @IBAction func doChannelURL(_ sender: Any) {
    //        channel4URL = String(channelURL.text!).trimmingCharacters(in: .whitespacesAndNewlines)
    //        if channel4URL != "" {
    ////            channelPass.becomeFirstResponder()
    //        }
    //    }
    
    //    @IBAction func doPass(_ sender: Any) {
    //        channel4Pass = String(channelPass.text!).trimmingCharacters(in: .whitespacesAndNewlines)
    //        if channel4Pass! == "" || channel4URL! == "" {
    //            showRules()
    //            return
    //        }
    //        let newUUID = UUID().uuidString
    //        channelUUID.text = newUUID
    //        doUUIDAnimation()
    //        storeURLgivenKey(key2Store: channel4K!, URL2Store: channel4URL!, pass2U: channel4Pass!)
    //        doSafariVC(url2U: channel4URL!)
    //    }
    
    
    
    //    func badURL() {
    //        let alert = UIAlertController(title: "Bad URL?", message: "Sorry, unable to open that URL \(channel4URL)", preferredStyle: .alert)
    //        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    //        self.present(alert, animated: true)
    //    }
    
    var lineName: String!
    var pickerAuto: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        channelURL.isHidden = true
        //        channelPass.isHidden = true
        //        channelUUID.alpha = 0.0
        
        
        // Do any additional setup after loading the view, typically from a nib.
        //        if !icloudStatus()! {
        //            // warn user needs cloudKit
        //        }
        let defaults = UserDefaults.standard
        lineName = defaults.string(forKey: remoteAttributes.lineName)
        let linePass = defaults.string(forKey: remoteAttributes.linePassword)
        //        stationsRegistered = (defaults.array(forKey: remoteRecords.stationNames) as? [String])!
        
        cloudDB.share.returnAllLines()
        postingButton.isEnabled = true
        linesPicker.delegate = self
        linesPicker.dataSource = self
        stationsPicker.delegate = self
        stationsPicker.dataSource = self
        cloudDB.share.returnAllTokensWithOwners()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return stationsRead.count
        } else {
            return linesRead.count
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        if pickerView.tag == 1 {
    //            return stationsRegistered[row]
    //        } else {
    //            return "knowitall"
    //        }
    //    }
    
    var rowSelected:Int?
    var lineSelected: String?
    var stationSelected: Int?
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBoldItalic", size: 20)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        if pickerView.tag == 1 {
            if row < stationsRead.count {
                pickerLabel?.text = stationsRead[row]
                selectedStation = pickerLabel?.text
            }
        } else {
            
            pickerLabel?.text = linesRead[row]
            selectedLine = pickerLabel?.text
        }
        
        if row == rowSelected {
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        } else {
            pickerLabel?.textColor = UIColor.black
            pickerLabel?.backgroundColor = UIColor.clear
            
        }
        
        return pickerLabel!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rowSelected = row
        pickerAuto = false
        pickerView.reloadAllComponents()
        if pickerView.tag == 0 {
            if linesRead.count > 0 && row < linesRead.count {
                    postingOK(lineName: linesRead[row])
                    cloudDB.share.returnStationsOnLine(line2Seek: linesRead[row])
//                    selectedLine = linesRead[row]
            }
        } else {
            if stationsRead.count > 0 && row < stationsRead.count {
                stationSelected = row
//                selectedStation = stationsRead[row]
            }
        }
    }
    
    func postingOK(lineName:String) {
        if ownerToken == tokenOwner[lineName] {
            let peru = Notification.Name("enablePost")
            NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
            } else {
            let peru = Notification.Name("disablePost")
            NotificationCenter.default.post(name: peru, object: nil, userInfo: nil)
        }
    }
    
    private var pinObserver: NSObjectProtocol!
    private var pinObserver2: NSObjectProtocol!
    private var pinObserver3: NSObjectProtocol!
    private var pinObserver4: NSObjectProtocol!
    private var pinObserver5: NSObjectProtocol!
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        doAnimation()
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = "showPin"
        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
            if self.linesPicker != nil {
                self.linesPicker.selectRow(0, inComponent: 0, animated: true)
                self.linesPicker.reloadAllComponents()
            }
        }
        let alert2Monitor2 = "stationPin"
        pinObserver2 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor2), object: nil, queue: queue) { (notification) in
            if self.stationsPicker != nil {
                self.stationsPicker.selectRow(0, inComponent: 0, animated: true)
                self.stationsPicker.reloadAllComponents()
            }
        }
        let alert2Monitor3 = "enablePost"
        pinObserver3 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor3), object: nil, queue: queue) { (notification) in
            self.postingButton.isEnabled = true
        }
        let alert2Monitor4 = "disablePost"
        pinObserver4 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor4), object: nil, queue: queue) { (notification) in
            // fix bug later
            self.postingButton.isEnabled = false
        }
        let alert2Monitor5 = "refresh"
        pinObserver5 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor4), object: nil, queue: queue) { (notification) in
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        }
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.showPosting))
//        swipeLeft.direction = .left
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.showConfig))
//        swipeRight.direction = .right
//        self.view.addGestureRecognizer(swipeLeft)
//        self.view.addGestureRecognizer(swipeRight)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if self.pickerAuto {
                self.linesPicker.selectRow(0, inComponent: 0, animated: true)
                self.pickerView(self.linesPicker, didSelectRow:0, inComponent: 0)
                self.stationsPicker.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    
    @objc func showPosting() {
        //        if segue.identifier == segueNames.posting {
        //            let pVC = destination as? PostingViewController
        //            pVC?.bahninfo = lineSelected
        //            pVC?.hofinfo = stationSelected
        //            print("posting \(lineSelected) \(stationSelected)")
        //        }
        //        let destination = segue.destination.contents
        //        let pVC = destination as? PostingViewController
        //        self.navigationController?.pushViewController(pVC, animated: true)
        //        performSegue(withIdentifier: segueNames.posting, sender: self)
    }
    
    @objc func showConfig() {
        //        let destination = segue.destination.contents
        //        let pVC = destination as? ConfigViewController
        //        self.navigationController?.pushViewController(pVC, animated: true)
        //
        //        if segue.identifier == segueNames.configuration {
        //            let pVC = destination as? ConfigViewController
        //            print("config")
        //        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let center = NotificationCenter.default
        if pinObserver != nil {
            center.removeObserver(pinObserver)
        }
        if pinObserver2 != nil {
            center.removeObserver(pinObserver2)
        }
        if pinObserver3 != nil {
            center.removeObserver(pinObserver3)
        }
        if pinObserver4 != nil {
            center.removeObserver(pinObserver4)
        }
        if pinObserver5 != nil {
            center.removeObserver(pinObserver5)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        if segue.identifier == segueNames.posting {
            let pVC = destination as? PostingViewController
//            pVC?.bahninfo = selectedLine
//            pVC?.hofinfo = selectedStation
//            print("posting \(lineSelected) \(stationSelected)")
        }
        if segue.identifier == segueNames.configuration {
            let pVC = destination as? ConfigViewController
            print("config")
            stationDictionary = [:]
        }
    }
}




extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
