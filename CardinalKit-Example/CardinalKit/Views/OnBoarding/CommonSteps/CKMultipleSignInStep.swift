//
//  CKMultipleSignInStep.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 25/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ResearchKit
import CardinalKit
import SwiftUI

public class CKMultipleSignInStep: ORKQuestionStep{
    public override init(
        identifier: String
    ) {
        super.init(identifier: identifier)
        self.answerFormat = ORKAnswerFormat.booleanAnswerFormat()
    }

    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class CKMultipleSignInStepViewController: ORKQuestionStepViewController{
    public var CKMultipleSignInStep: CKMultipleSignInStep!{
        return step as? CKMultipleSignInStep
    }
    
    let authLibrary = Libraries.shared.authlibrary
    
    public override func viewDidLoad() {
        
        ///Sign in label
        let signInLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 450, height: 50 ))
        signInLabel.center.x = view.center.x
        signInLabel.text = "Sign In"
        signInLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(signInLabel)
        
        let config = CKPropertyReader(file: "CKConfiguration")
        var button:UIButton? = nil
        if config["Login-Sign-In-With-UserPassword"]["Enabled"] as? Bool == true {
            let buttonUserPassWord = CustomButton(title: "Sign in with User and Password", backGroundColor: .white, textColor: .black, borderColor: .black, reference: button, action: #selector(loginUserAndPaswwordAction))
            self.view.addSubview(buttonUserPassWord)
            button = buttonUserPassWord
            
        }
        
        if config["Login-Sign-In-With-Facebook"]["Enabled"] as? Bool == true {
            let buttonFacebook = CustomButton(title: "Sign in with Facebook", backGroundColor: UIColor(red: 59, green: 89, blue: 152), textColor: .white, borderColor: nil, reference: button, action: #selector(loginFacebookAction), WithAttachement: "facebook", imageOffset: 35)
            self.view.addSubview(buttonFacebook)
            button = buttonFacebook
        }
        
        if config["Login-Sign-In-With-Google"]["Enabled"] as? Bool == true {
            let buttonGoogle = CustomButton(title: "Sign in with Google", backGroundColor: .white, textColor: .gray, borderColor: UIColor(red: 66, green: 133, blue: 244), reference: button, action: #selector(loginGoogleAction),WithAttachement: "google")
            self.view.addSubview(buttonGoogle)
            button = buttonGoogle
        }
        
        if config["Login-Sign-In-With-Apple"]["Enabled"] as? Bool == true {
            let buttonApple = CustomButton(title: "Sign in with Apple", backGroundColor: .black, textColor: .white, borderColor: nil, reference: button, action: #selector(loginAppleAction),WithAttachement: "apple")
            self.view.addSubview(buttonApple)
            button = buttonApple
        }
        
        self.view.backgroundColor = .white
    }
    
    public func CustomButton(
        title:String,
        backGroundColor:UIColor,
        textColor:UIColor,
        borderColor:UIColor?,
        reference:UIButton?,
        action: Selector,
        WithAttachement image:String="",
        imageOffset:CGFloat = 50
    )->UIButton{
        let button = UIButton(frame: CGRect(x: 200, y: 200, width: 350, height: 50))
        button.center = view.center
        if let reference = reference {
            button.center.y = reference.center.y - 60
        }
        else{
            button.center.y = CGFloat(Float(view.frame.maxY) - 200)
        }
        button.setTitle(title, for: .normal)
        
        button.setTitleColor(textColor,for: .normal)
        button.addTarget(self,action: action,for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.backgroundColor = backGroundColor
        if let borderColor=borderColor{
            button.layer.borderWidth = 2
            button.layer.borderColor =  borderColor.cgColor
        }
        if(image != ""){
            button.setImage(UIImage(named: image)!, for: .normal)
            button.imageEdgeInsets.left = -imageOffset
        }
        return button
    }
    
    @objc
    func loginUserAndPaswwordAction(){
        self.setAnswer(true)
        super.goForward()
    }
    
    @objc
    func loginFacebookAction(sender: AnyObject) {//action of the custom button in the storyboard
        authLibrary.LoginWithFacebook(onSuccess: {
            self.setAnswer(false)
            super.goForward()
        }, onError: { error in
            self.showError(error)
        }, viewController: self)
    }
    
    private var currentNonce: String!
    
    @objc
    func loginAppleAction() {
        authLibrary.LoginWithApple(
            onSuccess: {
                self.setAnswer(false)
                super.goForward()
            }, onError: { error in
                self.showError(error)
            }
        )
    }
   
    
    
    @objc
    func loginGoogleAction(){
        authLibrary.LoginWithGoogle(onSuccess: {
            self.setAnswer(false)
            super.goForward()
        }, onError: { error in
            self.showError(error)
        }, viewController: self)
    
    }
    
    private func showError(_ error: Error) {
        // with your request to Google.
        print("Sign in with Google errored: \(error)")
        Alerts.showInfo(
            title: NSLocalizedString("Failed to Sign in with Google", comment: ""),
            message: error.localizedDescription
        )
    }
}


