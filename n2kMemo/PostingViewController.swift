//
//  PostingViewController.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UIKit
import MobileCoreServices

var testURL = "https://www.dropbox.com/s/ztnaguussrcraxf/Marley.PNG?dl=1"

class PostingViewController: UIViewController, URLSessionDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    //    var stationsRegistered:[String] = ["English","French","Italian","German"]
    
    var bahninfo: String!
    var hofString: String!
    var hofinfo: Int!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextField.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
        bodyText.resignFirstResponder()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stationsRead.count
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        return stationsRegistered[row]
    //    }
    
    var rowSelected:Int?
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBoldItalic", size: 20)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = stationsRead[row]
        
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
        pickerView.reloadAllComponents()
    }
    
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyText: UITextView!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var returnLabel: UIButton!
    @IBOutlet weak var pickerStations: UIPickerView!
    @IBOutlet weak var clientLabel: UILabel!
    
    @IBAction func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func liveButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: {
            //            let prox2U = self.manProx != nil ? self.manProx : self.lastProximity
            //           self.setWayPoint.didSetProximity(name: self.nameTextField.text, proximity: prox2U)
        })
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = (info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage) {
//            DispatchQueue.main.async {
//
//            }
//        }
//        picker.presentingViewController?.dismiss(animated: true, completion: {
//      
//        })
//    }
    
    @IBAction func libraryButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func dropNdragButton(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeImage as NSString) as String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: false, completion: {
            //done
        })
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                //
                //                self.setWayPoint.didSetImage(name: self.nameTextField.text!, image: UIImage(data: data))
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    var tokenCheque: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyText.delegate = self
        if tokenCheque == nil {
            cloudDB.share.returnAllTokens()
            tokenCheque = tokensRead.count
            if hofinfo != nil {
                self.pickerStations.selectRow(hofinfo, inComponent: 0, animated: true)
                rowSelected = hofinfo
                hofString = stationsRead[hofinfo]
            }
        }
        clientLabel.text = "\(tokensRead.count)"
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        lineLabel.text = bahninfo
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBOutlet weak var dropNdragButton: UIButton!
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var items: CFArray?
        
        let urlPath = Bundle.main.bundleURL.appendingPathComponent("Cert.p12")
        let contentOf = try? Data(contentsOf:urlPath)
        
        let certOptions:NSDictionary = [kSecImportExportPassphrase as NSString:"0244941651" as NSString]
        SecPKCS12Import(contentOf! as NSData, certOptions, &items)
        let certItems:Array = (items! as Array)
        let dict:Dictionary<String, AnyObject> = certItems.first! as! Dictionary<String, AnyObject>
        
        let label = dict[kSecImportItemLabel as String] as? String
        let keyID = dict[kSecImportItemKeyID as String] as? Data
        let trust = dict[kSecImportItemTrust as String] as! SecTrust?
        let certChain = dict[kSecImportItemCertChain as String] as? Array<SecTrust>
        let identity = dict[kSecImportItemIdentity as String] as! SecIdentity?
        
        let credentials = URLCredential(identity: identity!, certificates: certChain, persistence: .forSession)
        completionHandler(.useCredential,credentials)
    }
    
    var timer = Timer()
    var devices2Post2:[String] = []
    
    @IBAction func postAction(_ sender: UIButton) {
        if !timer.isValid {
            devices2Post2 = tokensRead
            scheduledTimerWithTimeInterval()
        }
    }
    
    var postsMade = 0
    
    func scheduledTimerWithTimeInterval(){
        
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        let apnsSubSub = ["title":titleTextField.text,"body":bodyText.text]
        let apnsSub = ["alert":apnsSubSub,"category":"pizza.category","mutable-content":1] as [String : Any]
        let apnsPayload = ["aps":apnsSub,"line":bahninfo,"station":hofString,"image-url":testURL] as [String : Any]
        if devices2Post2.count > 0 {
            buildPost(token2U: devices2Post2.removeLast(), apns2S: apnsPayload)
            clientLabel.text = "\(postsMade)"
            postsMade += 1
        } else {
            timer.invalidate()
        }
    }
    
    func buildPost(token2U: String, apns2S: Any) {
        print("tokenPosted \(token2U)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        
        var loginRequest = URLRequest(url: URL(string: "https://api.sandbox.push.apple.com/3/device/" + token2U)!)
        loginRequest.allHTTPHeaderFields = ["apns-topic": "ch.cqd.PushHuliPizza",
                                            "content-type": "application/x-www-form-urlencoded"
        ]
        loginRequest.httpMethod = "POST"
        let data = try? JSONSerialization.data(withJSONObject: apns2S, options:[])
        if let content = String(data: data!, encoding: String.Encoding.utf8) {
            // here `content` is the JSON dictionary containing the String
            print(content)
        }
        loginRequest.httpBody = data
        print("apnsPayLoad \(data)")
        let loginTask = session.dataTask(with: loginRequest) { data, response, error in
            print("error \(error) \(response)")
        }
        loginTask.resume()
    }
    
    
    
}
