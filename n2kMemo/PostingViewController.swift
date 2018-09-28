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
var photoAttached: Bool = false

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
        selectedStation = stationsRead[row]
        pickerView.reloadAllComponents()
    }
    
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyText: UITextView!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var returnLabel: UIButton!
    @IBOutlet weak var pickerStations: UIPickerView!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var clientsRegistered: UILabel!
    @IBOutlet weak var workingIndicator: UIActivityIndicatorView!
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageEditedInfo = UIImagePickerController.InfoKey.editedImage
        let imageOriginalInfo = UIImagePickerController.InfoKey.originalImage
        if let image = (info[imageEditedInfo] as? UIImage ?? info[imageOriginalInfo] as? UIImage) {
            DispatchQueue.main.async {
                photoAttached = true
                self.postButton.isEnabled = false
                cloudDB.share.saveImage2Share(image2Save: image)
                self.postImage.image = image
            }
        }
        picker.presentingViewController?.dismiss(animated: true, completion: {
      
        })
    }
    
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
                if let file2Save = UIImage(data: data) {
                    photoAttached = true
                    self.postButton.isEnabled = false
                    cloudDB.share.saveImage2Share(image2Save: file2Save)
                    self.postImage.image = UIImage(data: data)
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    var tokenCheque: Int?
    private var pinObserver: NSObjectProtocol!
    private var pinObserver2: NSObjectProtocol!
    private var pinObserver3: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsMade = 0
        
        
        photoAttached = false
        titleTextField.delegate = self
        bodyText.delegate = self
        
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        workingIndicator.isHidden = true
//        lineLabel.text = bahninfo
        lineLabel.text = selectedLine
        self.hideKeyboardWhenTappedAround()
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = "disablePost"
        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
            self.postButton.isEnabled = false
        }
        let alert2Monitor2 = "enablePost"
        pinObserver2 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor2), object: nil, queue: queue) { (notification) in
            self.postButton.isEnabled = true
        }
        let alert2Monitor3 = "devices2Post"
        pinObserver3 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor3), object: nil, queue: queue) { (notification) in
//            self.clientLabel.text = "\(tokensRead.count)"
            self.clientsRegistered.text = "\(tokensRead.count)"
            print("ETF \(tokensRead.count) \(tokensRead)")
        }
        if tokenCheque == nil {
            cloudDB.share.returnAllTokensWithOutOwners()
            tokenCheque = tokensRead.count
            if hofinfo != nil {
                self.pickerStations.selectRow(hofinfo, inComponent: 0, animated: true)
                rowSelected = hofinfo
                selectedStation = stationsRead[hofinfo]
            }
        }
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
    }
    
    @IBOutlet weak var dropNdragButton: UIButton!
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var items: CFArray?
        
        let urlPath = Bundle.main.bundleURL.appendingPathComponent("Certificates.p12")
        let contentOf = try? Data(contentsOf:urlPath)
        
        let certOptions:NSDictionary = [kSecImportExportPassphrase as NSString:"0244941651" as NSString]
        SecPKCS12Import(contentOf! as NSData, certOptions, &items)
        let certItems:Array = (items! as Array)
        let dict:Dictionary<String, AnyObject> = certItems.first! as! Dictionary<String, AnyObject>
        
//        let label = dict[kSecImportItemLabel as String] as? String
//        let keyID = dict[kSecImportItemKeyID as String] as? Data
//        let trust = dict[kSecImportItemTrust as String] as! SecTrust?
        let certChain = dict[kSecImportItemCertChain as String] as? Array<SecTrust>
        let identity = dict[kSecImportItemIdentity as String] as! SecIdentity?
        
        let credentials = URLCredential(identity: identity!, certificates: certChain, persistence: .forSession)
        completionHandler(.useCredential,credentials)
    }
    
    var timer = Timer()
    var devices2Post2:[String] = []
    
    @IBAction func postAction(_ sender: UIButton) {
        workingIndicator.isHidden = false
        workingIndicator.startAnimating()
        if !timer.isValid {
            devices2Post2 = tokensRead
            scheduledTimerWithTimeInterval()
        }
    }
    
    var postsMade:Int!
    
    func scheduledTimerWithTimeInterval(){
        
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        var apnsPayload:[String:Any]!
        if photoAttached {
            let apnsSubSub = ["title":titleTextField.text,"body":bodyText.text]
            let apnsSub = ["alert":apnsSubSub,"category":"photo.category","mutable-content":1] as [String : Any]
            apnsPayload = ["aps":apnsSub,"line":selectedLine,"station":selectedStation,"image-url":url2Share!] as [String : Any]
        } else {
            let apnsSubSub = ["title":titleTextField.text,"body":bodyText.text]
            let apnsSub = ["alert":apnsSubSub] as [String : Any]
            apnsPayload = ["aps":apnsSub,"line":selectedLine,"station":selectedStation] as [String : Any]
        }
//        let apnsPayload = ["aps":apnsSub]
        if devices2Post2.count > 0 {
            buildPost(token2U: devices2Post2.removeLast(), apns2S: apnsPayload)
            postsMade += 1
            clientLabel.text = "\(postsMade!)"
        } else {
            timer.invalidate()
            workingIndicator.stopAnimating()
            workingIndicator.isHidden = true
        }
    }
    
    func buildPost(token2U: String, apns2S: Any) {
        print("tokenPosted \(token2U)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        
        var loginRequest = URLRequest(url: URL(string: "https://api.sandbox.push.apple.com/3/device/" + token2U)!)
        loginRequest.allHTTPHeaderFields = ["apns-topic": "ch.cqd.n2kMemo",
                                            "content-type": "application/x-www-form-urlencoded"
        ]
        loginRequest.httpMethod = "POST"
        let data = try? JSONSerialization.data(withJSONObject: apns2S, options:[])
        if let content = String(data: data!, encoding: String.Encoding.utf8) {
            // here `content` is the JSON dictionary containing the String
            print(content)
        }
        loginRequest.httpBody = data
        print("apnsPayLoad URL \(url2Share)")
        let loginTask = session.dataTask(with: loginRequest) { data, response, error in
            print("error \(error) \(response)")
        }
        loginTask.resume()
    }
    
    
    
}
