//
//  codefyApp.swift
//  codefy
//
//  Created by Oscar Angulo on 5/14/25.
//

import SwiftUI
import FirebaseCore

@main
struct codefyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
