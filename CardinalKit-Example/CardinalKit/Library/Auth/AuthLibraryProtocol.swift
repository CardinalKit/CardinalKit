//
//  AuthLibraryProtocol.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 28/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

protocol AuthLibrary {
    var user:User? {get}
    func LoginWithFacebook(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void, viewController: UIViewController)
    func LoginWithGoogle(onSuccess:@escaping () -> Void, onError:@escaping (Error) -> Void, viewController:UIViewController)
    func LoginWithApple(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func logout(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func RegisterUser(email:String, pass:String, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func LoginIWithUserPass(email:String, pass:String, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func ResetPassword(email:String,onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
}
