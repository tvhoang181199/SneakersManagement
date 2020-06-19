//
//  AddSneakerViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 1/7/20.
//  Copyright © 2020 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class AddSneakerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var editSneakerImageButton: UIButton!
    @IBOutlet weak var sneakerImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var amount: Int = 1
    var category: String? = "All"
    var countAll = 0
    var count = 0
    let sneakerCategories: [String] = ["All", "Nike", "Adidas", "Asics", "Puma", "Jordan"]
    
    let db = Firestore.firestore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.text = "\(amount)"
        
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
        if (amount == 1){
            SCLAlertView().showError("Error", subTitle: "Amount must be greater than 0!")
        }
        else {
            amount -= 1
            amountTextField.text = "\(amount)"
        }
    }
    
    @IBAction func categoriesTapped(_ sender: Any) {
        let alertView = UIAlertController(
            title: "Select Category",
            message: "\n\n\n\n\n\n",
            preferredStyle: .alert)

        let categoriesPicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 114))
        categoriesPicker.delegate = self
        categoriesPicker.dataSource = self

        categoriesPicker.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        alertView.view.addSubview(categoriesPicker)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        
        present(alertView, animated: true, completion: { () in
            categoriesPicker.frame.size.width = alertView.view.frame.size.width
        })
    }
    
    @IBAction func addTapped(_ sender: Any) {
        // Validate text fields
        let error = validateFields()

        if error != nil {
            SCLAlertView().showError("Error", subTitle: error!)
        }
        else if (amountTextField.text! as NSString).integerValue == 0 {
            SCLAlertView().showError("Error", subTitle: "Amount must be greater than 0!")
        }
        else {
            // Get count from category "All"
            db.collection("categories").document("All").getDocument { (snapshot, err) in
                if let snapshot = snapshot, snapshot.exists {
                    self.countAll = snapshot.data()!["count"]  as! Int
                }
                else {
                    self.db.collection("categories").document("All").setData(["count":self.countAll])
                }
            }
            // Get count from others
            db.collection("categories").document(self.category!).getDocument { (snapshot, err) in
                if let snapshot = snapshot, snapshot.exists {
                    self.count = snapshot.data()!["count"]  as! Int
                }
                else {
                    self.db.collection("categories").document(self.category!).setData(["count":self.count])
                }
            }
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                if self.category != "All" {
                    self.db.collection("categories").document(self.category!).updateData(["sneaker\(self.count)":[self.nameTextField.text!, self.amount, (self.priceTextField.text! as NSString).integerValue, self.category!, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(self.nameTextField.text!)"], "count":(self.count + 1)])
                }
                
                self.db.collection("categories").document("All").updateData(["sneaker\(self.countAll)":[self.nameTextField.text!, self.amount, (self.priceTextField.text! as NSString).integerValue, self.category!, "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(self.nameTextField.text!)"], "count":(self.countAll + 1)]) { (error) in
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
                        // Back to Store View
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.addButton("OK") { () -> Void in
                            self.performSegue(withIdentifier: "unwindToStoreViewSegue", sender: self)
                        }
                        // Show success alert view
                        alert.showSuccess("Success", subTitle: "Your new sneaker has been added!")
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

extension AddSneakerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension AddSneakerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sneakerCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sneakerCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.text =  sneakerCategories[row]
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category = sneakerCategories[row]
        categoriesButton.titleLabel?.text = "   \(category!)"
    }
}

extension AddSneakerViewController {
    func HiddenKeyBoard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func textDismissKeyboard() {
        view.endEditing(true)
    }
}
