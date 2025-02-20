//
//  AssistantApp.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 21/02/25.
//

import SwiftUI

@main
struct AssistantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
