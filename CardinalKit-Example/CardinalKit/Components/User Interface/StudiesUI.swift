//
//  StudiesUI.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import MessageUI
import CardinalKit
import ResearchKit

struct StudiesUI: View {
    
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
    }
    
    var body: some View {
        TabView {
            ActivitiesView(color: self.color)
                .tabItem {
                    Image("tab_activities").renderingMode(.template)
                    Text("Activities")
            }

            ProfileView(color: self.color)
                .tabItem {
                    Image("tab_profile").renderingMode(.template)
                    Text("Profile")
                }
        }.accentColor(self.color)
    }
}

struct StudyItem: Identifiable {
    var id = UUID()
    let image: UIImage
    var title = ""
    var description = ""
    let vc: ORKTaskViewController
    
    init(study: StudyTableItem) {
        self.image = study.image!
        self.title = study.title
        self.description = study.subtitle
        self.vc = study.task
    }
}

struct ActivitiesView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    var date = ""
    var activities: [StudyItem] = []
    
    init(color: Color) {
        self.color = color
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        
        self.date = formatter.string(from: date)
        
        let studyTableItems = StudyTableItem.allValues
        for study in studyTableItems {
            self.activities.append(StudyItem(study: study))
        }
    }
    
    var body: some View {
        VStack {
            Text(config.read(query: "Study Title")).font(.system(size: 25, weight:.bold)).foregroundColor(self.color)
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            Text(self.date).font(.system(size: 18, weight: .regular)).padding()
            List {
                Section(header: Text("Current Activities")) {
                    
                    ForEach(0 ..< self.activities.count) {
                        ActivityView(icon: self.activities[$0].image, title: self.activities[$0].title, description: self.activities[$0].description, vc: self.activities[$0].vc)
                    }
                    
                }.listRowBackground(Color.white)
            }.listStyle(GroupedListStyle())
        }
    }
}

struct ActivityView: View {
    let icon: UIImage
    var title = ""
    var description = ""
    let vc: ORKTaskViewController
    @State var showingDetail = false
    
    init(icon: UIImage, title: String, description: String, vc: ORKTaskViewController) {
        self.icon = icon
        self.title = title
        self.description = description
        self.vc = vc
    }
    
    var body: some View {
        HStack {
            Image(uiImage: self.icon).resizable().frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(self.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(self.description).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
            }.frame(height: 65).contentShape(Rectangle()).gesture(TapGesture().onEnded({
                self.showingDetail.toggle()
            })).sheet(isPresented: $showingDetail, onDismiss: {
                
            }, content: {
                TaskVC(vc: self.vc)
            })
    }
}



struct WithdrawView: View {
    let color: Color
    @State var showWithdraw = false
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Withdraw from Study").foregroundColor(self.color)
            Spacer()
            Text("›").foregroundColor(self.color)
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            self.showWithdraw.toggle()
            })).sheet(isPresented: $showWithdraw, onDismiss: {
                
            }, content: {
                WithdrawalVC()
            })
    }
}

struct ReportView: View {
    let color: Color
    var email = ""
    
    init(color: Color, email: String) {
        self.color = color
        self.email = email
    }
    
    var body: some View {
        HStack {
            Text("Report a Problem")
            Spacer()
            Text(self.email).foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            EmailHelper.shared.sendEmail(subject: "App Support Request", body: "Enter your support request here.", to: self.email)
        }))
    }
}

struct SupportView: View {
    let color: Color
    var phone = ""
    
    init(color: Color, phone: String) {
        self.color = color
        self.phone = phone
    }
    
    var body: some View {
        HStack {
            Text("Support")
            Spacer()
            Text(self.phone).foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            let telephone = "tel://"
                let formattedString = telephone + self.phone
            guard let url = URL(string: formattedString) else { return }
            UIApplication.shared.open(url)
        }))
    }
}

struct HelpView: View {
    var site = ""
    
    init(site: String) {
        self.site = site
    }
    
