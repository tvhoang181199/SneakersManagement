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
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selectedGender: String? = nil
    var selectedAccountType: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.HiddenKeyBoard()
        
        imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
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
        // Style profile photo
        Utilities.styleProfileImageView(profileImageView)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func editProfileImageTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
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
                    db.collection("users").document(email).setData(["lastname":lastName, "firstname":firstName, "email":email, "phonenumber":phoneNumber, "gender":gender, "accounttype":accountType, "photoURL":"gs://sneakers-management-e47a9.appspot.com/user-profile-image/\(result!.user.uid)", "uid":result!.user.uid]) { (error) in
                        
                        if error != nil {
                            // Show error alert
                            SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                        }
                        else {
                            // Upload profile photo
                            let uid = result!.user.uid
                            let storageRef = Storage.storage().reference().child("user-profile-image/\(uid)")

                            guard let imageData = self.profileImageView.image!.jpegData(compressionQuality: 1) else { return }

                            let metaData = StorageMetadata()
                            metaData.contentType = "image/jpeg"

                            storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                                guard metaData != nil else { return }
                                storageRef.downloadURL { (url, error) in
                                    guard url != nil else { return }
                                }
                            }
                            // Go to HomeView
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alert = SCLAlertView(appearance: appearance)
                            alert.addButton("OK") { () -> Void in
                                let story = self.storyboard
                                let vc = story?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                                let navController = UINavigationController(rootViewController: vc)
                                navController.modalPresentationStyle = .fullScreen
                                self.present(navController, animated: true)
                            }
                            // Show alert view before changing to HomeView
                            alert.showSuccess("Success", subTitle: "Your account was created successfully")
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension SignUpViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
