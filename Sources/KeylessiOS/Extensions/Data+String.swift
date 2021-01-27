//
//  File.swift
//  
//
//  Created by Ubaldo Cotta on 26/1/21.
//

import Foundation

extension Data {
    var hexString: String {
        return self.reduce("", { $0 + String(format: "%02x", $1) })
    }
    
    var string: String {
        return String(bytes: self, encoding: .utf8) ?? ""
    }
}
