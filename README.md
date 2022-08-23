<img src="https://github.com/CardinalKit/CardinalKit/blob/master/CardinalKit-Web-Assets/header.png?raw=true" alt="cardinalkit logo">

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END --> 

---

<img src="https://github.com/CardinalKit/CardinalKit/blob/main/CardinalKit-Web-Assets/CK_Map.jpg?raw=true" alt="cardinalkit map">

Includes:
* Informed consent process using ResearchKit.
* Track day-to-day adherence with CareKit.
* Monitor health data with HealthKit.
* Collect and upload EHR data.
* CoreMotion data demo.
* Awesome SwiftUI templates.
* Zero-code [customizable configuration file.](https://cardinalkit.org/docs/ckconfig)
* GCP Firebase Integration.

## Build your App with CardinalKit

This repository contains a fully functional example in the `CardinalKit-Example` directory that you can use as a starting point for building your own app. To get started, clone this repository and follow our simple [setup instructions](https://cardinalkit.org/cardinalkit-docs/1-cardinalkit-app/1-start.html).

Feel free to join our Slack community or attend one of our workshops or buildathons for help customizing your app! Learn more at https://cardinalkit.org.

## Contribute to CardinalKit

Head on over to https://cardinalkit.org/ to get onboarded to our open source community ⚡️ 

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://gutierrezsantiago.com"><img src="https://avatars2.githubusercontent.com/u/5482213?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Santiago Gutierrez</b></sub></a><br /><a href="https://github.com/CardinalKit/CardinalKit/commits?author=ssgutierrez42" title="Code">💻</a></td>
    <td align="center"><a href="http://varunshenoy.com"><img src="https://avatars3.githubusercontent.com/u/10859091?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Varun Shenoy</b></sub></a><br /><a href="https://github.com/CardinalKit/CardinalKit/commits?author=varunshenoy" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/mhittle"><img src="https://avatars1.githubusercontent.com/u/1742619?v=4?s=100" width="100px;" alt=""/><br /><sub><b>mhittle</b></sub></a><br /><a href="#ideas-mhittle" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-mhittle" title="Maintenance">🚧</a> <a href="#projectManagement-mhittle" title="Project Management">📆</a></td>
    <td align="center"><a href="https://github.com/aamirrasheed"><img src="https://avatars3.githubusercontent.com/u/7892721?v=4?s=100" width="100px;" alt=""/><br /><sub><b>aamirrasheed</b></sub></a><br /><a href="#content-aamirrasheed" title="Content">🖋</a> <a href="#video-aamirrasheed" title="Videos">📹</a></td>
    <td align="center"><a href="http://apollozhu.github.io/en"><img src="https://avatars1.githubusercontent.com/u/10842684?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Zhiyu Zhu/朱智语</b></sub></a><br /><a href="https://github.com/CardinalKit/CardinalKit/commits?author=ApolloZhu" title="Code">💻</a></td>
    <td align="center"><a href="http://vishnu.io"><img src="https://avatars.githubusercontent.com/u/1212163?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Vishnu Ravi</b></sub></a><br /><a href="https://github.com/CardinalKit/CardinalKit/commits?author=vishnuravi" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## License

CardinalKit is available under the MIT license. See the LICENSE file for more info.


<img src="https://github.com/CardinalKit/CardinalKit/blob/master/CardinalKit-Web-Assets/footer.png?raw=true" alt="biodesign logo">



# Use cardinalKit as a library


## What can you do with cardinal kit as a library?
- Collect HealthKit data between a couple of specific dates
- Collect HealthKit data in the background whenever the app is used
- Set up a database to:
  - Save and get HealthKit records
  - Save and get user data
  - Create, Save and get data for surveys with ResearchKit
- Create a task calendar (ResearchKit)
- Collect sensor data and store this data in a database (By default cardinal kit implements firebase/firestore as database and firebase/storage as bucket to store files)

## Configure CardinalKit

Cardinal kit is developed to be used as an external pod using cocoapods for use add the following line to your podfile

```
pod 'CardinalKit', :git => 'https://github.com/CardinalKit/CardinalKit',:branch => 'main'
```

Cardinal Kit by default implements firebase as external database and realm as local database this can be changed when configuring CardinalKit

## 1. implements your own external database
  Cardinal Kit defines two protocols to implement the database
  ```
  CKDeliveryDelegate
  CKReceiverDelegate
  ```

## 1.1 CKDeliveryDelegate
This protocol defines the methods that you must implement so that cardinal download kit obtains data from your database.

``` Swift
public protocol CKDeliveryDelegate {
  // Cardinal Kit will call this method to send a packet to its Database
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void)
    // Cardinal Kit will call this method to send any text file
    func send(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void)?)
   // this method will be called to send files to your bucket
     // the option alsoSendToFirestore sends the data in plain text to your database as well
    func sendToCloud(files:URL, route: String, alsoSendToFirestore:Bool, firestoreRoute:String?, onCompletion: @escaping (Bool) -> Void)
    // will be called when cardinal kit wants to save an object of type calendar in its database
    func createScheduleItems(route:String, items:[ScheduleModel], onCompletion: @escaping (Bool) -> Void)
    // cardinal kit will call this method at the start of execution, where you can make your initial database configurations
    func configure()
}
```
## 1.2 CKReceiverDelegate
This protocol defines the methods that you must implement to request data from your database.
```Swift
public protocol CKReceiverDelegate {
  /// Cardinal kit will call this method when it needs to fetch data from your database.
    func request(route: String, onCompletion: @escaping ([String:Any]?) -> Void)

    /// This function will be called to get bucket files
    func requestFromStorage(path:String,url:URL, OnCompletion: @escaping (Bool, Error?) -> Void)

    // This function will be called to obtain filtered data by defining the filters in the following model
    /***
    public struct FilterModel {
      var field:String
      var filterType:FilterType
      var value:Any
    }
    public enum FilterType {
      case GreaterThan
      case GreaterOrEqualTo
      case LessThan
      case LessOrEqualTo
      case equalTo
    }
     */
    func requestFilter(route: String, filter:[FilterModel], onCompletion: @escaping ([String:Any]?) -> Void)

    // this function will be called to get the calendar events of a specific date
    func requestScheduleItems(date: Date, onCompletion: @escaping ([ScheduleModel]) -> Void)

    // this function is implemented for firebase to get the public url of a storage file
    func requestUrlFromStorage(path:String, onCompletion: @escaping (URL) -> Void, onError: @escaping (Error) -> Void)
    // cardinal kit will call this method at startup, where you can make your initial database configurations
    func configure()
}
```

## 2. implements your own local database

To use a local database other than realm implement the following protocol
```
 CKLocalDBDelegate
```
``` Swift
public protocol CKLocalDBDelegate{
  // cardinal kit will call this method at startup, where you can make your initial database configurations
    func configure() -> Bool

    // For the data collection of healthKit cardinal Kit uses an object called SyncItem that returns the date when a data type of healthKit was last synchronized
    // params: datatype String
    //        device String
    func getLastSyncItem(params: [String : AnyObject]) -> DateLastSyncObject?
    func saveLastSyncItem(item:DateLastSyncObject)
    func deleteLastSyncitem()

    // To guarantee the correct sending of data to an external database, cardinalkit also saves objects called reditem in its local database. These objects contain the information that you want to send to the external database before being sent as a copy by if an error occurs
    func getNetworkItem(params: [String : AnyObject]) -> NetworkRequestObject?
    func saveNetworkItem(item:NetworkRequestObject)
    func deleteNetworkItem()
    func getNetworkItemsByFilter(filterQuery:String?) -> [NetworkRequestObject] 
}
```

## 3. start cardinalKit
Once you have these protocols implemented, start Cardinal Kit as follows

1. Import Cardinal Kit
   ```Swift
   import CardinalKit
   ```
2. Create an object ```CKAppOptions ```
   ```Swift
   let options = CKAppOptions()
   ```
3. Optionally assign your implementations to the options object
   ```Swift
   options.networkDeliveryDelegate = OwnDeliveryImplemenatation()
   options.networkReceiverDelegate = OwnReceiverImplemenatation()
   options.localDBDelegate = OwnLocalDbImplemenatation()
   ```
4. Send this object to CardinalKit
   ```Swift
   CKApp.configure(options)
   ```
5. Once you have configured CardinalKit you can use all of its features. 

## 1. Collect HealthKit data between a couple of specific dates

To start data collection you must first specify to CardinalKit what type of data you want to collect.

> If you do not tell CardinalKit the data types, all existing types will be collected.

```Swift
/// Defina un objeto con los tipos de datos
 var hkTypes: Set<HKSampleType> = [
    HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
    HKObjectType.quantityType(forIdentifier: .walkingStepLength)!,
    HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
    HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
    HKObjectType.quantityType(forIdentifier: .stepCount)!,
    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)!,
    HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)!,
    HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!
]

var clinicalTypes: Set<HKSampleType> = [
  HKClinicalType.allergyRecord(),
  HKClinicalType.audiogramSampleType()
]
/// Envielos a CardinalKit
CKApp.configureHealthKitTypes(types: hkTypes, clinicalTypes: clinicalTypes)

```

> You can see a list of all existing types in this file https://github.com/CardinalKit/CardinalKit/tree/main/CardinalKit/Source/Infrastructure/Health/Library/HealthKit/HealthKitManager+HKTypes.swift



In this example, healthkit data is collected from 10 days ago to the current date
```Swift
  CKApp.collectData(fromDate: Date().dayByAdding(-10)!, toDate: Date())
```

> **_NOTE:_** Once the data is collected, it is attempted to be sent to the databases using the implemented protocols.


## 2. Start HealthKit collection in the background 
Configure the healthKit data in the same way as in point 1
> **_NOTE:_** It is only necessary to configure the data types once cardinalkit will always collect only that type of data

```Swift
CKApp.startBackgroundDeliveryData()
```


## 3. Request user permissions for data collection
When you tell cardinalKit to collect data cardinalKit will first ask the user for permissions, but if you want you can tell cardinalKit to ask for these permissions at any time.

``` Swift
CKApp.getHealthPermision{ succes in
  OperationQueue.main.addOperation {
    // Anything you need to do after requesting permissions
  }
}
```
## 4. Enviar datos especificos a su base de datos

At any time you can request that CardinalKit send specific data to your external database

```Swift
let route = "/MyBdPath"
let json = {
  "data":{
    "param1":"valu1"
  }
}
let paramsExample = ["userId":"\(userId)","merge":true]
CKApp.sendData(route: route, data: json, params: paramsExample)       
```