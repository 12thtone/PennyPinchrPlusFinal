//
//  ButtonBlackBorderRadius.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/10/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import UIKit

class ButtonBlackBorderRadius: UIButton {
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        
        layer.cornerRadius = 13
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
}
