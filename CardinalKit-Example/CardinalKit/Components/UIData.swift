//
//  UIData.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Combine
import Foundation
import FirebaseFirestore

struct Notification: Identifiable {
    let id = UUID()
    let dateSent = Date()
    let testName: String
    let text: String
    let action: Bool
}

struct Result: Identifiable {
    let id = UUID()
    let testName: String
    let scores: [Double]
}

class NotificationsAndResults: ObservableObject {
    @Published var currNotifications: [Notification]
    @Published var upcomingNotifications: [Notification]
    @Published var results: [Result] = []

    init() {
        currNotifications = [
            Notification(testName: "User Survey", text: "is ready to be taken", action: true),
            Notification(testName: "Trailmaking B", text: "is ready to be taken", action: true)
        ]
        upcomingNotifications = [
            Notification(testName: "Trailmaking A", text: "test can be taken starting 'Date'", action: false),
            Notification(testName: "Spatial Memory", text: "test is coming up 'Date', please consume a moderate amount of caffine only", action: false),
            Notification(testName: "Amsler Grid", text: "test is coming up 'Date', please be mindful of eyes usage", action: false)
        ]
        guard let authCollection = CKStudyUser.shared.authCollection else {
            fatalError("Not signed in")
        }
        let db = Firestore.firestore()
        listener = db.collection(authCollection + "\(Constants.dataBucketSurveys)")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return
                }
                let studies: [Study] = snapshot.documents.compactMap { document in
                    let payload = document.data()["payload"] as! [String: Any]
                    switch payload["identifier"] as! String {
                    case "Trail making A":
                        return .trailA(
                            info: Info(payload),
                            numberOfErrors: (payload["results"] as! [Dict]).lazy
                                .filter { $0["identifier"] as! String == "trailmaking" }
                                .flatMap {
                                    ($0["results"] as! [Dict]).lazy
                                        .compactMap { $0["numberOfErrors"] as? Int }
                                }
                                .first!
                        )
                    case "Trail making B":
                        return .trailB(
                            info: Info(payload),
                            numberOfErrors: (payload["results"] as! [Dict]).lazy
                                .filter { $0["identifier"] as! String == "trailmaking" }
                                .flatMap {
                                    ($0["results"] as! [Dict]).lazy
                                        .compactMap { $0["numberOfErrors"] as? Int }
                                }
                                .first!
                        )
                    case "Speech Recognition":
                        return .speech(
                            info: Info(payload),
                            text: (payload["results"] as! [Dict]).lazy
                                .filter { $0["identifier"] as! String == "speech.recognition" }
                                .flatMap {
                                    ($0["results"] as! [Dict]).lazy
                                        .compactMap { $0["transcription"] as? Dict }
                                        .compactMap { $0["formattedString"] as? String }
                                }
                                .first!
                        )
                    case "Amsler Grid":
                        return nil
                    case "Survey":
                        return .survey(info: Info(payload))
                    default:
                        print(payload)
                        return nil
                    }
                }

                self.results = studies.lazy
                    .filter { $0.score != nil }
                    .grouped { $0.name }
                    .map { (key, value) in
                        Result(
                            testName: key,
                            scores: value
                                .sorted { $0.date < $1.date }
                                .map { floor($0.score! * 100) / 10 }
                        )
                    }
                    .sorted { $0.testName < $1.testName }
            }
    }
    
    func getTestIndex(testName: String) -> Int {
        switch testName {
            case "User Survey": return 0
            case "Trailmaking A": return 1
            case "Trailmaking B": return 2
            case "Spatial Memory": return 3
            case "Speech Recognition": return 4
            case "Amsler Grid": return 5
            default:
                fatalError("Unrecognized test \(testName)")
        }
    }
    
    func getLastestScore<T>(scores: [T]) -> T {
        // change based on the method used to sort the scores array by time (old->new OR new-> old)
        return scores.last!
    }

    enum Study {
        case survey(info: Info)
        case trailA(info: Info, numberOfErrors: Int)
        case trailB(info: Info, numberOfErrors: Int)
        case memory(info: Info)
        case speech(info: Info, text: String)
        case amsler(info: Info)

        var score: Double? {
            return error.map {
                return min(1, max(0, 1 - $0))
            }
        }

        private var error: Double? {
            switch self {
            case .survey:
                return nil
            case .trailA(_, numberOfErrors: let errors):
                return Double(errors) / 13
            case .trailB(_, numberOfErrors: let errors):
                return Double(errors) / 13
            case .memory(info: let info):
                return -1
            case .speech(_, text: let text):
                let target = StudyTasks.speechRecognitionText
                return Double(text.levenshtein(from: target)) / Double(target.count)
            case .amsler(info: let info):
                return -1
            }
        }

        var date: Date {
            switch self {
            case .survey(info: let info):
                return info.endDate
            case .trailA(info: let info, _):
                return info.endDate
            case .trailB(info: let info, _):
                return info.endDate
            case .memory(info: let info):
                return info.endDate
            case .speech(info: let info, _):
                return info.endDate
            case .amsler(info: let info):
                return info.endDate
            }
        }

        var name: String {
            switch self {
            case .survey:
                return "User Survey"
            case .trailA:
                return "Trailmaking A"
            case .trailB:
                return "Trailmaking B"
            case .memory:
                return "Spatial Memory"
            case .speech:
                return "Speech Recognition"
            case .amsler:
                return "Amsler Grid"
            }
        }
    }

    typealias Dict = [String: Any]

    struct Info {
        let startDate: Date
        let endDate: Date

        static func date(from string: String) -> Date! {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
            return dateFormatter.date(from: string)
        }

        init(_ dict: Dict) {
            startDate = Info.date(from: dict["startDate"] as! String)
            endDate = Info.date(from: dict["endDate"] as! String)
        }
    }

    var listener: ListenerRegistration!
    deinit {
        listener.remove()
    }
}
