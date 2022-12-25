//
//  CKTaskViewControllerDelegate.swift
//  CareKit Sample
//
//  Created by Santiago Gutierrez on 2/14/21.
//

import CardinalKit
import CareKit
import Firebase
import Foundation
import ResearchKit


class CKUploadToGCPTaskViewControllerDelegate: NSObject, ORKTaskViewControllerDelegate {
    /// Serializes the result of a ResearchKit task into JSON and uploads it to Firebase
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason,
        error: Error?
    ) {
        switch reason {
        case .completed:
            do {
                // (1) convert the result of the ResearchKit task into a JSON dictionary
                guard let task = taskViewController.task else {
                    return
                }

                if let json = try CKORKSerialization.CKTaskAsJson(
                    result: taskViewController.result,
                    task: task
                ) {
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
            fallthrough
        default:
            taskViewController.dismiss(animated: false, completion: nil)
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
            let documentsDirectory = try defaultFileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.appendingPathComponent(
                taskViewController.taskRunUUID.uuidString
            )
            try defaultFileManager.createDirectory(
                at: outputDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )

            return outputDirectory
        } catch let error as NSError {
            print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
        }

        return nil
    }

    /**
     Parse a result from a ResearchKit task and convert to a dictionary.
     JSON-friendly.

     - Parameters:
     - result: original `ORKTaskResult`
     - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
     */
    func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String: Any]? {
        let jsonData = try ORKESerializer.jsonData(for: result)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
    }

    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
     */
    func CKSendJSON(_ json: [String: Any]) throws {
        let identifier = (json["identifier"] as? String) ?? UUID().uuidString

        guard let authCollection = CKStudyUser.shared.authCollection,
              let userId = CKStudyUser.shared.currentUser?.uid else {
            return
        }
        let route = "\(authCollection)\(Constants.dataBucketSurveys)/\(identifier)"

        CKApp.sendData(
            route: route,
            data: ["results": FieldValue.arrayUnion([json])],
            params: [
                "userId": userId,
                "merge": true
            ]
        )
    }

    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
     */
    func CKSendFiles(_ files: URL, result: [String: Any]) throws {
        if  let collection = result["identifier"] as? String,
            let taskUUID = result["taskRunUUID"] as? String {
            try CKSendHelper.sendToCloudStorage(
                files,
                collection: collection,
                withIdentifier: taskUUID
            )
        }
    }
}
