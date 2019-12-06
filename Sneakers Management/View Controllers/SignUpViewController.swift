//
//  SignUpViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/4/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var standardButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selectedGender: String? = nil
    var selectedAccountType: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        // Style textfields
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(phoneNumberTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(confirmPasswordTextField)
        // Style buttons
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleCancelHollowButton(cancelButton)
    }
    
    @IBAction func maleTapped(_ sender: Any) {
        if femaleButton.isSelected {
            femaleButton.isSelected = false
            maleButton.isSelected = true
            selectedGender = "Male"
        }
        else {
            maleButton.isSelected = true
            selectedGender = "Male"
        }
    }
    
    @IBAction func femaleTapped(_ sender: Any) {
        if maleButton.isSelected {
            maleButton.isSelected = false
            femaleButton.isSelected = true
            selectedGender = "Female"
        }
        else {
            femaleButton.isSelected = true
            selectedGender = "Female"
        }
    }
    
    @IBAction func stardardButton(_ sender: Any) {
        if adminButton.isSelected {
            adminButton.isSelected = false
            standardButton.isSelected = true
            selectedAccountType = "Stardard"
        }
        else {
            standardButton.isSelected = true
            selectedAccountType = "Stardard"
        }
    }
    
    @IBAction func adminButton(_ sender: Any) {
        if standardButton.isSelected {
            standardButton.isSelected = false
            adminButton.isSelected = true
            selectedAccountType = "Admin"
        }
        else {
            adminButton.isSelected = true
            selectedAccountType = "Admin"
        }
    }
    
    // Sign up method
    func validateFields() -> String? {
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || selectedGender == nil || selectedAccountType == nil {
            return "Please fill all information"
        }
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 charaters, contains a special character and a number"
        }
        else {
            if (passwordTextField.text! != confirmPasswordTextField.text!) {
                return "Your confirm password is not matched"
            }
        }
        return nil
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        // Validate text fields
        let error = validateFields()
        
        if error != nil {
            SCLAlertView().showError("Error", subTitle: error!)
        }
        else {
            // Create data
            let lastName = lastNameTextField.text!
            let firstName = firstNameTextField.text!
            let phoneNumber = phoneNumberTextField.text!
            let gender = selectedGender!
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let accountType = selectedAccountType!
            
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    // There was an error creating the user
                    SCLAlertView().showError("Error", subTitle: err!.localizedDescription)
                }
                else {
                    // Create user successfully
                    // Store user's data
                    let db = Firestore.firestore()
                    db.collection("users").document(email).setData(["lastname":lastName, "firstname":firstName, "email":email, "phonenumber":phoneNumber, "gender":gender, "accounttype":accountType, "uid":result!.user.uid]) { (error) in
                        
                        if error != nil {
                            // Show error alert
                            SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                        }
                        else {
                            // Show success alert
                            SCLAlertView().showSuccess("Success", subTitle: "Your account was created successfully!")
                            // Go back to StartView
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
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
