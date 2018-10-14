//
//  PostingViewController.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UIKit
import MobileCoreServices
import SafariServices

var testURL = "https://www.dropbox.com/s/ztnaguussrcraxf/Marley.PNG?dl=1"
var photoAttached: Bool = false

class PostingViewController: UIViewController, URLSessionDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var debugThumb: UIImageView!
    @IBAction func debug(_ sender: Any) {
        //rint("media2Share \(media2Share)")
    }
    //    var stationsRegistered:[String] = ["English","French","Italian","German"]
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        //rint("Unwind to Root View Controller")
    }
    
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
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyText: UITextView!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var returnLabel: UIButton!

    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var webButton: UIButton!
    
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var clientsRegistered: UILabel!
    @IBOutlet weak var workingIndicator: UIActivityIndicatorView!
    
    @IBAction func webButton(_ sender: Any) {
        
    }
    
    @IBAction func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func liveButton(_ sender: UIButton) {
        postButton.isEnabled = false
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
        postButton.isEnabled = false
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
        postButton.isEnabled = false
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
    private var pinObserver4: NSObjectProtocol!
    private var pinObserver5: NSObjectProtocol!
    private var pinObserver6: NSObjectProtocol!
    
    @objc func deleteAttachment() {
        if postButton.isEnabled {
            photoAttached = false
            postImage.image = nil
            
        }
    }
    
    var swipeLeft: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsMade = 0
        photoAttached = false
        titleTextField.delegate = self
        bodyText.delegate = self
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(PostingViewController.deleteAttachment))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if selectedLine != nil {
            cloudDB.share.cleanUpImages(zone2U: selectedLine)
        }
        workingIndicator.isHidden = true
//        lineLabel.text = bahninfo
        lineLabel.text = selectedLine
        stationLabel.text = selectedStation
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
            
        }
        let alert2Monitor4 = "showWeb"
        pinObserver4 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor4), object: nil, queue: queue) { (notification) in
            let request2D = notification.userInfo!["http-url"] as? String
            if let url = URL(string: request2D!) {
                let vc = SFSafariViewController(url: url)
                vc.delegate = self
                if self.parent?.presentingViewController == self {
                    self.present(vc, animated: true)
                }
            }
        }
        let alert2Monitor5 = "webSnap"
        pinObserver5 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor5), object: nil, queue: queue) { (notification) in
//            let request2D = notification.userInfo!["http-url"] as? String
            self.postImage.image = webSnap
        }
        let alert2Monitor6 = "thumb"
        pinObserver6 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor6), object: nil, queue: queue) { (notification) in
            //rint("thumb posted")
            self.debugThumb.image = thumbImage
        }
        
        // NOT AN OBSERVER !!
        
        if tokenCheque == nil, lineLink != nil {
//            cloudDB.share.returnAllTokensWithOutOwners()
            cloudDB.share.returnAllTokensWithLinks(lineLink: lineLink, stationLink: stationLink, cursorOp: nil)
            tokenCheque = tokensRead.count
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tokenCheque = nil
        tokensRead.removeAll()
        webSite2Send = nil
        photoAttached = false
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
    var doPost: Bool = false
    
    @IBAction func postAction(_ sender: UIButton) {
        workingIndicator.isHidden = false
        workingIndicator.startAnimating()
        if !timer.isValid {
            devices2Post2 = tokensRead
            scheduledTimerWithTimeInterval()
        }
//        cloudDB.share.cleanUpImages(zone2U: selectedLine)
    }
    
    var postsMade:Int!
    
    func scheduledTimerWithTimeInterval(){
        
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    func jsonString(dictionary: [String:Any]) {
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
            ),
            let theJSONText = String(data: theJSONData,
                                     encoding: String.Encoding.ascii) {
//            //rint("JSON string = \n\(theJSONText)")
        }
    }
    
    @objc func updateCounting(){
        var apnsPayload:[String:Any] = [:]
        var apnsSub:[String:Any] = [:]
        var apnsSubSub:[String:Any] = [:]
        apnsSubSub = ["title":titleTextField.text!,"body":bodyText.text!] as [String : Any]
        apnsSub["alert"] = apnsSubSub as [String : Any]
        if photoAttached {
            apnsSub["category"] = "photo.category"
            apnsSub["mutable-content"] = 1
            if media2Share != nil {
                apnsPayload["image-url"] = media2Share!
            }
        }
        if webSite2Send != nil {
            apnsSub["category"] = "web.category"
            apnsPayload["http-url"] = (webSite2Send?.absoluteString)!
        }
        apnsPayload["line"] = selectedLine
        apnsPayload["station"] = selectedStation
        apnsPayload["aps"] = apnsSub

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
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        
//        var loginRequest = URLRequest(url: URL(string: "https://api.sandbox.push.apple.com/3/device/" + token2U)!)
        var loginRequest = URLRequest(url: URL(string: "https://api.push.apple.com/3/device/" + token2U)!)
        loginRequest.allHTTPHeaderFields = ["apns-topic": "ch.cqd.n2kMemo",
                                            "content-type": "application/x-www-form-urlencoded"
        ]
        loginRequest.httpMethod = "POST"
        let data = try? JSONSerialization.data(withJSONObject: apns2S, options:[])
        if let content = String(data: data!, encoding: String.Encoding.utf8) {
            // here `content` is the JSON dictionary containing the String
        }
        loginRequest.httpBody = data
        let loginTask = session.dataTask(with: loginRequest) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == 410 {
                cloudDB.share.deleteToken(token2Delete: token2U)
            }
/*
             APNS reponse codes https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html
            200 Success
            400 Bad request
            403 There was an error with the certificate or with the provider authentication token
            405 The request used a bad :method value. Only POST requests are supported.
            410 The device token is no longer active for the topic.
            413 The notification payload was too large.
            429 The server received too many requests for the same device token.
            500 Internal server error
            503 The server is shutting down and unavailable.
 */
        }
        loginTask.resume()
    }
    
    
    
}
