//
//  PaymentViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 1/8/20.
//  Copyright © 2020 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class PaymentViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var sneakerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var customerTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!
    
    var indexAll: Int = -1
    var indexOther: Int = -1
    var count: Int = 0
    var name: String = ""
    var amountStock: Int = 0
    var amount: Int = 1
    var price: Int = 0
    var category: String = ""
    var today: String = ""
    var image = UIImage()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupElements()
        setUpdata()
        
        amountTextField.delegate = self
        amountTextField.keyboardType = .numberPad
        phoneTextField.delegate = self
        phoneTextField.keyboardType = .numberPad
        
        self.HiddenKeyBoard()
        // Do any additional setup after loading the view.
    }
    
    func setupElements() {
        Utilities.stylePaymentButton(paymentButton)
    }
    
    func setUpdata() {
        nameLabel.text = name
        amountTextField.text = "\(amount)"
        totalLabel.text = "Total:   $\(amount * price)"
        sneakerImageView.image = image
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        today = formatter.string(from: date)
        dateLabel.text = "Date:   \(today)"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    func validateFields() -> String? {
        if amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || customerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill all information"
        }
        return nil
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        if amount >= amountStock {
            SCLAlertView().showError("Error", subTitle: "Not enough!")
        }
        else {
            amount = (amountTextField.text! as NSString).integerValue
            amount += 1
            amountTextField.text = "\(amount)"
            totalLabel.text = "Total:   $\(amount * price)"
        }
    }
    
    @IBAction func minusButtonTapped(_ sender: Any) {
        amount = (amountTextField.text! as NSString).integerValue
        if (amount == 1){
            SCLAlertView().showError("Error", subTitle: "Amount must be greater than 0!")
        }
        else {
            amount -= 1
            amountTextField.text = "\(amount)"
            totalLabel.text = "Total:   $\(amount * price)"
        }
    }
    
    
    @IBAction func payTapped(_ sender: Any) {
        // Validate text fields
        let error = validateFields()
        
        if error != nil {
            SCLAlertView().showError("Error", subTitle: error!)
        }
        else if (amountTextField.text! as NSString).integerValue > amountStock {
            SCLAlertView().showError("Error", subTitle: "Not enough!")
        }
        else if (amountTextField.text! as NSString).integerValue == 0 {
            SCLAlertView().showError("Error", subTitle: "Amount must be greater than 0!")
        }
        else {
            // Update stock
            db.collection("categories").document("All").updateData(["sneaker\(indexAll)":[name, (amountStock - amount), price, category, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(name)"]])
            
            if indexOther != -1 {
                db.collection("categories").document(category).updateData(["sneaker\(indexOther)":[name, (amountStock - amount), price, self.category, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(name)"]])
            }
            
            // Create payment
            // Get count
            db.collection("trading").document("payment").getDocument { (snapshot, err) in
                if let snapshot = snapshot, snapshot.exists {
                    self.count = snapshot.data()!["count"] as! Int
                }
                else {
                    self.db.collection("trading").document("payment").setData(["count":self.count])
                }
            }
            // Create new payment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.db.collection("trading").document("payment").updateData(["payment\(self.count)":[self.customerTextField.text!, self.phoneTextField.text!, self.name, self.amount, (self.amount * self.price), self.today], "count":(self.count + 1)]) { (error) in
                    
                    if error != nil {
                        // Show error alert
                        SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                    }
                    else {
                        // Back to Store View
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.addButton("OK") { () -> Void in
                            self.performSegue(withIdentifier: "unwindToStoreViewSegue", sender: self)
                        }
                        // Show success alert view
                        alert.showSuccess("Success", subTitle: "Payment created successfully!")
                    }
                }
            }
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

extension PaymentViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
