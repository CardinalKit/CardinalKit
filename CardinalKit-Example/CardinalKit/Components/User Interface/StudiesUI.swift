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
import Firebase
import PDFKit

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

            // add a visualizations tab to your app!
            VisualizationsView(color: self.color)
                .tabItem {
                    Image("tab_dashboard").renderingMode(.template)
                    Text("Visualize")
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
    let task: ORKOrderedTask

    init(study: StudyTableItem) {
        self.image = study.image!
        self.title = study.title
        self.description = study.subtitle
        self.task = study.task
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
                        ActivityView(icon: self.activities[$0].image, title: self.activities[$0].title, description: self.activities[$0].description, tasks: self.activities[$0].task)
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
    let tasks: ORKOrderedTask
    @State var showingDetail = false

    init(icon: UIImage, title: String, description: String, tasks: ORKOrderedTask) {
        self.icon = icon
        self.title = title
        self.description = description
        self.tasks = tasks
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
                TaskVC(tasks: self.tasks)
            })
    }
}

struct VisualizationsView: View {
    let color: Color
    @ObservedObject var visualizations = FirebaseHelper.shared.getGroupedSurveys()

    // For bonus points: add hooks to the CKConfiguration.plist file to customize the data visualization.
    let config = CKPropertyReader(file: "CKConfiguration")
    var visualizationConfig: [String: String] = [:]


    init(color: Color) {
        self.color = color
        self.visualizationConfig = config.readDict(query: "Visualizations")
    }

    var body: some View {
        VStack {
            Text(config.read(query: "Study Title")).font(.system(size: 25, weight:.bold)).foregroundColor(self.color)
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            List {
                Section(header: Text("Patient Data")) {

                    ForEach(0 ..< self.visualizations.data.count) {
                        VisualizationView(data: self.visualizations.data[$0] as! VisualizationData, config: self.visualizationConfig)
                    }

                }.listRowBackground(Color.white)
            }.listStyle(GroupedListStyle())
        }
    }
}

struct VisualizationView: View {
    @State var showingDetail = false
    var data: VisualizationData
    var type: String
    var title: String
    var description: String
    var visualization: AnyView
    var showThumbnail: Bool = false


    init(data: VisualizationData, config: [String: String]) {
        self.data = data
        self.type = data.type
        self.title = data.title
        self.description = data.description

        // set visualization config
        if (config["showThumbnail"]) != nil && (config["showThumbnail"]) == "true" {
            self.showThumbnail = true
        }

        // prepare the appropriate visualization
        switch self.data.type {
            case "LineGraph":
                self.visualization = AnyView(LineGraph(visualizationData: data))
            case "DiscreteGraph":
                self.visualization = AnyView(DiscreteGraph(visualizationData: data))
            case "PieChart":
                self.visualization = AnyView(PieChart(visualizationData: data, thumbnail: true))
            default:
                self.visualization = AnyView(EmptyView()) //noop
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(self.description).font(.system(size: 14, weight: .light, design: .default))
            }

            // show thumbnail visualization
            if self.showThumbnail {
                Group {
                    Spacer()
                    self.visualization
                    Spacer()
                }
            }

        }.frame(height: 130).contentShape(Rectangle()).gesture(TapGesture().onEnded({
            self.showingDetail.toggle()
        })).sheet(isPresented: $showingDetail, onDismiss: {

        }, content: {
            VisualizationInspectionView(data: self.data)
        })
    }
}

struct VisualizationInspectionView: View {
    var data: VisualizationData

    // samples
    var visualization: AnyView

    init (data: VisualizationData) {
        self.data = data

        // prepare the appropriate visualization
        switch self.data.type {
            case "LineGraph":
                visualization = AnyView(LineGraph(visualizationData: data))
            case "DiscreteGraph":
                visualization = AnyView(DiscreteGraph(visualizationData: data))
            case "PieChart":
                visualization = AnyView(PieChart(visualizationData: data, thumbnail: false))
            default:
                visualization = AnyView(EmptyView()) //noop
        }
    }

