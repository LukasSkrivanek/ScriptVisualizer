//
//  HomeViewModel.swift
//  TaskTry
//
//  Created by macbook on 30.04.2024.
//
import Foundation
import Observation

@Observable
final class HomeViewModel{
    let coloredStrings = ["let" , "func", "print", "enum", "var", "final", "struct", "private", "do", "catch"]
    var scriptText: String = ""
    var outputText: String = ""
    var isRunning: Bool = false
    var lastExitCode: Int32 = 0
    var filePath: String = ""
    var lastExitCodeVisible = false
    
    func executeScript() {
        isRunning = true
        outputText = ""
        if scriptText.isEmpty {
            // if the text is empty, we will execute script from the file
            executeScriptFromFile(atPath: filePath)
        } else {
            // execute script from the code
            executeScriptFromCode()
        }
    }
    private func executeScriptFromCode() {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("scriptFromCode.swift")
        do {
            try scriptText.write(to: tempURL, atomically: true, encoding: .utf8)
            executeScriptFromFile(atPath: tempURL.path)
        } catch {
            print("Error writing script to temporary file: \(error)")
            self.isRunning = false
        }
    }
    private func executeScriptFromFile(atPath filePath: String? = nil) {
        var arguments: [String] = []
        
        if let filePath = filePath {
            let fileURL = URL(fileURLWithPath: filePath)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                outputText = "File not found at path: \(filePath)"
                self.isRunning = false
                return
            }
            arguments = [fileURL.path] // use path to file as a argument
        }
        let task = Process()
        task.launchPath = "/usr/bin/swift" // path to command swift
        task.arguments = arguments // pass arguments to run the script
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        let errorPipe = Pipe()
        task.standardError = errorPipe
        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                self.isRunning = false
                self.lastExitCode = task.terminationStatus
            }
        }
        do {
            try task.run() // start the process
            let outputHandle = outputPipe.fileHandleForReading
            outputHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputText.append(output)
                    }
                }
            }
            let errorHandle = errorPipe.fileHandleForReading
            errorHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if let errorOutput = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputText.append(errorOutput)
                    }
                }
            }
        } catch {
            print("Error running script: \(error)")
            self.isRunning = false
        }
    }
}
