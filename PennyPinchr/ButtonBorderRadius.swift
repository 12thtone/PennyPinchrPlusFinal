//
//  ButtonBorderRadius.swift
//  PennyPinchr
//
//  Created by Matt Maher on 12/9/16.
//  Copyright © 2016 MMMD. All rights reserved.
//

import UIKit

class ButtonBorderRadius: UIButton {
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        
        layer.cornerRadius = 13
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }
}