    func exportToPDF() {

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFileURL = documentDirectory.appendingPathComponent("Chart.pdf")

        //Normal with
        let width: CGFloat = 8.5 * 72.0
        //Estimate the height of your view
        let height: CGFloat = 1000
        let charts = body

        let pdfVC = UIHostingController(rootView: charts)
        pdfVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        //Render the view behind all other views
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        rootVC?.addChild(pdfVC)
        rootVC?.view.insertSubview(pdfVC.view, at: 0)

        //Render the PDF
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: height))
        DispatchQueue.main.async {
            do {
                try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                    context.beginPage()
                    rootVC!.view.layer.render(in: context.cgContext)
                })
                print("wrote file to: \(outputFileURL.path)")
            } catch {
                print("Could not create PDF file: \(error.localizedDescription)")
            }
        }

        pdfVC.removeFromParent()
        pdfVC.view.removeFromSuperview()
    }

    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Spacer()
            VStack {
                Text(self.data.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(self.data.description).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
            HStack {
                Spacer()
                // 'render' visualization
                self.visualization
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Button(action: { self.presentationMode.wrappedValue.dismiss() })
                { Text("Back") }
                Spacer()
                Button(action: { self.exportToPDF()})
                { Text("Export to PDF") }
                Spacer()
                Spacer()
            }

            Spacer()
        }
    }
}

struct VisualizationData: Identifiable {
    var id = UUID()
    var description: String
    var type: String
    var title: String
    var values: [Any]

    init(title: String, description: String, type: String,  values: [Any]) {
        self.title = title
        self.description = description
        self.type = type
        self.values = values
    }
}

// reference: http://researchkit.org/docs/Classes/ORKPieChartView.html
struct PieChart: UIViewRepresentable {

    typealias UIViewType = ORKPieChartView
    var chart: ORKPieChartView
    var dataSource: ORKPieChartViewDataSource

    init (visualizationData: VisualizationData, thumbnail: Bool) {
        // make a new Chart and it's dataSource, then bind
        self.chart = ORKPieChartView()
        self.dataSource = PieChartDataSource(visualizationData: visualizationData)
        self.chart.dataSource = self.dataSource

        // binding Chart props from visualizationData
        if (thumbnail == true) {
            self.chart.text = ""
            self.chart.title = ""
            self.chart.showsPercentageLabels = false
        } else {
            self.chart.text = visualizationData.description
            self.chart.title = visualizationData.title
        }

    }

    func makeUIView(context: UIViewRepresentableContext<PieChart>) -> ORKPieChartView {
        return self.chart
    }

    func updateUIView(_ uiView: ORKPieChartView, context: UIViewRepresentableContext<PieChart>) {
        // noop
    }

    class PieChartDataSource: NSObject, ORKPieChartViewDataSource {
        var data: VisualizationData
        var values: [Double]

        init (visualizationData: VisualizationData) {
            self.data = visualizationData
            self.values = visualizationData.values as! [Double]
        }

        // todo: @uRiley
        let colors = [
            UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1),
            UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1),
            UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1),
        ]

        func numberOfSegments(in pieChartView: ORKPieChartView) -> Int {
            return values.count
        }

        func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
            return CGFloat(values[index])
        }

        func pieChartView(_ pieChartView: ORKPieChartView, colorForSegmentAt index: Int) -> UIColor {
            return colors[(index % colors.count)]
        }


    }
}

// reference: http://researchkit.org/docs/Classes/ORKLineGraphChartView.html
struct LineGraph: UIViewRepresentable {

    typealias UIViewType = ORKLineGraphChartView
    var chart: ORKLineGraphChartView
    var dataSource: ORKValueRangeGraphChartViewDataSource

    init (visualizationData: VisualizationData) {
        // make a new Graph and it's dataSource, then bind
        self.chart = ORKLineGraphChartView()
        self.dataSource = LineGraphDataSource(visualizationData: visualizationData)
        self.chart.dataSource = self.dataSource

        // binding Graph props from visualizationData
    }

    func makeUIView(context: UIViewRepresentableContext<LineGraph>) -> ORKLineGraphChartView {
        return self.chart
    }

    func updateUIView(_ uiView: ORKLineGraphChartView, context: UIViewRepresentableContext<LineGraph>) {
        // noop
    }

    class LineGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
        var data: VisualizationData
        var values: [[ORKValueRange]]

        init (visualizationData: VisualizationData) {
            self.data = visualizationData
            self.values = visualizationData.values as! [[ORKValueRange]]
        }

