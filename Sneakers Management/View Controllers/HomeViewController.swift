//
//  HomeViewController.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/5/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        Utilities.styleCancelHollowButton(logoutButton)
    }
    
    @IBAction func unwindToHomeView(segue:UIStoryboardSegue) {
    }

    @IBAction func logoutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "unwindToLoginViewSegue", sender: self)
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
