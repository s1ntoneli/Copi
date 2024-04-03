//
//  AppleScriptUtilities.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/1.
//

import Foundation
import Automator

// 创建一个AppleScript字符串
let script = """
contents of selection
"""

func callAppleScript() {
    // 创建一个NSAppleScript对象
    if let appleScript = NSAppleScript(source: script) {
        var error: NSDictionary?
        // 执行AppleScript
        if let output = appleScript.executeAndReturnError(&error).stringValue {
            print("AppleScript output: \(output)")
        } else if let error = error {
            print("AppleScript error: \(error)")
        }
    } else {
        print("Failed to create NSAppleScript object")
    }
}

func callAppleScript2() {
//    let ascr = "tell application id \"MACS\" to reveal some item in the first Finder window"
    let ascr = "get contents of selection"
//    let ascr = """
//            tell application "System Events"
//                set selectedText to (get contents of selection)
//            end tell
//            return selectedText
//            """
//    let ascr = """
//            tell application "System Events"
//                set selectedText to (get the clipboard)
//            end tell
//            return selectedText
//            """
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: ascr) {
        if let scriptResult = scriptObject
            .executeAndReturnError(&error)
            .stringValue {
                print(scriptResult)
        } else if (error != nil)  {
            print("error: ",error!)
        }
    }
}

func callAppleScript3() {
    guard let path = Bundle.main.path(forResource: "getselection", ofType: "applescript") else {
        print("not found getselection.applescript")
        return
    }
    
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    
    task.arguments = [path]
     
    try? task.run()
}

func runWorkflow() {
    guard let workflowPath = Bundle.main.path(forResource: "AppleScriptTest", ofType: "workflow") else {
            print("Workflow resource not found")
            return
        }

        let workflowURL = URL(fileURLWithPath: workflowPath)
        do {
            try AMWorkflow.run(at:workflowURL, withInput: "selection")
        } catch {
            print("Error running workflow: \(error)")
        }
}

import ApplicationServices
import Cocoa

func getSelectedTextByAXUI() -> String? {
    let systemWideElement = AXUIElementCreateSystemWide()

    var selectedTextValue: AnyObject?
    let errorCode = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &selectedTextValue)
    
    if errorCode == .success {
        let selectedTextElement = selectedTextValue as! AXUIElement
        var selectedText: AnyObject?
        let textErrorCode = AXUIElementCopyAttributeValue(selectedTextElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textErrorCode == .success, let selectedTextString = selectedText as? String {
            return selectedTextString
        } else {
            return nil
        }
    } else {
        return nil
    }
}

func getSelectedTextByCopy() -> String? {
    var result: String? = nil
    let pasteboard = NSPasteboard.general
    pasteboard.onPrivateMode {
        let changeCount = pasteboard.changeCount
        print("changeCount before copy", changeCount)
        callSystemCopy()
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            print("changeCount after copy", pasteboard.changeCount)
            if changeCount != pasteboard.changeCount {
                result = pasteboard.string(forType: .string)
                print("get result", result)
            }
            semaphore.signal()
        }
        print("wait")
        semaphore.wait()
        print("wait finished")
    }
    print("return result", result)
    return result
}

func getSelectedText() -> String? {
    return getSelectedTextByAXUI() ?? getSelectedTextByCopy()
}
