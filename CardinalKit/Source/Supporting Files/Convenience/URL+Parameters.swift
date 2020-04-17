//
//  URL+Parameters.swift
//  CS342Support
//
//  Created by Santiago Gutierrez on 11/5/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation

extension URL {
    
    public func getQueryString(parameter: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        return url.queryItems?.first(where: { $0.name == parameter })?.value
    }
    
}
