//
//  ProfileView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import HealthKit
import ResearchKit
import Firebase
import EFStorageCore
import EFStorageKeychainAccess

extension HKBiologicalSex: CustomStringConvertible {
    public var description: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .notSet: return "Unknown"
        case .other: return "Other"
        @unknown default:
            return "Other/Unknown"
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var config: CKPropertyReader
    let color: Color

    @State
    var isEditingBasicInfo: Bool = false
    @ObservedObject
    var studyUser: CKStudyUser = .shared

    @State
    var needsHealthKitAccess = false


    var name: String {
        studyUser.currentUser?.displayName
            ?? studyUser.currentUser?.uid
            ?? "Unknown"
    }

    var readTypes: Set<HKObjectType> = [
        HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)!,
        HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)!,
    ]

    var basicInfoSection: some View {
        Section(header: HStack {
            Text("Basic Information")
            Spacer()
            Button(action: {
                isEditingBasicInfo = true
            }, label: {
                if #available(iOS 14.0, *) {
                    Label("Edit", systemImage: "square.and.pencil")
                } else {
                    Text("Edit")
                        .fontWeight(.bold)
                }
            })
        }) {
            HStack {
                Text("Name")
                Spacer()
                Text(name)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Date of Birth")
                Spacer()
                Text(studyUser.dateOfBirth.flatMap {
                    DateFormatter
                        .localizedString(from: $0,
                                         dateStyle: .short,
                                         timeStyle: .none)
                } ?? "Unknown")
                .foregroundColor(.secondary)
            }
            HStack {
                Text("Sex Assigned at Birth")
                Spacer()
                Text(studyUser.sex.description)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Handedness")
                Spacer()
                Text(studyUser.handedness ?? "Unknown")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Ethnicity")
                Spacer()
                Text(studyUser.ethnicity ?? "Unknown")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Education")
                Spacer()
                Text(studyUser.education ?? "Unknown")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Postal Code")
                Spacer()
                Text(studyUser.zipCode ?? "Unknown")
                    .foregroundColor(.secondary)
            }
        }
    }

    var clinicalInfoSection: some View {
        Section(header: Text("Clinical Information"),
                footer: Group {
                    if  HKHealthStore.isHealthDataAvailable() {
                        Text("To manage which health data categories are accessible by TrialX, go to the system Health app.")
                    } else {
                        EmptyView()
                    }
                }
        ) {
            HStack {
                ConsentDocumentButton(title: "Consent Document (Signed)")
                Spacer()
                Image(systemName: "checkmark")
            }
            HStack {
                Button("EHR Access Permission") {
                    #warning("TODO")
                }
                Spacer()
                Image(systemName: "checkmark")
            }
            if needsHealthKitAccess {
                Button("Grant Health Data Access") {
                    let store = HKHealthStore()
                    store.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                        if success {
                            updateHealthKitAccessStatus()
                        }
                    }
                }
            }
        }
    }

    var footer: some View {
        Text(config.read(query: "Copyright"))
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
    }

    var body: some View {
        NavigationView {
            List {
                basicInfoSection

                clinicalInfoSection

                //                Section {
                //                    HelpView(site: config.read(query: "Website"))
                //                    SupportView(color: color, phone: config.read(query: "Phone"))
                //                    ReportView(color: color, email: config.read(query: "Email"))
                //                    ChangePasscodeView()
                //                }

                Section(footer: footer) {
                    WithdrawView()
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile")
        }
        .sheet(isPresented: $isEditingBasicInfo) {
            TaskVC(tasks: StudyTasks.basicInfoSurvey, onComplete: { result in
                guard case let .success(taskResult) = result else { return }
                updateBasicInfo(with: taskResult)
            })
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            if HKHealthStore.isHealthDataAvailable() {
                updateHealthKitAccessStatus()
            }
        }
    }

    func updateHealthKitAccessStatus() {
        HKHealthStore().getRequestStatusForAuthorization(toShare: [], read: readTypes) { status, error in
            withAnimation {
                switch status {
                case .shouldRequest: needsHealthKitAccess = true
                case .unknown: print(error ?? CKError.unknownError)
                case .unnecessary: needsHealthKitAccess = false
                @unknown default: needsHealthKitAccess = false
                }
            }
        }
    }

    func updateBasicInfo(with taskResult: ORKTaskResult) {
        if let nameResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .nameQuestionStep.rawValue)?
            .results?.first as? ORKTextQuestionResult,
           let name = nameResult.textAnswer {
            studyUser.name = name
        } else {
            studyUser.name = nil
        }

        if let dobResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .dobQuestionStep.rawValue)?
            .results?.first as? ORKDateQuestionResult,
           let date = dobResult.dateAnswer {
            studyUser.dateOfBirth = date
        } else {
            studyUser.dateOfBirth = nil
        }

        if let sexResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .sexQuestionStep.rawValue)?
            .results?.first as? ORKChoiceQuestionResult,
           let firstResult = sexResult.choiceAnswers?.first,
           let sexString = firstResult as? String {
            let sex: HKBiologicalSex
            switch sexString {
            case "HKBiologicalSexNotSet": sex = .notSet
            case "HKBiologicalSexFemale": sex = .female
            case "HKBiologicalSexMale": sex = .male
            case "HKBiologicalSexOther": sex = .other
            default: sex = .other
            }
            studyUser.sex = sex
        } else {
            studyUser.sex = .notSet
        }

        if let handednessResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .handedQuestionStep.rawValue)?
            .results?.first as? ORKChoiceQuestionResult,
           let firstAnswer = handednessResult.choiceAnswers?.first,
           let handedness = firstAnswer as? String {
            studyUser.handedness = handedness
        } else {
            studyUser.handedness = nil
        }

        if let locationResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .locationQuestionStep.rawValue)?
            .results?.first as? ORKLocationQuestionResult,
           let location = locationResult.locationAnswer,
           let zipCode = location.postalAddress?.postalCode {
            studyUser.zipCode = zipCode
        } else {
            studyUser.zipCode = nil
        }

        if let ethnicityResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .ethnicityQuestionStep.rawValue)?
            .results?.first as? ORKChoiceQuestionResult,
           let firstAnswer = ethnicityResult.choiceAnswers?.first,
           let ethnicity = firstAnswer as? String {
            studyUser.ethnicity = ethnicity
        } else {
            studyUser.ethnicity = nil
        }

        if let educationResult = taskResult.stepResult(
            forStepIdentifier: ORKStep.Identifier
                .educationQuestionStep.rawValue)?
            .results?.first as? ORKChoiceQuestionResult,
           let firstAnswer = educationResult.choiceAnswers?.first,
           let education = firstAnswer as? String {
            studyUser.education = education
        } else {
            studyUser.education = nil
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(color: .accentColor)
            .environmentObject(CKConfig.shared)
    }
}
