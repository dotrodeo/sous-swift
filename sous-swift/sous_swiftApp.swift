//
//  sous_swiftApp.swift
//  sous-swift
//
//  Created by Derek Wheelden on 11/10/25.
//

import SwiftData
import SwiftUI

@main
struct sous_swiftApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
