//
//  travelManagerApp.swift
//  Shared
//
//  Created by Sunbae lee on 2022/08/15.
//

import SwiftUI

@main
struct travelManagerApp: App {
    let persistenceController = PersistenceController.shared
    // 0: System, 1: Light, 2: Dark
    @AppStorage("selectedAppearance") var selectedAppearance: Int = 0 

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(mapColorScheme()) // Apply preferred color scheme
        }
    }
    
    // Helper function to map stored Int to ColorScheme
    private func mapColorScheme() -> ColorScheme? {
        switch selectedAppearance {
        case 1: return .light
        case 2: return .dark
        default: return nil // System setting
        }
    }
}
