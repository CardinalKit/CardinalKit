//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct ValueCoding: Equatable, Codable, RawRepresentable {
    enum CodingKeys: String, CodingKey {
        case code
        case system
        case display
    }
    
    
    let code: String
    let system: String
    let display: String?
    
    var rawValue: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        guard let data = try? encoder.encode(self) else {
            return "{}"
        }
        
        return String(decoding: data, as: UTF8.self)
    }
    
    
    init(code: String, system: String, display: String?) {
        self.code = code
        self.system = system
        self.display = display
    }
    
    init?(rawValue: String) {
        let data = Data(rawValue.utf8)
        guard let valueCoding = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        
        self = valueCoding
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decode(String.self, forKey: .code)
        self.system = try values.decode(String.self, forKey: .system)
        self.display = try values.decodeIfPresent(String.self, forKey: .display)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(system, forKey: .system)
        try container.encode(display, forKey: .display)
    }
}
