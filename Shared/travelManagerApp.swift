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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
