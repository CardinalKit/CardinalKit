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
    
    let collection: String = "carekit-store/v2/entities"
    
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
            var outComesNotDeleted:[String]=[]
            let group = DispatchGroup()
            var error:Error? = nil
            for entity in deviceRevision.entities{
                group.enter()
                let entityData = try JSONEncoder().encode(entity)
                let entityJson = try CKSendHelper.jsonDataAsDict(entityData) ?? [String:Any]()
                var jsonResult:[String:Any] = entityJson["object"] as! [String : Any]
                jsonResult["type"]=entityJson["type"]
                if var uuid = jsonResult["uuid"] as? String
                {
                    var add = true
                    if jsonResult["type"] as? String == "outcome",
                       let taskUUID = jsonResult["taskUUID"] as? String,
                       let ocurrencyIndex = jsonResult["taskOccurrenceIndex"]{
                        uuid = "outcome \(taskUUID) \(ocurrencyIndex)"
                        if jsonResult["deletedDate"] == nil{
                            outComesNotDeleted.append(uuid)
                        }
                        else{
                            if !outComesNotDeleted.contains(uuid){
                                outComesNotDeleted.append(uuid)
                            }
                            else{
                                add = false
                            }
                        }
                    }
                    if(add){
                        CKSendHelper.appendCareKitArrayInFirestore(json: jsonResult, collection: "\(collection)", withIdentifier: uuid, overwriteRemote: overwriteRemote) { (success, _error) in
                            print("[putRevisionInFirestore] success \(success), error \(_error?.localizedDescription ?? "")")
                            if let _error = _error{
                                error = _error
                            }
                            group.leave()
                        }
                    }
                }
                
            }
            group.notify(queue: .main, execute: {
                    completion(error)
                })
        } catch {
            print("[putRevisionInFirestore] " + error.localizedDescription)
            completion(error)
        }
    }
    
    fileprivate func getRevisionsFromFirestore(completion: @escaping (_ revisions: [OCKRevisionRecord]) -> Void) {
        CKSendHelper.getFromFirestore(collection: collection, onCompletion: { [self] (documents, error) in
            guard let documents = documents,
                  documents.count>0 else {
                completion([OCKRevisionRecord]())
                return
            }
            let group = DispatchGroup()
            var entities = [CareKitStore.OCKEntity]()
            for document in documents{
                group.enter()
                CKSendHelper.getFromFirestore(collection: self.collection, identifier: document.documentID) { (document, error) in
                    group.leave()
                    do{
                        guard let document = document,
                              var payload = document.data() else {
                                completion([OCKRevisionRecord]())
                            return
                        }
                        payload.removeValue(forKey: "updatedAt")
                        let type = payload["type"]!
                        payload.removeValue(forKey: "type")
                        
                        var object = [String:Any]()
                        object["object"] = payload
                        object["type"] = type
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
                        let entity = try JSONDecoder().decode(CareKitStore.OCKEntity.self, from: jsonData)
                        entities.append(entity)
                        
                    }
                    catch {
                        print("[getRevisionsFromFirestore] ERROR " + error.localizedDescription)
                        completion([OCKRevisionRecord]())
                    }
                }
            }
            group.notify(queue: .main, execute: {
                completion([OCKRevisionRecord(entities: entities, knowledgeVector: OCKRevisionRecord.KnowledgeVector())])
            })
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
