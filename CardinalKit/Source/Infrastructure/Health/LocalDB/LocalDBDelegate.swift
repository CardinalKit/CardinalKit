//
//  LocalDBDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol CKLocalDBDelegate{
    func configure()
}

public class CKLocalDB{
    
}

extension CKLocalDB:CKLocalDBDelegate{
    public func configure() {
        // Using Realm as local Db
        _ = RealmManager.shared.configure()
    }
}

