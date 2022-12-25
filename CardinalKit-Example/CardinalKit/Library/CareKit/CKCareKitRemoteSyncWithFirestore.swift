//
//  CKCareKitRemoteSyncWithFirestore.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import CardinalKit
import CareKit
import CareKitStore
import CareKitUI
import FirebaseFirestore


class CKCareKitRemoteSyncWithFirestore: OCKRemoteSynchronizable {
    var delegate: OCKRemoteSynchronizationDelegate?
    var automaticallySynchronizes = true
    let collection = "carekit-store/v2/outcomes"
    
    init() {
        delegate = self
    }

    func pullRevisions(
        since knowledgeVector: OCKRevisionRecord.KnowledgeVector,
        mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void,
        completion: @escaping (Error?) -> Void
    ) {
        // https://developer.apple.com/videos/play/wwdc2020/10151
        // Given a revision record, merge it into the store.
        getRevisionsFromFirestore { outcomes in
            print("[pullRevisions] mergeRevision")
            let newRecord = self.createPullMergeRevisionRecord(outcomes, knowledgeVector)
            mergeRevision(newRecord, completion)
        }
    }
    
    func pushRevisions(
        deviceRevision: OCKRevisionRecord,
        overwriteRemote: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        getRevisionsFromFirestore { outcomes in
            print("[pushRevisions] mergeRevision")
            var newRevisions = outcomes
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

// swiftlint:disable function_body_length closure_body_length cyclomatic_complexity
extension CKCareKitRemoteSyncWithFirestore {
    fileprivate func putRevisionInFirestore(
        deviceRevision: OCKRevisionRecord,
        _ overwriteRemote: Bool,
        _ completion: @escaping (Error?) -> Void
    ) {
        do {
            var outcomesNotDeleted: [String] = []
            let group = DispatchGroup()
            var error: Error?

            for entity in deviceRevision.entities {
                group.enter()

                let entityData = try JSONEncoder().encode(entity)
                let entityJson = try JSONSerialization.jsonObject(
                    with: entityData,
                    options: []
                ) as? [String: Any] ?? [String: Any]()

                guard var jsonResult = entityJson["object"] as? [String: Any] else {
                    return
                }

                jsonResult["type"] = entityJson["type"]

                if jsonResult["type"] as? String == "outcome",
                   let taskUUID = jsonResult["taskUUID"] as? String,
                   let uuid = UUID(uuidString: taskUUID),
                   let ocurrencyIndex = jsonResult["taskOccurrenceIndex"] {
                    var query = OCKTaskQuery()
                    query.uuids.append(uuid)

                    CKCareKitManager.shared.coreDataStore.fetchAnyTasks(query: query, callbackQueue: .main, completion: { result in
                        var id = "id"
                        switch result {
                        case .failure(let error):
                            print("Error: \(error)")
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

                        if jsonResult["deletedDate"] == nil {
                            outcomesNotDeleted.append(uuid)
                        } else {
                            if !outcomesNotDeleted.contains(uuid) {
                                outcomesNotDeleted.append(uuid)
                            } else {
                                add = false
                            }
                        }

                        if add {
                            guard let authCollection = CKStudyUser.shared.authCollection else {
                               return
                           }
                           
                           let route = "\(authCollection)\(self.collection)/\(uuid)"
                           
                           CKApp.sendData(route: route, data: jsonResult, params: nil, onCompletion: { success, error in
                               print("[putRevisionInFirestore] success \(success), error \(error?.localizedDescription ?? "")")
                               group.leave()
                           })
                        } else {
                            group.leave()
                        }
                    })
                } else {
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
    
    fileprivate func getRevisionsFromFirestore(completion: @escaping (_ outcomes: [OCKRevisionRecord]) -> Void) {
        guard let authCollection = CKStudyUser.shared.authCollection else {
            return
        }

        let authRoute = authCollection + "\(collection)"

        CKApp.requestData(route: authRoute, onCompletion: { result in
            if let documents = result as? [DocumentSnapshot] {
                guard !documents.isEmpty else {
                    completion([OCKRevisionRecord]())
                    return
                }

                let group = DispatchGroup()
                var outcomes = [CareKitStore.OCKEntity]()

                for document in documents {
                    group.enter()
                    
                    guard let authCollection = CKStudyUser.shared.authCollection else {
                        return
                    }

                    let route = "\(authCollection)\(self.collection)/\(document.documentID)"

                    CKApp.requestData(route: route, onCompletion: { result in
                        guard let document = result as? DocumentSnapshot,
                              var payload = document.data(),
                              !payload.isEmpty else {
                                completion([OCKRevisionRecord]())
                                return
                        }
                        payload["updatedAt"] = nil
                        if let type = payload["type"],
                           type as? String == "outcome",
                           let id = payload["taskId"] as? String {
                            payload.removeValue(forKey: "type")
                            var query = OCKTaskQuery()
                            query.ids.append(id)

                            CKCareKitManager.shared.coreDataStore.fetchAnyTasks(query: query, callbackQueue: .main, completion: { result in
                                switch result {
                                case .failure(let error):
                                do {
                                    print("Error: \(error)")
                                    group.leave()
                                }
                                case .success(let tasks):
                                    if tasks.count == 1 {
                                        payload["taskUUID"] = tasks[0].uuid?.uuidString ?? UUID().uuidString
                                        var object = [String: Any]()
                                        object["object"] = payload
                                        object["type"] = type
                                        do {
                                            let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
                                            let entity = try JSONDecoder().decode(CareKitStore.OCKEntity.self, from: jsonData)
                                            outcomes.append(entity)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    group.leave()
                                }
                            })
                        } else {
                            group.leave()
                        }
                    })
                }
                group.notify(queue: .main, execute: {
                    let knowledgeVector = OCKRevisionRecord.KnowledgeVector()
                    completion(
                        [OCKRevisionRecord(entities: outcomes, knowledgeVector: knowledgeVector)]
                    )
                })
            }
        })
    }
    
    fileprivate func createPullMergeRevisionRecord(
        _ revisions: [OCKRevisionRecord],
        _ knowledgeVector: OCKRevisionRecord.KnowledgeVector
    ) -> OCKRevisionRecord {
        let newEntities = revisions.filter {
            $0.knowledgeVector >= knowledgeVector
        }
        .flatMap {
            $0.entities
        }
        
        var allKnowledge = OCKRevisionRecord.KnowledgeVector()
        for rev in revisions.map({ $0.knowledgeVector }) {
            allKnowledge.merge(with: rev)
        }
        
        let newRecord = OCKRevisionRecord(entities: newEntities, knowledgeVector: allKnowledge)
        return newRecord
    }
    
    fileprivate func createPushMergeRevisionRecord(
        _ revisions: [OCKRevisionRecord],
        _ knowledgeVector: OCKRevisionRecord.KnowledgeVector
    ) -> OCKRevisionRecord {
        let newEntities = revisions.filter {
            knowledgeVector >= $0.knowledgeVector
        }
        .flatMap {
            $0.entities
        }
        
        var allKnowledge = knowledgeVector
        for rev in revisions.map({ $0.knowledgeVector }) {
            allKnowledge.merge(with: rev)
        }
        
        let newRecord = OCKRevisionRecord(entities: newEntities, knowledgeVector: allKnowledge)
        return newRecord
    }
}

extension CKCareKitRemoteSyncWithFirestore: OCKRemoteSynchronizationDelegate {
    func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
        CKCareKitManager.shared.coreDataStore.synchronize { error in
            print("[CKCareKitRemoteSyncWithFirestore][didRequestSynchronization] completed with error: \(error?.localizedDescription ?? "(none)")")
        }
    }
    
    func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
        print("[CKCareKitRemoteSyncWithFirestore][remote] progress: \(progress)")
    }
}
