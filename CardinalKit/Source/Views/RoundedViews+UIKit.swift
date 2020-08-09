//
//  RoundedViews+UIKit.swift
//  CS342 Library
//
//  Created by Santiago Gutierrez on 9/1/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit

@IBDesignable
public class RoundedButton: UIButton {
    
    @IBInspectable
    var enabledColor: UIColor = UIColor.radicalRed
    
    @IBInspectable
    var disabledColor: UIColor = UIColor.altoGrey
    
    @IBInspectable
    var cornerRadius: CGFloat = 7
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        if isEnabled {
            enable()
        } else {
            disable()
        }
        
    }
    
    public func enable() {
        self.backgroundColor = enabledColor
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.isEnabled = true
    }
    
    public func disable() {
        self.backgroundColor = disabledColor
        self.setTitleColor(UIColor.darkGray, for: UIControl.State())
        self.isEnabled = false
    }
    
}

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable
    var drawBorder: Bool = false
    
    @IBInspectable
    var borderWidth: CGFloat = 1.0
    
    @IBInspectable
    var cornerRadius: CGFloat = 7
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        if drawBorder {
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
    
}

@IBDesignable
class CircleView: UIView {
    
    @IBInspectable
    var drawBorder: Bool = false
    
    @IBInspectable
    var borderWidth: CGFloat = 1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.bounds.size.width * 0.5
        self.clipsToBounds = true
        
        if drawBorder {
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
    
}
