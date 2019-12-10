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
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selectedGender: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleLoginFilledButton(saveButton)
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
    
    @IBAction func saveTapped(_ sender: Any) {
        // Create data
        let lastName = lastNameTextField.text!
        let firstName = firstNameTextField.text!
        let gender = selectedGender!

        // Update data
        let email = Auth.auth().currentUser?.email
        let db = Firestore.firestore()
        let ref = db.collection("users").document(email!)
        ref.updateData(["lastname":lastName, "firstname":firstName, "gender":gender]) { (err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert = SCLAlertView(appearance: appearance)
                alert.addButton("OK") { () -> Void in
                    let story = self.storyboard
                    let vc = story?.instantiateViewController(withIdentifier: "AccountVC") as! AccountViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: false)
                }
                alert.showSuccess("Success", subTitle: "Your information have been updated!")
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
