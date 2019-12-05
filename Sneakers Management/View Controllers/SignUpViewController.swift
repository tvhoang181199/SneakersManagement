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
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let genderList = ["Male", "Female", "Other"]
    var selectedGender: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        createGenderPicker()
        createBirthdayPicker()
        createToolbar()

        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        // Style textfields
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(phoneNumberTextField)
        Utilities.styleTextField(genderTextField)
        Utilities.styleTextField(birthdayTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(confirmPasswordTextField)
        // Style buttons
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleCancelHollowButton(cancelButton)
    }
    
    // Create pickers
    func createBirthdayPicker() {
        let birthdayPicker = UIDatePicker()
        birthdayPicker.datePickerMode = .date
        birthdayPicker.addTarget(self, action: #selector(SignUpViewController.dateChanged(birthdayPicker:)), for: .valueChanged)
        birthdayTextField.inputView = birthdayPicker
    }
    
    @objc func dateChanged(birthdayPicker: UIDatePicker){
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "MMM dd, yyyy"
        birthdayTextField.text = birthdayFormatter.string(from: birthdayPicker.date)
    }
    
    func createGenderPicker() {
        let genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker
    }
    
    func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SignUpViewController.dissmissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        genderTextField.inputAccessoryView = toolBar
        birthdayTextField.inputAccessoryView = toolBar
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    // Sign up method
    func validateFields() -> String? {
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
            let gender = genderTextField.text!
            let birthday = birthdayTextField.text!
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
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
                    
                    db.collection("users").addDocument(data: ["lastname":lastName, "firstname":firstName, "phonenumber":phoneNumber, "gender":gender, "birthday":birthday, "uid":result!.user.uid]) { (error) in
                        
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

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = genderList[row]
        genderTextField.text = selectedGender
    }
}

