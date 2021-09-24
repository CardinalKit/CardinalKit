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
    
    let collection: String = "carekit-store/v2/outcomes"
    
    init() {
        delegate = self
    }
    
    
    func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
        
        // https://developer.apple.com/videos/play/wwdc2020/10151
        // Given a revision record, merge it into the store.
        getRevisionsFromFirestore { (outComes) in
            print("[pullRevisions] mergeRevision")
            let newRecord = self.createPullMergeRevisionRecord(outComes, knowledgeVector)
            mergeRevision(newRecord, completion)
        }
    }
    
    func pushRevisions(deviceRevision: OCKRevisionRecord, overwriteRemote: Bool, completion: @escaping (Error?) -> Void) {
        
        getRevisionsFromFirestore { (outComes) in
            print("[pushRevisions] mergeRevision")
            var newRevisions = outComes
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
                 if  jsonResult["type"] as? String == "outcome",
                   let taskUUID = jsonResult["taskUUID"] as? String,
                   let ocurrencyIndex = jsonResult["taskOccurrenceIndex"]
                {
                    var query = OCKTaskQuery()
                    query.uuids.append(UUID(uuidString: taskUUID)!)
                    CKCareKitManager.shared.coreDataStore.fetchAnyTasks(query: query, callbackQueue: .main, completion: {(result) in
                        var id = "id"
                        switch result{
                        case .failure(let error): print("Error: \(error)")
                        case .success(let tasks):
                            guard tasks.count == 1 else {
                                group.leave()
                                return
                            }
                            id = tasks[0].id
                            jsonResult["taskId"] = id
                        }
                        
                        var add = true
                        let uuid = "\(id)-\(ocurrencyIndex)"
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
                        if add{
                            CKSendHelper.appendCareKitArrayInFirestore(json: jsonResult, collection: "\(self.collection)", withIdentifier: uuid, overwriteRemote: overwriteRemote) { (success, _error) in
                                print("[putRevisionInFirestore] success \(success), error \(_error?.localizedDescription ?? "")")
                                if let _error = _error{
                                    error = _error
                                }
                                group.leave()
                            }
                        }
                        else{
                            group.leave()
                        }
                        
                    })
                    
                    
                }
                else{
                    group.leave()
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
    
    fileprivate func getRevisionsFromFirestore(completion: @escaping (_ outComes:[OCKRevisionRecord]) -> Void) {
        CKSendHelper.getFromFirestore(collection: collection, onCompletion: { [self] (documents, error) in
            guard let documents = documents,
                  documents.count>0 else {
                completion([OCKRevisionRecord]())
                return
            }
            let group = DispatchGroup()
            var outComes = [CareKitStore.OCKEntity]()
            for document in documents{
                group.enter()
                CKSendHelper.getFromFirestore(collection: self.collection, identifier: document.documentID) { (document, error) in
                    guard let document = document,
                          var payload = document.data(),
                          payload.count>0 else {
                        completion([OCKRevisionRecord]())
                        return
                    }
                    payload.removeValue(forKey: "updatedAt")
                    if let type = payload["type"],
                        type as?String == "outcome",
                       let id = payload["taskId"] as? String{
                        
                        payload.removeValue(forKey: "type")
                        var query = OCKTaskQuery()
                        query.ids.append(id)
                        CKCareKitManager.shared.coreDataStore.fetchAnyTasks(query: query, callbackQueue: .main, completion: {(result) in
                            switch result{
                            case .failure(let error):do {
                                print("Error: \(error)")
                                group.leave()
                            }
                            case .success(let tasks):
                                if tasks.count == 1{
                                    payload["taskUUID"] = tasks[0].uuid!.uuidString
                                    var object = [String:Any]()
                                    object["object"] = payload
                                    object["type"] = type
                                    do{
                                        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
                                        let entity = try JSONDecoder().decode(CareKitStore.OCKEntity.self, from: jsonData)
                                        outComes.append(entity)
                                    }
                                    catch{
                                        
                                    }
                                }
                                group.leave()
                            }
                        })
                    }
                    else{
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main, execute: {
                let KnowledgeVector = OCKRevisionRecord.KnowledgeVector()
                completion(
                    [OCKRevisionRecord(entities: outComes, knowledgeVector: KnowledgeVector)]
                )
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