        // todo: @uRiley
        let colors = [
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 100/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)
        ]

        func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
            return values[plotIndex][pointIndex]
        }

        func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
            return values[plotIndex].count
        }

        func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
            return values.count
        }

        func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
            return colors[(plotIndex % colors.count)]
        }
    }
}

// reference: http://researchkit.org/docs/Classes/ORKDiscreteGraphChartView.html
struct DiscreteGraph: UIViewRepresentable {

    typealias UIViewType = ORKDiscreteGraphChartView
    var chart: ORKDiscreteGraphChartView
    var dataSource: ORKValueRangeGraphChartViewDataSource

    init (visualizationData: VisualizationData) {
        // make a new Graph and it's dataSource, then bind
        self.chart = ORKDiscreteGraphChartView()
        self.dataSource = DiscreteGraphDataSource(visualizationData: visualizationData)
        self.chart.dataSource = self.dataSource

        // binding Graph props from visualizationData
    }

    func makeUIView(context: UIViewRepresentableContext<DiscreteGraph>) -> ORKDiscreteGraphChartView {
        return self.chart
    }

    func updateUIView(_ uiView: ORKDiscreteGraphChartView, context: UIViewRepresentableContext<DiscreteGraph>) {
        // no-operation
    }

    class DiscreteGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
        var data: VisualizationData
        var values: [[ORKValueRange]]

        init (visualizationData: VisualizationData) {
            self.data = visualizationData
            self.values = visualizationData.values as! [[ORKValueRange]]
        }

        // todo: @uRiley
        let colors = [
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 100/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)
        ]

        func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
            return values[plotIndex][pointIndex]
        }

        func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
            return values[plotIndex].count
        }

        func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
            return values.count
        }

        func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
            return colors[(plotIndex % colors.count)]
        }
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

struct DocumentView: View {
    @State private var showPreview = false
    let documentsURL: URL!

    init() {
        let documentsPath = UserDefaults.standard.object(forKey: "consentFormURL")
        self.documentsURL = URL(fileURLWithPath: documentsPath as! String, isDirectory: false)
        print(self.documentsURL.path)
    }

    var body: some View {
        HStack {
            Text("View Consent Document")
            Spacer()
            Text("›")
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                self.showPreview = true

        })).background(DocumentPreview(self.$showPreview, url: self.documentsURL))
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
                    DocumentView()
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

class FirebaseHelper: NSObject {
    private let db = Firestore.firestore()
    private let authCollection = CKStudyUser.shared.authCollection
    public static let shared = FirebaseHelper()

    class Payload: ObservableObject {
        @Published var data = []
    }

