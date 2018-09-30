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
    
    var fireName = String()
    var firePass = String()
    
    
    @IBAction func login(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            print("Users: ", snapshot)
            var counter = 0
            while (counter < snapshot.childrenCount){
                
                print("Child Snapshot: ", "\(String(describing: snapshot.childSnapshot(forPath: "\(counter)").value))")

                let usernameVal = "\(String(describing: self.username.text))"
                
                let  fireVal = "\(String(describing: snapshot.childSnapshot(forPath: "\(counter)").value))"

                if usernameVal == fireVal {
                    print("\(String(describing: self.username.text)) ","equals ", " \(fireVal)")
                }else{
                    print("Username: \(usernameVal) is not equal to \(fireVal)")
                }
                counter += 1
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
