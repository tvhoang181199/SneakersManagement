//
//  AccountViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/6/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import Firebase

class AccountViewController: UIViewController {
    
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var lastName: String? = nil
    var firstName: String? = nil
    var phone: String? = nil
    var email: String? = nil
    var gender: String? = nil
    var type: String? = nil
    var profileImageURL: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        setUpData()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(changePasswordButton)
        Utilities.styleDeleteFilledButton(deleteAccountButton)
        Utilities.styleProfileImageView(profileImageView)
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
                self.firstName = snapshot?.data()!["firstname"] as? String
                self.phone = snapshot?.data()!["phonenumber"] as? String
                self.email = snapshot?.data()!["email"] as? String
                self.gender = snapshot?.data()!["gender"] as? String
                self.type = snapshot?.data()!["accounttype"] as? String
                self.profileImageURL = snapshot?.data()!["photoURL"] as? String
                
                // Update profile photo
                let ref = Storage.storage().reference(forURL: self.profileImageURL!)
                ref.getData(maxSize: 1 * 2048 * 2048) { (data, error) in
                    if error == nil {
                        self.profileImageView.image = UIImage(data: data!)
                    }
                }
                
                // Update labels
                self.nameLabel.text = "\(self.firstName!) \(self.lastName!)"
                self.phoneLabel.text = "\(self.phone!)"
                self.genderLabel.text = "\(self.gender!)"
                self.typeLabel.text = "\(self.type!)"
                self.emailLabel.text = "\(self.email!)"
            }
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes") { () -> Void in
            let user = Auth.auth().currentUser
            let db = Firestore.firestore()
            // Delete user database
            db.collection("users").document((user?.email)!).delete { (error) in
                if let error = error {
                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
            }
            
            // Delete user's profile photo
            let ref = Storage.storage().reference(forURL: self.profileImageURL!)
            ref.delete(completion: nil)
            
            // Delete user
            user?.delete(completion: { (error) in
                if let error = error {
                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
                else {
                    self.performSegue(withIdentifier: "unwindToLoginViewSegue", sender: self)
                }
            })
        }
        alert.addButton("No") {}
        alert.showWarning("Warning", subTitle: "Your account will be DELETED. Are you sure?")
    }
    
    @IBAction func backTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindToHomeViewSegue", sender: self)
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
