//
//  CKCareKitRemoteSynchronizable.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore
import CareKitUI

class CKCareKitRemoteSynchronizable: OCKRemoteSynchronizable {
    
    var delegate: OCKRemoteSynchronizationDelegate?
    
    var automaticallySynchronizes: Bool = true
    
    let collection: String = "carekit-store"
    let identifier: String = "v1"
    
    init() {
        delegate = self
    }
    
    func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
        
        // https://developer.apple.com/videos/play/wwdc2020/10151
        // TODO: send knowledgeVector to server & use to exchange for a OCKRevisionRecord.
        // let data = try JSONEncoder().encode(knowledgeVector)
        
        // Given a revision record, merge it into the store.
        CKSendHelper.getFromFirestore(collection: collection, identifier: identifier, onCompletion: { (document, error) in
            guard let document = document,
                  let payload = document.data()?["payload"] else {
                completion(error)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let revision = try JSONDecoder().decode(OCKRevisionRecord.self, from: jsonData)
                print("[pullRevisions] mergeRevision")
                mergeRevision(revision, completion)
            } catch {
                print("[pullRevisions] ERROR " + error.localizedDescription)
                completion(error)
            }
        })
    }
    
    func pushRevisions(deviceRevision: OCKRevisionRecord, overwriteRemote: Bool, completion: @escaping (Error?) -> Void) {
        
        // This step will pass the revision record to server (GCP, Firestore).
        do {
            let data = try JSONEncoder().encode(deviceRevision)
            try CKSendHelper.sendToFirestore(data: data, collection: collection, withIdentifier: identifier, onCompletion: { (success, error) in
                print("[pushRevisions] success: \(success)")
                completion(error)
            })
        } catch {
            print(error)
            completion(error)
        }
    }
    
    func chooseConflictResolutionPolicy(_ conflict: OCKMergeConflictDescription, completion: @escaping (OCKMergeConflictResolutionPolicy) -> Void) {
        completion(.keepRemote)
    }
    
}

extension CKCareKitRemoteSynchronizable : OCKRemoteSynchronizationDelegate {
    
    func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
        // no server action
    }
    
    func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
        // no server action
    }
    
}
