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

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var paymentButton: UIButton!
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
    var indexAll: Int = -1
    var indexOther: Int = -1
    
    let db = Firestore.firestore()
    let email = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkRole()
        setupElements()
        setupData()
        
        // Do any additional setup after loading the view.
    }
    
    func setupData() {
        nameLabel.text = "Name:   \(name)"
        amountLabel.text = "Amount:   \(amount)"
        priceLabel.text =  "Price:   $\(price)"
        categoryLabel.text = "Category:   \(category)"
        sneakerImageView.image = image
    }
    
    func setupElements() {
        Utilities.stylePaymentButton(paymentButton)
    }
    
    func checkRole() {
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                if (snapshot?.data()!["accounttype"] as? String) == "Standard" {
                    self.editButton.isEnabled = false
                    self.paymentButton.isEnabled = false
                }
            }
        }
    }
    
    func getIndex(_ name: String, _ category: String) {
        // Get index of "All" category
        db.collection("categories").document("All").getDocument { (snapshot, err) in
            let countAll = snapshot?.data()!["count"] as! Int
            for i in 0..<countAll {
                let index = "sneaker" + String(i)
                let info = snapshot?.data()![index] as! [Any]
                let _name = info[0] as! String
                if _name == name {
                    self.indexAll = i
                    break
                }
            }
        }
        // Get index of non-"All" category
        if category != "All" {
            self.db.collection("categories").document(category).getDocument { (snapshot, err) in
                let countOther = snapshot?.data()!["count"] as! Int
                for i in 0..<countOther {
                    let index = "sneaker" + String(i)
                    let info = snapshot?.data()![index] as! [Any]
                    let _name = info[0] as! String
                    if _name == name {
                        self.indexOther = i
                        break
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoEditSneakerSegue" {
            let vc = segue.destination as! EditSneakerViewController
            
            getIndex(name, category)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                vc.indexAll = self.indexAll
                vc.indexOther = self.indexOther
            }
            vc.name = name
            vc.amount = amount
            vc.price = price
            vc.category = category
            vc.image = image

        }
        else if segue.identifier == "GotoPaymentSegue" {
            let vc = segue.destination as! PaymentViewController
            
            getIndex(name, category)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                vc.indexAll = self.indexAll
                vc.indexOther = self.indexOther
            }
            
            vc.name = name
            vc.amountStock = amount
            vc.price = price
            vc.category = category
            vc.image = image
        }
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
