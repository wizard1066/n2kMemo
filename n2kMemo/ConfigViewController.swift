//
//  ConfigViewController.swift
//  n2kMemo
//
//  Created by localadmin on 27.09.18.
//  Copyright © 2018 ch.cqd.n2kMemo. All rights reserved.
//

import UIKit
import CloudKit

class ConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var workingIndicator: UIActivityIndicatorView!
    @IBAction func return2Landing(_ sender: Any) {
        if lineLink != nil {
            cloudDB.share.updateStationsBelongingTo(lineName: selectedLine, line2Seek: lineLink, stations2D: station2D, stations2U: station2T)
        }
    }
    
    @IBAction func Debug(_ sender: Any) {
        //rint("exit \(station2T)\n\n \(station2D)")
        for station in stationsRead {
            //rint("stationsRead \(station)")
        }
        for station in stationsRegistered {
            //rint("stationsRegistered \(station)")
        }
        for station in station2T {
            //rint("station2T \(station?.name) ")
        }
        for station in station2D {
            //rint("station2D \(station?.name) ")
        }
    }
    
//    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var stationsTable: UITableView!
    @IBOutlet weak var stationName: UITextField!
    
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var lineText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var stationText: UITextField!
    
    
    @IBOutlet weak var zeroURL: UILabel!
    @IBOutlet weak var dropZone: UILabel!
    
    
//    @IBAction func returnAction(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
    
//    @IBAction func fetch(_ sender: Any) {
//        //        cloudDB.share.fetchPublicInZone(zone2Search: linesRead[0])
////        cloudDB.share.saveImage2Share()
//    }
    
//    @IBOutlet weak var getText: UITextField!
    
//    @IBAction func get(_ sender: Any) {
//        cloudDB.share.accessShare(URL2D: getText.text!)
//    }
    @IBOutlet weak var imageFetched: UIImageView!
    
//    @IBAction func registerButton(_ sender: UIButton) {
//        registerButton.isEnabled = false
//        selectedLine = newText
//
//        let defaults = UserDefaults.standard

