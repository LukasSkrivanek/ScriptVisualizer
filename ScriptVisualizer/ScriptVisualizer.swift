//
//  TaskTryApp.swift
//  TaskTry
//
//  Created by macbook on 27.04.2024.
//

import SwiftUI

@main
struct ScriptVisualizer: App {
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
