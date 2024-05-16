//
//  LogUtilities.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/24.
//

import Foundation

// MARK: - Log
// inline log，格式如：时间(精确到ms): 调用位置的类名.方法名.参数 - message
@inline(__always)
func log(_ message: String = "", level: LogLevel = .verbose, file: String = #file, function: String = #function) {
    let time = CFAbsoluteTimeGetCurrent()
    let timeStr = String(format: "%.3f", time)

    let fileName = URL(fileURLWithPath: file).lastPathComponent.split(separator: ".")[0]
    print("\(level)\(timeStr): \(fileName).\(function) \(message)")
}

@inline(__always)
func log(_ level: LogLevel = .verbose, _ tag: String = "", _ message: Any..., file: String = #file, function: String = #function) {
    let time = CFAbsoluteTimeGetCurrent()
    let timeStr = String(format: "%.3f", time)

    let fileName = URL(fileURLWithPath: file).lastPathComponent.split(separator: ".")[0]
#if DEBUG
    print("\(level.rawValue)\(timeStr): \(fileName)-\(function)", tag, message ?? "")
#endif
}

enum LogLevel: String {
    case verbose = ""
    case info = "🟣 "
    case node = "🟢 "
    case warning = "🟡 "
    case error = "🔴 "
}

// 打印堆栈
func printCallStack() {
    let callStackSymbols = Thread.callStackSymbols
    for symbol in callStackSymbols {
        print(symbol)
    }
}
