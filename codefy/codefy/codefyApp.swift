//
//  codefyApp.swift
//  codefy
//
//  Created by Oscar Angulo on 5/14/25.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import UIKit

func setupTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.21, alpha: 1.0) // #1A1F36
    appearance.stackedLayoutAppearance.selected.iconColor = .white
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
    UITabBar.appearance().standardAppearance = appearance
    if #available(iOS 15.0, *) {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

@main
struct codefyApp: App {
    init() {
        FirebaseApp.configure()
        setupTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
