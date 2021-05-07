//
//  UndoControllerExampleApp.swift
//  UndoControllerExample
//
//  Created by Никита Белокриницкий on 07.05.2021.
//

import SwiftUI
import UndoController

@main
struct UndoControllerApp: App {
    @StateObject private var undoController: UndoController = UndoController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Example of using the UndoController in nested views using EnvironmentObject.
                // Note, in this case the UndoController will overlap the TabView.
                // This happens because UndoController is added to the view that contains the TabView.
                .environmentObject(undoController)
                .add(undoController)
        }
    }
}
