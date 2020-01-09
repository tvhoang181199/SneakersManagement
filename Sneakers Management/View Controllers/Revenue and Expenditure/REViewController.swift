//
//  REViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/30/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class REViewController: UIViewController {

    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var expenditureLabel: UILabel!
    
    var revenue: Int = 0
    var expenditure: Int = 0
    var countSneaker: Int = 0
    var countPayment: Int = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.revenueLabel.text = "TOTAL REVENUE: $\(self.revenue)"
            self.expenditureLabel.text = "TOTAL EXPENDITURE: $\(self.expenditure)"

        }
        
        // Do any additional setup after loading the view.
    }
    
    func setUpData() {
        // Set revenue value
        db.collection("trading").document("payment").getDocument { (snapshot, err) in
            if let snapshot = snapshot, snapshot.exists {
                if let err = err {
                    SCLAlertView().showError("Error", subTitle: err.localizedDescription)
                }
                else {
                    self.countPayment = snapshot.data()!["count"] as! Int
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if (self.countPayment != 0) {
                            for i in 0..<self.countPayment {
                                let index = "payment" + String(i)
                                let info = snapshot.data()![index] as! [Any]
                                let _total = info[4] as! Int
                                self.revenue += _total
                            }
                        }
                    }
                }
            }
        }

        // Set expenditure value
        self.db.collection("categories").document("All").getDocument { (snapshot, err) in
            if let snapshot = snapshot, snapshot.exists {
                if let err = err {
                    SCLAlertView().showError("Error", subTitle: err.localizedDescription)
                }
                else {
                    self.countSneaker = snapshot.data()!["count"] as! Int
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if (self.countSneaker != 0) {
                            for i in 0..<self.countSneaker {
                                let index = "sneaker" + String(i)
                                let info = snapshot.data()![index] as! [Any]
                                let _amount = info[1] as! Int
                                let _price = info[2] as! Int
                                self.expenditure += (_amount * _price)
                            }
                        }
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
