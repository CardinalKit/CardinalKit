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
import CardinalKit
import FirebaseFirestore

class CKCareKitRemoteSyncWithFirestore: OCKRemoteSynchronizable {
    func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord) -> Void, completion: @escaping (Error?) -> Void) {
        getRevisionsFromFirestore { (outComes) in
            print("[pullRevisions] mergeRevision")
            let newRecord = self.createPullMergeRevisionRecord(outComes, knowledgeVector)
            mergeRevision(newRecord)
            completion(nil)
        }
    }
    
    func pushRevisions(deviceRevision: OCKRevisionRecord, completion: @escaping (Error?) -> Void) {
        getRevisionsFromFirestore { (outComes) in
            print("[pushRevisions] mergeRevision")
            var newRevisions = outComes
            newRevisions.append(deviceRevision)
            let newRecord = self.createPushMergeRevisionRecord(newRevisions, deviceRevision.knowledgeVector)

            // This step will pass the revision record to server (GCP, Firestore).
            self.putRevisionInFirestore(deviceRevision: newRecord, true, completion)
        }
    }
    
    
    var delegate: OCKRemoteSynchronizationDelegate?
    
    var automaticallySynchronizes: Bool = true
    
    let collection: String = "carekit-store/v2/outcomes"
    
    init() {
        delegate = self
    }
    
    func chooseConflictResolution(conflicts: [OCKEntity], completion: @escaping OCKResultClosure<OCKEntity>) {
        // TODO: what entity need choose?
        completion(.success(conflicts[0]))
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
                let entityJson = try JSONSerialization.jsonObject(with: entityData, options: []) as? [String : Any] ?? [String:Any]()
                var jsonResult:[String:Any] = entityJson["object"] as! [String : Any]
                jsonResult["type"]=entityJson["type"]
                 if  jsonResult["type"] as? String == "outcome",
                   let taskUUID = jsonResult["taskUUID"] as? String,
                   let ocurrencyIndex = jsonResult["taskOccurrenceIndex"]
                {
                    var query = OCKTaskQuery()
                    query.uuids.append(UUID(uuidString: taskUUID)!)
                     CKCareKitManager.shared.coreDataStore.fetchAnyTasks(query: query, callbackQueue: DispatchQueue.main, completion: {(result) in
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
                            guard let authCollection = CKStudyUser.shared.authCollection else {
                               return
                           }
                           
                           let route = "\(authCollection)\(self.collection)/\(uuid)"
                           
                           CKApp.sendData(route: route, data: jsonResult, params: nil, onCompletion: { (success, _error) in
                               print("[putRevisionInFirestore] success \(success), error \(_error?.localizedDescription ?? "")")
                               if let _error = _error{
                                   error = _error
                               }
                               group.leave()
                           })
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
        guard let authCollection = CKStudyUser.shared.authCollection else {
            return
        }
        let authRoute = authCollection + "\(collection)"
        CKApp.requestData(route: authRoute, onCompletion: { result in
            if let documents = result as? [DocumentSnapshot]{
                guard documents.count>0 else {
                    completion([OCKRevisionRecord]())
                    return
                }
                let group = DispatchGroup()
                var outComes = [CareKitStore.OCKEntity]()
                for document in documents{
                    group.enter()
                    
                    guard let authCollection = CKStudyUser.shared.authCollection else {
                        return
                    }
                    let route = "\(authCollection)\(self.collection)/\(document.documentID)"
                    CKApp.requestData(route: route, onCompletion: {
                        result in
                        guard let document = result as? DocumentSnapshot,
                              var payload = document.data(),
                              payload.count>0
                        else{
                            completion([OCKRevisionRecord]())
                            return
                        }
                        
//                        payload.removeValue(forKey: "updatedAt")
                        payload["updatedAt"] = nil
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
                                        payload["taskUUID"] = tasks[0].uuid.uuidString
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
                    })                    
                }
                group.notify(queue: .main, execute: {
                    let KnowledgeVector = OCKRevisionRecord.KnowledgeVector()
                    completion(
                        [OCKRevisionRecord(entities: outComes, knowledgeVector: KnowledgeVector)]
                    )
                })

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
