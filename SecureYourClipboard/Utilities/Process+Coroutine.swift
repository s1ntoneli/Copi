//
//  Process+Coroutine.swift
//  SecureYourClipboard
//
//  Created by lixindong on 2024/4/26.
//

import Foundation

extension Process {
    public func launching() async throws -> (out: Pipe, err: Pipe) {
        let (stdout, stderr) = (Pipe(), Pipe())

        standardOutput = stdout
        standardError = stderr

        do {
            #if swift(>=4.0)
            if #available(OSX 10.13, *) {
                try run()
            } else if let path = launchPath, FileManager.default.isExecutableFile(atPath: path) {
                launch()
            } else {
                throw ProcessError.notExecutable(launchPath)
            }
            #else
            guard let path = launchPath, FileManager.default.isExecutableFile(atPath: path) else {
                throw ProcessError.notExecutable(launchPath)
            }
            launch()
            #endif
        } catch {
            throw error
        }

        self.waitUntilExit()

        guard self.terminationReason == .exit, self.terminationStatus == 0 else {
            let stdoutData = try? self.readDataFromPipe(stdout)
            let stderrData = try? self.readDataFromPipe(stderr)

            let stdoutString = stdoutData.flatMap { (data: Data) -> String? in String(data: data, encoding: .utf8) }
            let stderrString = stderrData.flatMap { (data: Data) -> String? in String(data: data, encoding: .utf8) }

            throw ProcessError.execution(process: self, standardOutput: stdoutString, standardError: stderrString)
        }
        return (stdout, stderr)
    }

    private func readDataFromPipe(_ pipe: Pipe) throws -> Data {
        let handle = pipe.fileHandleForReading
        defer { handle.closeFile() }

        let fd = handle.fileDescriptor

        let bufsize = 1024 * 8
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsize)
        defer { buf.deallocate() }

        var data = Data()

        while true {
            let bytesRead = read(fd, buf, bufsize)

            if bytesRead == 0 {
                break
            }

            if bytesRead < 0 {
                throw POSIXError.Code(rawValue: errno).map { POSIXError($0) } ?? CocoaError(.fileReadUnknown)
            }

            data.append(buf, count: bytesRead)
        }

        return data
    }

    public enum ProcessError: Error {
        case notExecutable(String?)
        case execution(process: Process, standardOutput: String?, standardError: String?)
    }
}

extension Process.ProcessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notExecutable(let path?):
            return "File not executable: \(path)"
        case .notExecutable(nil):
            return "No launch path specified"
        case .execution(process: let task, standardOutput: _, standardError: _):
            return "Failed executing: `\(task)` (\(task.terminationStatus))."
        }
    }
}
//
//public extension Promise where T == (out: Pipe, err: Pipe) {
//    func print() -> Promise<T> {
//        return tap { result in
//            switch result {
//            case .fulfilled(let raw):
//                let stdout = String(data: raw.out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
//                let stderr = String(data: raw.err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
//                Swift.print("stdout: `\(stdout ?? "")`")
//                Swift.print("stderr: `\(stderr ?? "")`")
//            case .rejected(let err):
//                Swift.print(err)
//            }
//        }
//    }
//}

extension Process {
    open override var description: String {
        let launchPath = self.launchPath ?? "$0"
        var args = [launchPath]
        arguments.flatMap{ args += $0 }
        return args.map { arg in
            let contains: Bool
            #if swift(>=3.2)
            contains = arg.contains(" ")
            #else
            contains = arg.characters.contains(" ")
            #endif
            if contains {
                return "\"\(arg)\""
            } else if arg == "" {
                return "\"\""
            } else {
                return arg
            }
        }.joined(separator: " ")
    }
}
