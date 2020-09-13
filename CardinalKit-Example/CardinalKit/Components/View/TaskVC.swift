//
//  TaskVC.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/13/20.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI
import Firebase
import ResearchKit

struct TaskVC: UIViewControllerRepresentable {

    let vc: ORKTaskViewController

    init(tasks: ORKOrderedTask) {
        self.vc = ORKTaskViewController(task: tasks, taskRun: NSUUID() as UUID)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {

        if vc.outputDirectory == nil {
            vc.outputDirectory = context.coordinator.CKGetTaskOutputDirectory(vc)
        }

        self.vc.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below

        // & present the VC!
        return self.vc

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

    }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            defer { taskViewController.dismiss(animated: true, completion: nil) }
            guard case .completed = reason else { return }
            do {
                // (1) convert the result of the ResearchKit task into a JSON dictionary
                if let json = try CKTaskResultAsJson(taskViewController.result) {

                    // (2) send using Firebase
                    try CKSendJSON(json)

                    // (3) if we have any files, send those using Google Storage
                    if let associatedFiles = taskViewController.outputDirectory {
                        try CKSendFiles(associatedFiles, result: json)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        /**
         Create an output directory for a given task.
         You may move this directory.

         - Returns: URL with directory location
         */
        func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
            do {
                let defaultFileManager = FileManager.default

                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)

                return outputDirectory
            } catch {
                print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
                return nil
            }
        }

        /**
         Parse a result from a ResearchKit task and convert to a dictionary.
         JSON-friendly.

         - Parameters:
         - result: original `ORKTaskResult`
         - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
         */
        func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
            let jsonData = try ORKESerializer.jsonData(for: result)
            return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
        }

        /**
         Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
         */
        func CKSendJSON(_ json: [String:Any]) throws {

            if  let identifier = json["identifier"] as? String,
                let taskUUID = json["taskRunUUID"] as? String,
                let authCollection = CKStudyUser.shared.authCollection,
                let userId = CKStudyUser.shared.currentUser?.uid {

                let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]

                // If using the CardinalKit GCP instance, the authCollection
                // represents the directory that you MUST write to in order to
                // verify and access this data in the future.

                let db = Firestore.firestore()
                db.collection(authCollection + "\(Constants.dataBucketSurveys)")
                    .document(identifier + "-" + taskUUID).setData(dataPayload) { err in

                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("Document successfully written!")
                    }
                }

            }
        }

        /**
         Given a file, use the Firebase SDK to store it in Google Storage.
         */
        func CKSendFiles(_ files: URL, result: [String:Any]) throws {
            if  let identifier = result["identifier"] as? String,
                let taskUUID = result["taskRunUUID"] as? String,
                let stanfordRITBucket = CKStudyUser.shared.authCollection {

                let fileManager = FileManager.default
                let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)

                for file in fileURLs {

                    var isDir : ObjCBool = false
                    guard FileManager.default.fileExists(atPath: file.path, isDirectory: &isDir) else {
                        continue //no file exists
                    }

                    if isDir.boolValue {
                        try CKSendFiles(file, result: result) //cannot send a directory, recursively iterate into it
                        continue
                    }

                    let storageRef = Storage.storage().reference()
                    let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")

                    let uploadTask = ref.putFile(from: file, metadata: nil)

                    uploadTask.observe(.success) { snapshot in
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("File uploaded successfully!")
                    }

                    uploadTask.observe(.failure) { snapshot in
                        print("Error uploading file!")
                        guard let error = snapshot.error.flatMap({
                            StorageErrorCode(rawValue: $0._code)
                        }) else { return }

                        switch error {
                        case .objectNotFound, .bucketNotFound, .projectNotFound:
                            print("Not Found")
                        case .unauthenticated, .unauthorized, .nonMatchingChecksum, .invalidArgument:
                            print("Not legit")
                        case .quotaExceeded, .retryLimitExceeded, .downloadSizeExceeded:
                            print("Too much")
                        case .cancelled:
                            print("Cancelled")
                        case .unknown:
                            fallthrough
                        @unknown default:
                            print("Reason Unknown")
                        }
                    }
                }
            }
        }
    }
}
struct TaskVC_Previews: PreviewProvider {
    static var previews: some View {
        TaskVC(tasks: ORKOrderedTask(identifier: "Test", steps: []))
    }
}
