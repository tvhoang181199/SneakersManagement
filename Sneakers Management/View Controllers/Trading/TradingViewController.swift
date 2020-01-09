//
//  TradingViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/30/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

struct paymentInfo {
    var customer: String? = nil
    var phone: String? = nil
    var sneaker: String? = nil
    var amount: Int? = nil
    var total: Int? = nil
    var date: String? = nil
    var image: UIImage? = nil
}

class paymentCell: UITableViewCell {
    @IBOutlet weak var sneakerImage: UIImageView!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    func setPayment(_ payment: paymentInfo) {
        sneakerImage.image = payment.image!
        customerLabel.text = payment.customer!
        amountLabel.text = "Amount: \(payment.amount!)"
        dateLabel.text = payment.date!
        totalLabel.text = "Total: $\(payment.total!)"
    }
    
}

class TradingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var paymentList = [paymentInfo]()
    var count: Int = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPaymentList()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reloadTable(_ sender: Any) {
        setPaymentList()
        tableView.reloadData()
    }
    
    func setPaymentList() {
        paymentList.removeAll()
        db.collection("trading").document("payment").getDocument { (snapshot, err) in
            if let snapshot = snapshot, snapshot.exists {
                if let err = err {
                    SCLAlertView().showError("Error", subTitle: err.localizedDescription)
                }
                else {
                    self.count = snapshot.data()!["count"] as! Int
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if (self.count == 0) {
                            SCLAlertView().showNotice("Notice", subTitle: "No trading history!")
                        }
                        else {
                            for i in 0..<self.count {
                                let index = "payment" + String(i)
                                let info = snapshot.data()![index] as! [Any]
                                let _customer = info[0] as! String
                                let _phone = info[1] as! String
                                let _sneaker = info[2] as! String
                                let _amount = info[3] as! Int
                                let _total = info[4] as! Int
                                let _date = info[5] as! String
                                let photoURL = "gs://sneakers-management-e47a9.appspot.com/sneaker-image/\(_sneaker)"
                                
                                let ref = Storage.storage().reference(forURL: photoURL)
                                ref.getData(maxSize: 1*2048*2048) { (data, err) in
                                    if let err = err {
                                        SCLAlertView().showError("Error", subTitle: err.localizedDescription)
                                    }
                                    else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            let payment = paymentInfo(customer: _customer, phone: _phone, sneaker: _sneaker, amount: _amount, total: _total, date: _date, image: UIImage(data: data!))
                                            self.paymentList.append(payment)
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                SCLAlertView().showNotice("Notice", subTitle: "No trading history!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! paymentCell
        
        cell.setPayment(paymentList[indexPath.row])
        
        return cell
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
