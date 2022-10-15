//
//  Questionnaire+ValueSets.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//


import ModelsR4


extension Questionnaire {
    /// Get ValueSets defined as a contained resource within a FHIR `Questionnaire`
    /// - Returns: An array of `ValueSet`
    func getContainedValueSets() -> [ValueSet] {
        guard let contained = self.contained else {
            return []
        }
        let valueSets = contained.compactMap { resource in
            resource.get() as? ValueSet
        }
        return valueSets
    }
}
