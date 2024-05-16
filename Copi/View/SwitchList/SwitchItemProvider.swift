//
//  SwitchItemProvider.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/1.
//

import Foundation

class SwitchItemProvider {
    static let shared = SwitchItemProvider()
    
    static func loadFromAssets() async -> [SensitiveDataRegexModel] {
        guard let path = Bundle.main.path(forResource: "regex", ofType: "json") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path.string))
            return try JSONDecoder().decode([SensitiveDataRegexModel].self, from: data)
        } catch {
            print(error)
        }

        return []
    }
}

extension SensitiveDataRegexModel {
    static func fromJson(_ json: String) -> [SensitiveDataRegexModel] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        let model = try? JSONDecoder().decode([SensitiveDataRegexModel].self, from: data)

        return model ?? []
    }
    
    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: name)
    }
    
    func filter(_ value: String, template: (String) -> String = { _ in "REPLACED" }) -> String {
        // 创建正则表达式对象
        print("filtering by regex", regex)
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
}
