//
//  StoreViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/30/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SCLAlertView

struct sneakerInfo {
    var name: String? = nil
    var category: String? = nil
    var amount: Int? = nil
    var price: Int? = nil
    var image: UIImage? = nil
}

class sneakerCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}

class StoreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sneakerCategories: [String] = ["All", "Nike", "Adidas", "Asics", "Puma", "Jordan"]
    var category: String? = "All"
    var sneakerList = [sneakerInfo]()
    var count = 0
    var selectedCellRow = 0

    let db = Firestore.firestore()
    let email = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkRole()
        
        setImageList()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func checkRole() {
        db.collection("users").document(email!).getDocument { (snapshot, err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                if (snapshot?.data()!["accounttype"] as? String) == "Standard" {
                    self.addButton.isEnabled = false
                }
            }
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
    
    @IBAction func filterTapped(_ sender: Any) {
        setImageList()
        self.collectionView.reloadData()
    }
    
    func setImageList() {
        sneakerList.removeAll()
        db.collection("categories").document(category!).getDocument { (snapshot, err) in
            if let err = err {
                SCLAlertView().showError("Error", subTitle: err.localizedDescription)
            }
            else {
                self.count = snapshot!.data()!["count"] as! Int
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if (self.count == 0) {
                        SCLAlertView().showNotice("Out of stock", subTitle: "No sneakers found!")
                    }
                    else {
                        for i in 0..<self.count {
                            let index = "sneaker" + String(i)
                            let info = snapshot?.data()![index] as! [Any]
                            let _name = info[0] as! String
                            let _amount = info[1] as! Int
                            let _price = info[2] as! Int
                            let _category = info[3] as! String
                            let photoURL = info[4] as! String
                            
                            let ref = Storage.storage().reference(forURL: photoURL)
                            ref.getData(maxSize: 1*2048*2048) { (data, err) in
                                if let err = err {
                                    SCLAlertView().showError("Error", subTitle: err.localizedDescription)
                                }
                                else {
                                    let sneaker = sneakerInfo(name: _name, category: _category, amount: _amount, price: _price, image: UIImage(data: data!))
                                    self.sneakerList.append(sneaker)
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sneakerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sneakerCell", for: indexPath) as! sneakerCell
        
        cell.imageView.image =  sneakerList[indexPath.row].image
        cell.nameLabel.text = sneakerList[indexPath.row].name

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoSneakerDetailSegue" {
            let vc = segue.destination as! SneakerDetailViewController
            guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else { return }
              
            vc.name = sneakerList[indexPath.row].name!
            vc.amount = sneakerList[indexPath.row].amount!
            vc.price = sneakerList[indexPath.row].price!
            vc.category = sneakerList[indexPath.row].category!
            vc.image = sneakerList[indexPath.row].image!
        }
    }
    
    @IBAction func unwindToStoreView(segue:UIStoryboardSegue) {
        setImageList()
        collectionView.reloadData()
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

extension StoreViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
