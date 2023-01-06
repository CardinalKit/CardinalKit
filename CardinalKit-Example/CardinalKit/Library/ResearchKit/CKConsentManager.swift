//
//  CKConsentManager.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/5/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//

import Firebase
import ResearchKit

enum CKConsentError: Error {
    case urlError
    case saveError
    case uploadError
    case downloadError
}

class CKConsentManager {
    var consentFileName: String = {
        let config = CKPropertyReader(file: "CKConfiguration")
        return config.read(query: "Consent File Name") ?? "My Consent File"
    }()

    func uploadConsent(data: Data) async throws {
        let storageRef = Storage.storage().reference()

        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).first
        docURL = docURL?.appendingPathComponent("\(consentFileName).pdf")

        guard let url = docURL,
              let documentCollection = CKStudyUser.shared.authCollection else {
            throw CKConsentError.urlError
        }

        // Saves the PDF to a file locally and sets its location in User Defaults
        do {
            try data.write(to: url)
            UserDefaults.standard.set(url.path, forKey: "consentFormURL")
        } catch {
            throw CKConsentError.saveError
        }

        // Uploads the PDF file to Firebase Cloud Storage
        let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            documentRef.putFile(from: url, metadata: nil) { _, error in
                if error != nil {
                    continuation.resume(throwing: CKConsentError.uploadError)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func downloadConsent() async throws -> URL {
        guard let documentCollection = CKStudyUser.shared.authCollection else {
            throw CKConsentError.urlError
        }

        let storageRef = Storage.storage().reference()
        let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")

        guard let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).first else {
            throw CKConsentError.urlError
        }

        // Download the PDF file from Firebase Cloud Storage and save it locally
        let url = docURL.appendingPathComponent("\(consentFileName).pdf")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            documentRef.write(toFile: url) { _, error in
                if error != nil {
                    continuation.resume(throwing: CKConsentError.downloadError)
                } else {
                    UserDefaults.standard.set(url.path, forKey: "consentFormURL")
                    continuation.resume()
                }
            }
        }
        return url
    }

    func verifyConsent() async -> Bool {
        guard let documentCollection = CKStudyUser.shared.authCollection else {
            return false
        }

        let storageRef = Storage.storage().reference()
        let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")

        return await withCheckedContinuation { (continuation: CheckedContinuation) in
            documentRef.getMetadata { metadata, error in
                if error != nil {
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
