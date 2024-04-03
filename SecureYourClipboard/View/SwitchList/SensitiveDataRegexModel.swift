//
//  SensitiveDataRegexModel.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/1.
//

import Foundation

struct SensitiveDataRegexModel: Codable {
    var name: String
    var regex: String
    var systemImage: String? = nil
    var description: String
    var author: String
    var example: [ExampleModel] = []
    
    struct ExampleModel: Codable {
        let input: String
        let output: String
    }
}
