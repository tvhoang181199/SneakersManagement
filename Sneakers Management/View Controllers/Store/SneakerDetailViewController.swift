//
//  SneakerDetailViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 1/7/20.
//  Copyright © 2020 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SCLAlertView

class SneakerDetailViewController: UIViewController {

    @IBOutlet weak var sneakerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var name: String = ""
    var amount: Int = 0
    var price: Int = 0
    var category: String = ""
    var image = UIImage()
    
    let db = Firestore.firestore()
    let email = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //checkRole()
        
        nameLabel.text = "Name:   \(name)"
        amountLabel.text = "Amount:   \(amount)"
        priceLabel.text =  "Price:   $\(price)"
        categoryLabel.text = "Category:   \(category)"
        sneakerImageView.image = image

        // Do any additional setup after loading the view.
    }
    
//    func checkRole() {
//        db.collection("users").document(email!).getDocument { (snapshot, err) in
//            if let err = err {
//                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
//            }
//            else {
//                if (snapshot?.data()!["accounttype"] as? String) == "Standard" {
//                    self.deleteButton.isEnabled = false
//                }
//            }
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
