//
//  FilterModel.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 7/07/22.
//

import Foundation

public enum FilterType {
    case GreaterThan
    case GreaterOrEqualTo
    case LessThan
    case LessOrEqualTo
    case equalTo
}

public struct FilterModel {
    var field:String
    var filterType:FilterType
    var value:Any
    public init(field:String, filterType:FilterType, value:Any){
        self.field = field
        self.value = value
        self.filterType = filterType
    }
}
