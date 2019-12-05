//
//  Ultilities.swift
//  Sneakers Management
//
//  Created by Vũ Hoàng Trịnh on 12/4/19.
//  Copyright © 2019 Vũ Hoàng Trịnh. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.init(red: 48/255, green: 100/255, blue: 180/255, alpha: 1).cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.init(red: 48/255, green: 100/255, blue: 180/255, alpha: 1)
    }
    
    static func styleLoginTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 100/255, blue: 180/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleCancelHollowButton(_ button:UIButton) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.red
    }
    
    static func styleLoginFilledButton(_ button:UIButton) {
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 100/255, blue: 180/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&~])[A-Za-z\\d$@$#!%*?&~]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}
