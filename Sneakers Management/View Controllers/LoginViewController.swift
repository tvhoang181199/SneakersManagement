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

var global_email: String? = nil

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
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
                global_email = email
                let story = self.storyboard
                let vc = story?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
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
