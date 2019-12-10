//
//  AccountViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/6/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class AccountViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var lastName: String? = nil
    var firstName: String? = nil
    var phone: String? = nil
    var email: String? = nil
    var gender: String? = nil
    var type: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        setUserData()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        Utilities.styleLoginFilledButton(editButton)
        Utilities.styleFilledButton(changePasswordButton)
        Utilities.styleDeleteFilledButton(deleteAccountButton)
        Utilities.styleCancelHollowButton(backButton)
    }
    
    func setUserData() {
        let email = Auth.auth().currentUser?.email
        let db = Firestore.firestore()
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                for document in ((snapshot?.data())!) {
                    switch (document.key) {
                    case "lastname":
                        self.lastName = document.value as? String
                    case "firstname":
                        self.firstName = document.value as? String
                    case "phonenumber":
                        self.phone = document.value as? String
                    case "email":
                        self.email = document.value as? String
                    case "gender":
                        self.gender = document.value as? String
                    case "accounttype":
                        self.type = document.value as? String
                    default:
                        ()
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
            db.collection("users").document((user?.email)!).delete { (error) in
                if let error = error {
                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
            }
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
