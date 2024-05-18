//
//  SpeechRecognizedDemoApp.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/17.
//

import SwiftUI

@main
struct SpeechRecognizedDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SpeechRecognizer())
        }
    }
}
