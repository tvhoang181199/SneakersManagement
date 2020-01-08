//
//  HomeViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/5/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SCLAlertView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var hiLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var tradingButton: UIButton!
    @IBOutlet weak var REButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    
    var lastName: String? = nil
    var profileImageURL: String? = nil
    
    let db = Firestore.firestore()
    let email = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkRole()
        setUpElements()
        setUpData()
        
        // Do any additional setup after loading the view.
    }
    
    func checkRole() {
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                if (snapshot?.data()!["accounttype"] as? String) == "Standard" {
                    self.tradingButton.isEnabled = false
                    self.REButton.isEnabled = false
                }
            }
        }
    }
    
    func setUpElements() {
        let attriutes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 25)]
        navigationController?.navigationBar.titleTextAttributes = attriutes as [NSAttributedString.Key : Any]
        Utilities.styleProfileImageView(profileImageView)
        storeButton.layer.cornerRadius = 10
        tradingButton.layer.cornerRadius = 10
        REButton.layer.cornerRadius = 10
        accountButton.layer.cornerRadius = 10
    }
    
    func setUpData() {
        let email = Auth.auth().currentUser?.email
        let db = Firestore.firestore()
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                // Get data
                self.lastName = snapshot?.data()!["lastname"] as? String
                self.profileImageURL = snapshot?.data()!["photoURL"] as? String
                
                // Update profile photo
                let ref = Storage.storage().reference(forURL: self.profileImageURL!)
                ref.getData(maxSize: 1 * 2048 * 2048) { (data, error) in
                    if error == nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.profileImageView.image = UIImage(data: data!)!
                        }
                    }
                }

                // Update labels
                self.hiLabel.text = "Hi, \(self.lastName!)!"
            }
        }
    }
    
    @IBAction func unwindToHomeView(segue:UIStoryboardSegue) {
    }

    @IBAction func logoutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "unwindToLoginViewSegue", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
