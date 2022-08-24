//
//  firebaseStorage.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 29/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import FirebaseStorage

/***
 implementation of the network protocol using firebase storage
 */
class FirebaseStorage:NetworkingLibrary
{
    func sendFile(url: URL, path: String) {
        let storageReference = Storage.storage().reference()
        let DocumentRef = storageReference.child(path)
        
        DocumentRef.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkIfFileExist(url:URL, path:String,onComplete:@escaping (Bool)->Void){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let DocumentRef = storageRef.child(path)
        
        DocumentRef.write(toFile: url) { url, error in
            onComplete(error == nil)
        }
    }
}
