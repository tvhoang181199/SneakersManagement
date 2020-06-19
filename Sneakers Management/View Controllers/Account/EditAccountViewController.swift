//
//  EditAccountViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/6/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth
import Firebase

class EditAccountViewController: UIViewController {

    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var selectedGender: String? = nil
    
    var lastName: String? = nil
    var firstName: String? = nil
    var gender: String? = nil
    var profileImageURL: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        setUpData()
        
        imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.HiddenKeyBoard()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        // Style text fields
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(firstNameTextField)
        // Style profile image view
        Utilities.styleProfileImageView(profileImageView)
    }
    
    func setUpData() {
        let email = Auth.auth().currentUser?.email
        let db = Firestore.firestore()
        
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                // Get current data
                self.lastName = snapshot?.data()!["lastname"] as? String
                self.firstName = snapshot?.data()!["firstname"] as? String
                self.gender = snapshot?.data()!["gender"] as? String
                self.profileImageURL = snapshot?.data()!["photoURL"] as? String
                
                // Show profile photo
                let ref = Storage.storage().reference(forURL: self.profileImageURL!)
                ref.getData(maxSize: 1 * 2048 * 2048) { (data, error) in
                    if error == nil {
                        self.profileImageView.image = UIImage(data: data!)
                    }
                }
                
                // Set information text fields
                self.lastNameTextField.text = "\(self.lastName!)"
                self.firstNameTextField.text = "\(self.firstName!)"
                
                // Set gender information radio buttons
                if (self.gender == "Male") {
                    self.maleButton.isSelected = true
                    self.selectedGender = "Male"
                }
                else {
                    self.femaleButton.isSelected = true
                    self.selectedGender = "Female"
                }
                
            }
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
    
    @IBAction func saveTapped(_ sender: Any) {
        // Create data
        let lastName = lastNameTextField.text!
        let firstName = firstNameTextField.text!
        let gender = selectedGender!

        // Update data
        let uid = Auth.auth().currentUser?.uid
        let email = Auth.auth().currentUser?.email
        let db = Firestore.firestore()
        let ref = db.collection("users").document(email!)
        ref.updateData(["lastname":lastName, "firstname":firstName, "gender":gender]) { (err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                // Upload profile photo
                let storageRef = Storage.storage().reference().child("user-profile-image/\(uid!)")

                guard let imageData = self.profileImageView.image!.jpegData(compressionQuality: 1) else { return }

                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"

                storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                    guard metaData != nil else { return }
                    storageRef.downloadURL { (url, error) in
                        guard url != nil else { return }
                    }
                }
                // Show alert view
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
                alert.showSuccess("Success", subTitle: "Your information have been updated!")
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

extension EditAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension EditAccountViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
