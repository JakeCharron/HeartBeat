//
//  ViewController.swift
//  HeartBeat
//
//  Created by JakeDev on 9/8/18.
//  Copyright © 2018 Jake Charron. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func login(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        print("\(username.text)")
        ref.child("Users").child("\(username.text)").observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.value)
        }
    }
    
}
