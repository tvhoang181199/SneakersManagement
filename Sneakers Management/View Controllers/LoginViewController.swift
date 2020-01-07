//
//  LoginViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/4/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        
        self.HiddenKeyBoard()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        Utilities.styleLoginTextField(emailTextField)
        Utilities.styleLoginTextField(passwordTextField)
        Utilities.styleLoginFilledButton(loginButton)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // Create cleaned data
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sign in
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
            }
            else {
                // Transition to HomeVC
                let story = self.storyboard
                let vc = story?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            }
        }
    }
    
    @IBAction func forgetPasswordTapped(_ sender: Any) {
        if emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            SCLAlertView().showError("Error", subTitle: "Please enter your email address")
        }
        else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
                else {
                    SCLAlertView().showInfo("Email Sent", subTitle: "Check your email and follow the instructions to reset your password")
                }
            }
        }
    }
    
    @IBAction func unwindToLoginView(segue:UIStoryboardSegue) {
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

extension LoginViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
