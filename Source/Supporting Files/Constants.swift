//
//  Constants.swift
//  CS342Support
//
//  Created by Santiago Gutierrez on 4/17/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

class Constants {
    
    enum Environment {
        case development
        case production
    }
    
    static let environment: Environment = .production
    
    struct UserDefaults {
        
        //Misc
        static let FirstRun = "edu.stanford.vasctrac.firstRun"
        static let FirstLogin = "edu.stanford.vasctrac.firstLogin"
        static let CompletedMarketingSurvey = "edu.stanford.vasctrac.completedMarketingSurvey"
        static let HKDataShare = "edu.stanford.vasctrac.healthKitShare"
        
        //Session
        static let DeviceToken = "edu.stanford.vasctrac.deviceToken"
        static let UserId = "edu.stanford.vasctrac.userId"
        static let EID = "edu.stanford.vasctrac.EID"
        static let ValidSession = "edu.stanford.vasctrac.validSession"
        
        // Surveys
        static let MedicalSurvey = "edu.stanford.vasctrac.medicalSurvey"
        static let SF12Survey = "edu.stanford.vasctrac.sf12Survey"
        static let SurgicalSurvey = "edu.stanford.vasctrac.surgicalSurvey"
        static let PhysicalSurvey = "edu.stanford.vasctrac.physicalSurvey"
        
        // Watch
        static let WatchReceivedFiles = "edu.stanford.vasctrac.watch.receivedFiles"
        static let WatchTransferFailedFiles = "edu.stanford.vasctrac.watch.failedFiles"
    }
    
    struct Network {
        
        // MARK: Environments URLs
        static let stagingUrl = "https://vasctracdev.azurewebsites.net"
        static let productionUrl = "https://vasctrac-samoyed.azurewebsites.net"
        
        static let localUrl = "http://192.168.7.243:3000"//"http://localhost:3000"
        
        static var currentServerUrl: String {
            switch Constants.environment {
            case .development:
                return localUrl//stagingUrl
            case .production:
                return productionUrl
            }
        }
        
        static let SuccessRange = 200..<300
        static let NotFound = 404
        static let ServerError = 500
    }
    
    struct Keychain {
        static let AppIdentifier = "edu.stanford.vasctrac"
        static let TokenIdentifier = "edu.stanford.vasctrac.token"
    }
    
    struct Notification {
        static let MessageArrivedNotification = "MessageArrivedNotification"
        static let DidRegisterNotifications = "DidRegisterUserNotificationSettings"
        static let DidRegisterNotificationsWithToken = "didRegisterForRemoteNotificationsWithDeviceToken"
        
        static let WalkTestRequest = "WalkTestRequest"
        static let APIUserErrorNotification = "APIUserErrorNotification"
        static let DataSyncRequest = "DataSyncRequest"
        
        //Reset tab navigation badges
        static let BadgeReset = "BadgeReset"
        
        //Session
        static let SessionExpired = "UserSessionExpired"
        static let SessionReset = "SessionReset"
        
        //Watch
        static let SessionWatchReachabilityDidChange = "SessionWatchReachabilityDidChange"
        static let SessionWatchStateDidChange = "sessionWatchStateDidChange"
    }
    
    struct Sync {
        static let completed = "edu.stanford.vasctrac.sync.completed"
        static let eventsCompleted = "edu.stanford.vasctrac.sync.events.completed"
        static let surveysCompleted = "edu.stanford.vasctrac.sync.surveys.completed"
        static let walkTestCompleted = "edu.stanford.vasctrac.sync.walktest.completed"
        static let hkDay = "edu.stanford.vasctrac.sync.hk.day.completed"
        static let hkEverything = "edu.stanford.vasctrac.sync.hk.everything.completed"
    }
    
    struct WatchMessage {
        static let walkStarted = "edu.stanford.vasctrac.walk.started"
        static let walkRestingStarted = "edu.stanford.vasctrac.walk.resting.started"
        static let walkStopActive = "edu.stanford.vasctrac.walk.stop.active"
        static let walkStop = "edu.stanford.vasctrac.walk.stop"
        static let walkCancel = "edu.stanford.vasctrac.walk.cancel"
        
        static let phoneReceivedFile = "edu.stanford.vasctrac.phone.received.file"
        
        static let watchError = "edu.stanford.vasctrac.watchtrac.error"
        static let watchReady = "edu.stanford.vasctrac.watchtrac.ready"
        static let watchStartDate = "edu.stanford.vasctrac.watchtrac.ready.startdate"
        static let watchConfirm = "edu.stanford.vasctrac.watchtrac.received.confirm"
        static let watchEndWorkout = "edu.stanford.vasctrac.watchtrac.workout.end"
        
        static let watchProcessing = "edu.stanford.vasctrac.watchtrac.result.processing"
        static let watchProcessingSuccess = "edu.stanford.vasctrac.watchtrac.result.processing.success"
        static let watchProcessingError = "edu.stanford.vasctrac.watchtrac.result.processing.error"
        
        static let watchSession = "edu.stanford.vasctrac.watchtrac.session"
        static let watchSessionRefresh = "edu.stanford.vasctrac.watchtrac.session.refresh"
        
        static let watchWorkoutSession = "edu.stanford.vasctrac.watchtrac.workout.session"
        
        static let watchSnapshot = "edu.stanford.vasctrac.watchtrac.snapshot"
    }
}
