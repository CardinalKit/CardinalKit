//
//  FeatureFlags.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/1/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//


enum FeatureFlags {
    /// Skips the onboarding flow for demos and UI testing.
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
}
