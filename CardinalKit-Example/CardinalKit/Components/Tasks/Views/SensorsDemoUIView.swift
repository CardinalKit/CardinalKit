//
//  SensorsDemoUIView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import CardinalKit
import SwiftUI

struct SensorsDemoUIView: View {
    let motionManager = CKCoreMotionManager.shared
    let timer = CKTimer()
    
    @State var isMotionActive = false
    @State var useAppleWatch = false
    
    @ObservedObject var timerDelegate = TimerObservable()
    
    fileprivate func motionStart() {
        guard !isMotionActive else {
            return
        }
        
        isMotionActive = true
        motionManager.start()
        timer.start()
        // isMotionActive = motionManager.isActive
    }
    
    fileprivate func motionStop() {
        guard isMotionActive else { return }
        
        isMotionActive = false
        motionManager.stop()
        timer.stop()
        // isMotionActive = motionManager.isActive
    }

    // swiftlint:disable closure_body_length
    var body: some View {
        VStack(spacing: 10) {
            Image("CKLogo")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.paddingHorizontalMain * 4)
                .padding(.trailing, Metrics.paddingHorizontalMain * 4)
                .accessibilityLabel(Text("CardinalKit Logo"))
            
            Text("This DEMO is a CoreMotion sensors test. Press a button from below to get started.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .bold, design: .default))
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)
            
            Text(
                """
                Data from the following sensors will be collected and uploaded into \
                Google Cloud Storage: (1) accelerometer, (2) gyro, (3) device motion
                """
                )
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .regular, design: .default))
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)
            
            HStack(spacing: 10) {
                Button(action: {
                    motionStart()
                }, label: {
                     Text("start")
                        .padding(Metrics.paddingButtonLabel * 2.5)
                        .foregroundColor(.white)
                        .background(isMotionActive ? Color.gray : Color.green)
                        .clipShape(Circle())
                        .font(.system(size: 20, weight: .bold, design: .default))
                })
                Button(action: {
                    motionStop()
                }, label: {
                     Text("stop")
                        .padding(Metrics.paddingButtonLabel * 2.5)
                        .foregroundColor(.white)
                        .background(isMotionActive ? Color.red : Color.gray)
                        .clipShape(Circle())
                        .font(.system(size: 20, weight: .bold, design: .default))
                })
            }.padding(Metrics.paddingVerticalMain)
            
            Text(isMotionActive ? "\(timerDelegate.elapsedSeconds)" : "")
                .padding(Metrics.paddingButtonLabel)
                .font(.system(size: 30, weight: .light, design: .rounded))
            
            Spacer()
            
            Image("SBDLogoGrey")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.paddingHorizontalMain * 4)
                .padding(.trailing, Metrics.paddingHorizontalMain * 4)
                .accessibilityLabel(Text("Biodesign Logo"))
            
            if useAppleWatch {
                HStack(spacing: 10) {
                    Image("WatchIcon")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                        .accessibilityLabel(Text("Watch Icon"))
                    
                    Text("Apple Watch NOT connected")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
        }.onAppear(perform: {
            self.isMotionActive = motionManager.isActive
            self.timer.delegate = timerDelegate
        })
    }
}

class TimerObservable: ObservableObject, TimerDelegate {
    @Published var elapsedSeconds: Int = 0
    
    func limitReached() {}
    func tickMinute(_ timer: TimerController) {}
    func tick(_ timer: TimerController) {
        self.elapsedSeconds = timer.elapsedSeconds
    }
}

struct SensorsDemoUIView_Previews: PreviewProvider {
    static var previews: some View {
        SensorsDemoUIView()
    }
}
