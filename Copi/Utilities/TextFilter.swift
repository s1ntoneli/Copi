//
//  Filter.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/3/28.
//

import Foundation

enum TextFilter: CaseIterable {
    
    case phone
    case email
    case url
    case creditCard
    case bankAccount
    case crypto
    //    case custom(String, String)
    
    var name: String {
        switch self {
        case .phone:
            return "Phone"
        case .email:
            return "Email"
        case .url:
            return "URL"
        case .creditCard:
            return "Credit Card"
        case .bankAccount:
            return "Bank Account"
        case .crypto:
            return "Crypto"
            //        case .custom(let name, _):
            //            return name
        }
    }
    
    var regex: String {
        switch self {
        case .phone:
            return #"\b\+?\d{1,3}[-\s]?\d{3,14}\b"#
        case .email:
            return #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#
        case .url:
            return #"\b((https?|ftp|file):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|])\b"#
        case .creditCard:
            return #"\b((\d{4}[- ]?){3}\d{4})\b"#
        case .bankAccount:
            return #"\b(\d{4}[- ]?){3}\d{4}\b"#
        case .crypto:
            return #"\b(0x[a-fA-F0-9]{40})\b"#
            //        case .custom(_, let regex):
            //            return regex
        }
    }
    
    // Storage key for UserDefaults
    // This key is used to store the state of the filter in UserDefaults
    // It should be unique for each filter
    var storageKey: String {
        switch self {
        case .phone:
            return "phone"
        case .email:
            return "email"
        case .url:
            return "url"
        case .creditCard:
            return "creditCard"
        case .bankAccount:
            return "bankAccount"
        case .crypto:
            return "crypto"
            //        case .custom(let name, _):
            //            return name
        }
    }
    
    var systemImage: String {
        switch self {
        case .phone:
            return "phone"
        case .email:
            return "envelope"
        case .url:
            return "link"
        case .creditCard:
            return "creditcard"
        case .bankAccount:
            return "banknote"
        case .crypto:
            return "bitcoinsign.circle"
        }
    }
    
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: storageKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }
    
    func filter(_ value: String, template: (String) -> String = { _ in "REPLACED" }) -> String {
        // 创建正则表达式对象
        if let regex = try? NSRegularExpression(pattern: regex, options: []) {
            // 查找匹配的字符串
            let matches = regex.matches(
               in: value,
               options: [],
               range: NSMakeRange(0, value.count)
           )
            let mutableString = NSMutableString(string: value)
            matches.reversed().forEach { match in
                guard let range = Range(match.range, in: value) else { return }

                let replacement = template(String(value[range]))
                regex.replaceMatches(in: mutableString, range: match.range, withTemplate: replacement)
            }

            print(mutableString)
            return mutableString as String
        } else {
            print("Invalid regular expression pattern.")
        }
        return value
    }
    
    static var allEnabledCases: [TextFilter] {
        return allCases.filter { $0.isEnabled }
    }
}
