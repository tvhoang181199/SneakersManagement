//
//  EditSneakerViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 1/7/20.
//  Copyright © 2020 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class EditSneakerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var editSneakerImageButton: UIButton!
    @IBOutlet weak var sneakerImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!

    var indexAll: Int = -1
    var indexOther: Int = -1
    var name: String = ""
    var amount: Int = 0
    var price: Int = 0
    var category: String = ""
    var image = UIImage()
    
    let sneakerCategories: [String] = ["All", "Nike", "Adidas", "Asics", "Puma", "Jordan"]
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sneakerImageView.image = image
        nameTextField.text = name
        amountTextField.text = "\(amount)"
        priceTextField.text = "\(price)"
        

        imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        amountTextField.delegate = self
        amountTextField.keyboardType = .numberPad
        priceTextField.delegate = self
        priceTextField.keyboardType = .numberPad
        
        self.HiddenKeyBoard()
        // Do any additional setup after loading the view.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    func validateFields() -> String? {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill all information"
        }
        return nil
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
    
    @IBAction func editSneakerImageTapped(_ sender: Any) {
         self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        amount = (amountTextField.text! as NSString).integerValue
        amount += 1
        amountTextField.text = "\(amount)"
    }
    
    @IBAction func minusButtonTapped(_ sender: Any) {
        amount = (amountTextField.text! as NSString).integerValue
        if (amount == 0){
            SCLAlertView().showError("Error", subTitle: "Amount must be equal or greater than 0!")
        }
        else {
            amount -= 1
            amountTextField.text = "\(amount)"
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // Validate text fields
        let error = validateFields()
        
        if error != nil {
            SCLAlertView().showError("Error", subTitle: error!)
        }
        else {
            self.db.collection("categories").document("All").updateData(["sneaker\(indexAll)":[self.nameTextField.text!, self.amount, (self.priceTextField.text! as NSString).integerValue, self.category, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(self.nameTextField.text!)"]])
            
            if self.indexOther != -1 {
                self.db.collection("categories").document(self.category).updateData(["sneaker\(indexOther)":[self.nameTextField.text!, self.amount, (self.priceTextField.text! as NSString).integerValue, self.category, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(self.nameTextField.text!)"]]) { (error) in
                    
                    if error != nil {
                        // Show error alert
                        SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                    }
                    else {
                        // Upload sneaker photo
                        let storageRef = Storage.storage().reference().child("sneaker-image/\(self.nameTextField.text!)")
                        
                        guard let imageData = self.sneakerImageView.image!.jpegData(compressionQuality: 1) else { return }
                        
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpeg"
                        
                        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                            guard metaData != nil else { return }
                            storageRef.downloadURL { (url, error) in
                                guard url != nil else { return }
                            }
                        }
                    }
                }
            }
            // Back to Store View
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("OK") { () -> Void in
                self.performSegue(withIdentifier: "unwindToStoreViewSegue", sender: self)
            }
            // Show success alert view
            alert.showSuccess("Success", subTitle: "Your new sneaker has been updated!")
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

extension EditSneakerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            self.sneakerImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.sneakerImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditSneakerViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