    /**
     Generate a dictionary where key is the survey identifier and value is an array of survey payloads.
     Uses completion handler paradigm to resolve async call to firebase.
     */
    func getGroupedSurveys() -> Payload {
        var surveysDict = [NSString: [NSDictionary]]()
        let payload = Payload()


        // if we're not signed in, don't even bother.
        if authCollection != nil {

            // Grab survey documents from firebase.
            db.collection(authCollection! + "\(Constants.dataBucketSurveys)").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    DispatchQueue.main.async {
                        // todo: @tlaskey3
                    }
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()["payload"] as? NSDictionary
                        let identifier = data!["identifier"]! as? NSString
                        if var surveyList: [NSDictionary] = surveysDict[identifier!] {
                            surveyList.append(data!)
                            surveysDict[identifier!] = surveyList
                        } else {
                            var surveyList = [NSDictionary]()
                            surveyList.append(data!)
                            surveysDict[identifier!] = surveyList
                        }
                    }
                    DispatchQueue.main.async {
                        payload.data = self.processGroupedSurveys(surveysDict: surveysDict)
                    }
                }
            }
        }
        return payload
    }

    /**
    Process the grouped surveys into an array of `VisualizationData` objects.
     */
    func processGroupedSurveys(surveysDict: [NSString: [NSDictionary]]) -> [VisualizationData] {
        var visDataArray = [VisualizationData]()

        /**
         Do the processing...
         Note: Switch statement could be replaced with a `ProcessSurveyHandler` class, allowing you to move all the processing implementations for different surveys into separate files/functions.
         This would modularize the code and reduce the size of the `StudiesUI` file.
            - @Tlaskey3
         */
        for identifier in surveysDict.keys {
            switch identifier {
            case "TappingTask":
                print("processing TappingTask")

                let title = identifier as String
                let description = ""
                let type = "LineGraph"
                var values = [[ORKValueRange(value: 0)]]

                // processess && update values

                let data = VisualizationData(
                    title: title,
                    description: description,
                    type: type,
                    values: values
                )
                visDataArray.append(data)

            case "Hanoi":
                print("processing Hanoi task")

                let title = identifier as String
                let description = "Time taken in seconds."
                let type = "DiscreteGraph"
                var values = [[],[]]
                
                // processess && update values
                for surveys in (surveysDict[identifier])! {
                    let results = surveys["results"] as! NSArray
                    let result = results[2] as! NSDictionary
                    let resultOfResults = result["results"] as! NSArray
                    let resultOfResultOfResults = resultOfResults[0] as! NSDictionary
                    let moves = resultOfResultOfResults["moves"] as! NSArray
                    let move = moves[moves.count - 1] as! NSDictionary
                    let ts = move["timestamp"] as! Double
                    
                    values[0].append(ORKValueRange(value: 0))
                    values[1].append(ORKValueRange(value: ts))
                }

                let data = VisualizationData(
                    title: title,
                    description: description,
                    type: type,
                    values: values
                )
                visDataArray.append(data)

            case "ShortWalkTask":
                print("processing ShortWalkTask")

                // This is a typical starting point
                let title = identifier as String
                let description = ""
                let type = "LineGraph"
                var values = [[ORKValueRange(value: 0)]]

                // processess && update values

                let data = VisualizationData(
                    title: title,
                    description: description,
                    type: type,
                    values: values
                )
                visDataArray.append(data)

            case "SurveyTask-SF12":
                print("processing SurveyTask-SF12")

                let title = identifier as String
                let description = "Personal Health Scale"
                let type = "LineGraph"
                var values = [[],[]]
                
                // processess && update values
                for surveys in (surveysDict[identifier])! {
                    let results = surveys["results"] as! NSArray
                    let result = results[1] as! NSDictionary
                    let healthScaleResults = result["results"] as! NSArray
                    let healthScaleResultsDict = healthScaleResults[0] as! NSDictionary
                    let healthScaleResult = healthScaleResultsDict["scaleAnswer"] as! Double
                    
                    values[0].append(ORKValueRange(value: 0))
                    values[1].append(ORKValueRange(value: healthScaleResult))
                }

                let data = VisualizationData(
                    title: title,
                    description: description,
                    type: type,
                    values: values
                )
                visDataArray.append(data)
            default:
                print("Unable to process surveys, unknown identifier")

            }
        }

        return visDataArray
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

struct DocumentPreview: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private let docController: UIDocumentInteractionController

    init(_ isActive: Binding<Bool>, url: URL) {
        self.isActive = isActive
        self.docController = UIDocumentInteractionController(url: url)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPreview>) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPreview>) {
        if self.isActive.wrappedValue && docController.delegate == nil { // to not show twice
            docController.delegate = context.coordinator
            self.docController.presentPreview(animated: true)
        }
    }

    func makeCoordinator() -> Coordintor {
        return Coordintor(owner: self)
    }

    final class Coordintor: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreview
        init(owner: DocumentPreview) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
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
            switch reason {
            case .completed:
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
                fallthrough
            default:
                taskViewController.dismiss(animated: true, completion: nil)

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
            }
            catch let error as NSError {
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
                db.collection(authCollection + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in

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
                    guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
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
                        /*if let error = snapshot.error as NSError? {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                // File doesn't exist
                                break
                            case .unauthorized:
                                // User doesn't have permission to access file
                                break
                            case .cancelled:
                                // User canceled the upload
                                break

                                /* ... */

                            case .unknown:
                                // Unknown error occurred, inspect the server response
                                break
                            default:
                                // A separate error occurred. This is a good place to retry the upload.
                                break
                            }
                        }*/
                    }

                }
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

                do {
                    try Auth.auth().signOut()

                    if (ORKPasscodeViewController.isPasscodeStoredInKeychain()) {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }

                    taskViewController.dismiss(animated: true, completion: {
                        fatalError()
                    })

                } catch {
                    print(error.localizedDescription)
                    Alerts.showInfo(title: "Error", message: error.localizedDescription)
                }

            default:

                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)

            }
        }
    }

}
