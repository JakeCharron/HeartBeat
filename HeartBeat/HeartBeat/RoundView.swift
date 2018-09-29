//
//  RoundView.swift
//  HeartBeat
//
//  Created by JakeDev on 9/8/18.
//  Copyright © 2018 Jake Charron. All rights reserved.
//

import UIKit

class RoundView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCR(_value: cornerRadius)
        }
    }
    
    func refreshCR(_value: CGFloat) {
        layer.cornerRadius = _value
    }
    
    func sharedInit() {
        refreshCR(_value: cornerRadius)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