////        if stationsRegistered.count > 0 {
////            selectedStation = stationsRegistered[0]
////        }
//        cloudDB.share.updateLine(lineName: newText, stationNames: stationsRegistered, stationSelected: stationsRegistered[0], linePassword: newPass)
//
////        linesRead.append(selectedLine)
////        stationsRead.append(selectedStation)
//
//    }
    
 
    
    func confirmRegistration() {
        let defaults = UserDefaults.standard
        defaults.set(selectedStation, forKey: remoteAttributes.stationName)
        defaults.set(selectedLine, forKey: remoteAttributes.lineName)
        let alert = UIAlertController(title: "Line registered", message: "Your new line is registered", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
//        registerButton.isEnabled = true
//        linesRead.append(selectedLine)
//        stationsRead.append(selectedStation)
    }
    
    // MARK: textfield delegate
    
    var newText: String!
    var newPass: String!
    var newStation: String!
    var bon: Bool!
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = verifyFields(textField: textField)
    }
    
    @IBAction func killLine(_ sender: UITextField) {
        if verifyFields(textField: sender) {
            deleteLine()
        }
    }
    
    func verifyFields(textField:UITextField) -> Bool {
        bon = false
        if textField.placeholder == "Password", lineText.text == "" {
            // no lineName do nothing
            return false
        }
        if textField.placeholder == "Line", passText.text == "" {
            // do password do nothing
            return false
        }
        if stationsRegistered.count == 0 {
            if textField.placeholder == "Station", stationText.text == "" {
                return false
            }
        }
        // no blanc spaces
        if textField.text == "" {
            return false
        }
        if lineText.text!.count < 3 || passText.text!.count < 3 || stationText.text!.count < 3 {
            let alert = UIAlertController(title: "Alert", message: "All fields MUST be completed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        
        newText = String(lineText.text!).trimmingCharacters(in: .whitespacesAndNewlines)
        newPass = String(passText.text!).trimmingCharacters(in: .whitespacesAndNewlines)
        newStation = String(stationText.text!).trimmingCharacters(in: .whitespacesAndNewlines)
        
//        registerButton.isEnabled = true
        
        // do a newlinw based on a second search just for the name
        workingIndicator.isHidden = false
        workingIndicator.startAnimating()
        cloudDB.share.getLine(lineName: newText, linePassword: newPass, stationName: newStation)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    // MARK: tableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationsRegistered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = stationsRegistered[indexPath.row]
        cell.textLabel?.font = UIFont(name: fontToUse, size: 20)
        cell.textLabel?.textAlignment = NSTextAlignment.center
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.stationsTable.cellForRow(at: indexPath)?.textLabel?.text
            })
            alert.addAction(UIAlertAction(title: "Insert", style: .default, handler: { (updateAction) in
                self.stationsRegistered.insert("", at: indexPath.row)
                var nRex = stationRecord()
                station2T.insert(nRex, at: indexPath.row)
                self.stationsTable.insertRows(at: [indexPath], with: .fade)
                self.addNewStation(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
    
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            if self.stationsRegistered.count > 1 {
                changed = true
                if let foo = station2T.first(where: {$0!.name == self.stationsRegistered[indexPath.row]}) {
                    station2D.append(foo!)
                    station2T.remove(at: indexPath.row)
                }
                self.stationsRegistered.remove(at: indexPath.row)
                //rint("Do that iCloud update")
            }
            tableView.reloadData()
        })
        
        return [deleteAction, editAction]
    }
    
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        //rint("didHighlightRowAt")
//        selectedStation = self.stationsTable.cellForRow(at: indexPath)?.textLabel?.text
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //rint("didSelectRowAt")
        selectedStation = self.stationsTable.cellForRow(at: indexPath)?.textLabel?.text
        if let foo = station2T.first(where: {$0!.name == selectedStation}) {
            if foo?.recordRecord != nil {
                let newReference = CKRecord.Reference(record: (foo?.recordRecord)!, action: .none)
                stationLink = newReference
                if foo?.shareLink != nil, foo?.shareLink != "" {
                    zeroURL.text = foo?.shareLink
                } else {
                    zeroURL.text = "Refresh required, return to landing view and come back"
                }
            } else {
                zeroURL.text = "Refresh required, return to landing view and come back"
            }
        }
    }
    
    func addNewStation(indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = self.stationsTable.cellForRow(at: indexPath)?.textLabel?.text
        })
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
            changed = true
            self.stationsTable.cellForRow(at: indexPath)?.textLabel?.text = alert.textFields!.first!.text!
            self.stationsRegistered[indexPath.row] = alert.textFields!.first!.text!
            station2T[indexPath.row]?.name = alert.textFields!.first!.text!
            self.stationsTable.reloadRows(at: [indexPath], with: .fade)
            //rint("Do that iCloud update")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Insert", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.stationsRegistered.insert("", at: indexPath.row)
                var nRex = stationRecord()
                station2T.insert(nRex, at: indexPath.row)
                self.stationsTable.insertRows(at: [indexPath], with: .fade)
                self.addNewStation(indexPath: indexPath)
            
            success(true)
        })
        closeAction.image = UIImage(named: "tick")
        closeAction.backgroundColor = .purple
        
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if self.stationsRegistered.count > 1 {
                changed = true
                if let foo = station2T.first(where: {$0!.name == self.stationsRegistered[indexPath.row]}) {
                    station2D.append(foo!)
                    station2T.remove(at: indexPath.row)
                }
                self.stationsRegistered.remove(at: indexPath.row)
                //rint("Do that iCloud update")
                tableView.reloadData()
            }
            success(true)
        })
        modifyAction.image = UIImage(named: "hammer")
        modifyAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        //rint("selected \(indexPath)")
    }
    
    // MARK: View methods
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stationsRegistered:[String] = []
    
    private func deleteLine() {
        let alert = UIAlertController(title: "", message: "Delete Line Item", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (updateAction) in
            cloudDB.share.deleteLine(lineName:self.newText,linePassword: self.newPass)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        station2T.removeAll()
        station2D.removeAll()
        stationsRead.removeAll()
        linesRead.removeAll()
//        registerButton.isEnabled = false
        
        stationsTable.rowHeight = 32
        lineText.delegate = self
        passText.delegate = self
        changed = false
        workingIndicator.isHidden = true
        let defaults = UserDefaults.standard
        if line2P != nil {
            lineText.placeholder = line2P
        }
        if station2P != nil {
            stationText.placeholder = station2P
        }
    }
    
    private var pinObserver: NSObjectProtocol!
    private var pinObserver2: NSObjectProtocol!
    private var pinObserver3: NSObjectProtocol!
    private var pinObserver4: NSObjectProtocol!
    private var pinObserver5: NSObjectProtocol!
    private var pinObserver6: NSObjectProtocol!
    private var pinObserver7: NSObjectProtocol!
    private var pinObserver8: NSObjectProtocol!
    private var pinObserver9: NSObjectProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = "confirmPin"
        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
            self.confirmRegistration()
        }
        let alert2Monitor2 = "stationPin"
        pinObserver2 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor2), object: nil, queue: queue) { (notification) in
            self.stationsRegistered = stationsRead
            self.stationsTable.reloadData()
        }
        let alert2Monitor5 = "sharePin"
        pinObserver5 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor5), object: nil, queue: queue) { (notification) in
            if url2Share != nil {
                self.zeroURL.text = url2Share!
            }
            self.workingIndicator.stopAnimating()
            self.workingIndicator.isHidden = true
        }
        let alert2Monitor4 = "doImage"
        pinObserver4 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor4), object: nil, queue: queue) { (notification) in
            self.imageFetched.image = image2D
        }
        let alert2Monitor6 = "showURL"
        pinObserver6 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor6), object: nil, queue: queue) { (notification) in
            let request2D = notification.userInfo![remoteAttributes.lineURL] as? String
            self.zeroURL.text = request2D
//            self.registerButton.isEnabled = true
            self.workingIndicator.stopAnimating()
            self.workingIndicator.isHidden = true
        }
        let alert2Monitor7 = localObservers.noLineFound
        pinObserver7 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor7), object: nil, queue: queue) { (notification) in
            let message2D = "No Line or Password wrong ..."
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"Attention", message:message2D, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.passText.text = ""
                self.lineText.text = ""
                self.workingIndicator.stopAnimating()
                self.workingIndicator.isHidden = true
            }
            
        }
        let alert2Monitor8 = localObservers.newLine
        pinObserver8 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor8), object: nil, queue: queue) { (notification) in
            let message2D = "No line found, do you want to create a new one"
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"Wait ...", message:message2D, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    self.passText.text = ""
                    self.lineText.text = ""
                    self.stationText.text = ""
                    self.workingIndicator.stopAnimating()
                    self.workingIndicator.isHidden = true
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                    registerButton.isEnabled = false
                    selectedLine = self.newText
                    selectedStation = self.newStation
                    
                    if let _ = self.stationsRegistered.first(where: {$0 == selectedStation}) {
                        // do nothing it is already in the array
                    } else {
                        self.stationsRegistered.append(selectedStation)
                    }
                    
//                    if self.stationsRegistered.count > 0 {
//                        selectedStation = self.stationsRegistered[0]
//                    }
                    
                    cloudDB.share.updateLine(lineName: self.newText, stationNames: self.stationsRegistered, stationSelected: self.stationsRegistered[0], linePassword: self.newPass)
                    
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        let alert2Monitor9 = localObservers.clearFields
        pinObserver4 = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor9), object: nil, queue: queue) { (notification) in
            self.passText.text = ""
            self.lineText.text = ""
            self.stationText.text = ""
            self.stationsRegistered.removeAll()
            self.stationsTable.reloadData()
            station2T.removeAll()
            station2D.removeAll()
            selectedLine = ""
            selectedStation = ""
            stationsRead.removeAll()
            linesRead.removeAll()
            self.zeroURL.text = ""
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConfigViewController.keyboardWillShow(_:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConfigViewController.keyboardWillHide(_:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(copyURL))
        view.addGestureRecognizer(press)
        
        self.hideKeyboardWhenTappedAround()
//        self.confirmTableUpdated()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // keyboard on screen
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        // keyboard off screen
//        _ = verifyFields(textField: lineText)
//        _ = verifyFields(textField: passText)
    }
    
    @objc func copyURL() {
        UIPasteboard.general.string = self.zeroURL.text
        
        zeroURL.alpha = 0
        UIView.animate(withDuration: 0.75, delay: 0.25, options: [.curveEaseOut], animations: {
            self.zeroURL.alpha = 1.0
        }) { (status) in
            // do nothing
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
        if pinObserver4 != nil {
            center.removeObserver(pinObserver4)
        }
        if pinObserver5 != nil {
            center.removeObserver(pinObserver5)
        }
        if pinObserver6 != nil {
            center.removeObserver(pinObserver6)
        }
        if pinObserver7 != nil {
            center.removeObserver(pinObserver7)
        }
        if pinObserver8 != nil {
            center.removeObserver(pinObserver8)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)?)
//    {
//        super.dismiss(animated: flag, completion:completion)
////        let destination = parent!.contents
////        let pVC = destination as? ViewController
////        pVC?.lineName = selectedLine
////        pVC?.stationName = selectedStation
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents

            let pVC = destination as? ViewController
//            pVC?.theLine.text = selectedLine
//            pVC?.theStation.text = selectedStation
//            if selectedLine != nil {
//                linesRead.append(selectedLine)
//                if selectedStation != nil {
//                    stationsRead.append(selectedStation)
//                } else {
//                    stationsRead.append(stationsRegistered[0])
//                }
//            }
    }
    
}

extension UIViewController: UIGestureRecognizerDelegate {
    


    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

}

extension UIViewController {
    
}