    var body: some View {
        HStack {
            Text("Help")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                if let url = URL(string: self.site) {
                UIApplication.shared.open(url)
            }
        }))
    }
}

struct ChangePasscodeView: View {
    @State var showPasscode = false
    
    var body: some View {
        HStack {
            Text("Change Passcode")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
                    self.showPasscode.toggle()
                }
        })).sheet(isPresented: $showPasscode, onDismiss: {
            
        }, content: {
            PasscodeVC()
        })
    }
}

struct PatientIDView: View {
    var userID = ""
    
    init() {
        if let currentUser = CKStudyUser.shared.currentUser {
           self.userID = currentUser.uid
       }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("PATIENT ID").font(.system(.headline)).foregroundColor(Color(.greyText()))
                Spacer()
            }
            HStack {
                Text(self.userID).font(.system(.body)).foregroundColor(Color(.greyText()))
                Spacer()
            }
        }.frame(height: 100)
    }
}

struct ProfileView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        VStack {
            Text("Profile").font(.system(size: 25, weight:.bold))
            List {
                Section {
                    PatientIDView()
                }.listRowBackground(Color.white)
                
                Section {
                    ChangePasscodeView()
                    HelpView(site: config.read(query: "Website"))
                }
                
                Section {
                    ReportView(color: self.color, email: config.read(query: "Email"))
                    SupportView(color: self.color, phone: config.read(query: "Phone"))
                }
                
                Section {
                    WithdrawView(color: self.color)
                }
                
                Section {
                    Text(config.read(query: "Copyright"))
                }
            }.listStyle(GroupedListStyle())
        }
    }
}


struct StudiesUI_Previews: PreviewProvider {
    static var previews: some View {
        StudiesUI()
    }
}

public extension UIColor {
    class func greyText() -> UIColor {
        return UIColor(netHex: 0x989998)
    }
    
    class func lightWhite() -> UIColor {
        return UIColor(netHex: 0xf7f8f7)
    }
}

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()

    func sendEmail(subject:String, body:String, to:String){
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}

struct PasscodeVC: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: ORKPasscodeViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKPasscodeViewController

    func makeUIViewController(context: Context) -> ORKPasscodeViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let num = config.read(query: "Passcode Type")
        
        if num == "4" {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType:.type4Digit)
            
            return editPasscodeViewController
        } else {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType: .type6Digit)
            
            return editPasscodeViewController
        }
        
    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        

    }
    
}

struct TaskVC: UIViewControllerRepresentable {
    
    let vc: ORKTaskViewController
    
    init(vc: ORKTaskViewController) {
        self.vc = vc
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
        do {
            let defaultFileManager = FileManager.default
            
            // Identify the documents directory.
            let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
            try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            
            return outputDirectory
        }
        catch let error as NSError {
            print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
        }
        
        return nil
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        
        vc.outputDirectory = CKGetTaskOutputDirectory(vc)
        
        self.vc.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return self.vc

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
                taskViewController.dismiss(animated: true, completion: nil)
            default:
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
}


struct WithdrawalVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let instructionStep = ORKInstructionStep(identifier: "WithdrawlInstruction")
        instructionStep.title = NSLocalizedString(config.read(query: "Withdrawal Instruction Title"), comment: "")
        instructionStep.text = NSLocalizedString(config.read(query: "Withdrawal Instruction Text"), comment: "")
        
        let completionStep = ORKCompletionStep(identifier: "Withdraw")
        completionStep.title = NSLocalizedString(config.read(query: "Withdraw Title"), comment: "")
        completionStep.text = NSLocalizedString(config.read(query: "Withdraw Text"), comment: "")
        
        let withdrawTask = ORKOrderedTask(identifier: "Withdraw", steps: [instructionStep, completionStep])
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: withdrawTask, taskRun: nil)
        
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
                UserDefaults.standard.set(false, forKey: "didCompleteOnboarding")
                taskViewController.dismiss(animated: true, completion: {
                    fatalError()
                })
                
            default:
                
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
}
