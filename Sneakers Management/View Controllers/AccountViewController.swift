//
//  AccountViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/6/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var changepwdButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    let db = Firestore.firestore()
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
    
    func setUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                for document in (snapshot?.documents)! {
                    if let _lastName = document.data()["lastname"] as? String {
                        self.lastName = _lastName
                    }
                    if let _firstName = document.data()["firstname"] as? String {
                        self.firstName = _firstName
                    }
                    if let _phone = document.data()["phonenumber"] as? String {
                        self.phone = _phone
                    }
                    if let _email = document.data()["email"] as? String {
                        self.email = _email
                    }
                    if let _gender = document.data()["gender"] as? String {
                        self.gender = _gender
                    }
                    if let _type = document.data()["accounttype"] as? String {
                        self.type = _type
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
    
    func setUpElements() {
        Utilities.styleLoginFilledButton(editButton)
        Utilities.styleFilledButton(changepwdButton)
        Utilities.styleCancelHollowButton(backButton)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
