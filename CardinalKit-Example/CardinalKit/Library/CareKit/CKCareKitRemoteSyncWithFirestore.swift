//
//  CKCareKitRemoteSynchronizable.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import CareKitUI

class CKCareKitRemoteSyncWithFirestore: OCKRemoteSynchronizable {
    
    var delegate: OCKRemoteSynchronizationDelegate?
    
    var automaticallySynchronizes: Bool = true
    
    let collection: String = "carekit-store"
    let identifier: String = "v1"
    
    init() {
        delegate = self
    }
    
    func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
        
        // https://developer.apple.com/videos/play/wwdc2020/10151
        // Given a revision record, merge it into the store.
        getRevisionsFromFirestore { (revisions) in
            print("[pullRevisions] mergeRevision")
            let newRecord = self.createPullMergeRevisionRecord(revisions, knowledgeVector)
            mergeRevision(newRecord, completion)
        }
    }
    
    func pushRevisions(deviceRevision: OCKRevisionRecord, overwriteRemote: Bool, completion: @escaping (Error?) -> Void) {
        
        getRevisionsFromFirestore { (revisions) in
            print("[pushRevisions] mergeRevision")
            var newRevisions = revisions
            newRevisions.append(deviceRevision)
            let newRecord = self.createPushMergeRevisionRecord(newRevisions, deviceRevision.knowledgeVector)
            
            // This step will pass the revision record to server (GCP, Firestore).
            self.putRevisionInFirestore(deviceRevision: newRecord, true, completion)
        }
        
    }
    
    func chooseConflictResolutionPolicy(_ conflict: OCKMergeConflictDescription, completion: @escaping (OCKMergeConflictResolutionPolicy) -> Void) {
        // NOTE: depending on your project, you might want to change the resolution policy
        completion(.keepRemote)
    }
    
}

extension CKCareKitRemoteSyncWithFirestore {
    
    fileprivate func putRevisionInFirestore(deviceRevision: OCKRevisionRecord, _ overwriteRemote: Bool, _ completion: @escaping (Error?) -> Void) {
        do {
            let data = try JSONEncoder().encode(deviceRevision)
            let json = try CKSendHelper.jsonDataAsDict(data) ?? [String:Any]()
            
            CKSendHelper.appendCareKitArrayInFirestore(json: json, collection: collection, withIdentifier: identifier, overwriteRemote: overwriteRemote) { (success, error) in
                print("[putRevisionInFirestore] success \(success), error \(error?.localizedDescription ?? "")")
                completion(error)
            }
        } catch {
            print("[putRevisionInFirestore] " + error.localizedDescription)
            completion(error)
        }
    }
    
    fileprivate func getRevisionsFromFirestore(completion: @escaping (_ revisions: [OCKRevisionRecord]) -> Void) {
        CKSendHelper.getFromFirestore(collection: collection, identifier: identifier, onCompletion: { (document, error) in
            guard let document = document,
                  let payload = document.data()?["revisions"] else {
                completion([OCKRevisionRecord]())
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let revisions = try JSONDecoder().decode([OCKRevisionRecord].self, from: jsonData)
                completion(revisions)
            } catch {
                print("[getRevisionsFromFirestore] ERROR " + error.localizedDescription)
                completion([OCKRevisionRecord]())
            }
        })
    }
    
    fileprivate func createPullMergeRevisionRecord(_ revisions: [OCKRevisionRecord], _ knowledgeVector: OCKRevisionRecord.KnowledgeVector) -> OCKRevisionRecord {
        let newEntities = revisions.filter({ $0.knowledgeVector >= knowledgeVector }).flatMap({ $0.entities })
        
        var allKnowledge = OCKRevisionRecord.KnowledgeVector()
        for rev in revisions.map({ $0.knowledgeVector }) {
            allKnowledge.merge(with: rev)
        }
        
        let newRecord = OCKRevisionRecord(entities: newEntities, knowledgeVector: allKnowledge)
        return newRecord
    }
    
    fileprivate func createPushMergeRevisionRecord(_ revisions: [OCKRevisionRecord], _ knowledgeVector: OCKRevisionRecord.KnowledgeVector) -> OCKRevisionRecord {
        let newEntities = revisions.filter({ knowledgeVector >= $0.knowledgeVector }).flatMap({ $0.entities })
        
        var allKnowledge = knowledgeVector
        for rev in revisions.map({ $0.knowledgeVector }) {
            allKnowledge.merge(with: rev)
        }
        
        let newRecord = OCKRevisionRecord(entities: newEntities, knowledgeVector: allKnowledge)
        return newRecord
    }
    
}

extension CKCareKitRemoteSyncWithFirestore : OCKRemoteSynchronizationDelegate {
    
    func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
        CKCareKitManager.shared.coreDataStore.synchronize { (error) in
            print("[CKCareKitRemoteSyncWithFirestore][didRequestSynchronization] completed with error: \(error?.localizedDescription ?? "(none)")")
        }
    }
    
    func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
        print("[CKCareKitRemoteSyncWithFirestore][remote] progress: \(progress)")
    }
    
}
