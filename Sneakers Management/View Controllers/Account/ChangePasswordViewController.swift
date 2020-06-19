//
//  ChangePasswordViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/6/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        
        self.HiddenKeyBoard()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements(){
        Utilities.styleLoginTextField(newPasswordTextField)
        Utilities.styleLoginTextField(confirmNewPasswordTextField)
        Utilities.styleFilledButton(changePasswordButton)
    }
    
    func validateFields() -> String? {
        if newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmNewPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please enter all fields"
        }
        let cleanedPassword = newPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your new password is at least 8 charaters, contains a special character and a number"
        }
        else {
            if (newPasswordTextField.text! != confirmNewPasswordTextField.text!) {
                return "Your confirm password is not matched"
            }
        }
        return nil
    }
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        // Validate text fields
        let error = validateFields()
        
        if error != nil {
            SCLAlertView().showError("Error", subTitle: error!)
        }
        else {
            let password = newPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Update password
            let user = Auth.auth().currentUser
            user?.updatePassword(to: password, completion: { (error) in
                if let error = error {
                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
                else {
                    SCLAlertView().showSuccess("Success", subTitle: "Your password has been changed")
                    self.dismiss(animated: true, completion: nil)
                }
            })
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

extension ChangePasswordViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
