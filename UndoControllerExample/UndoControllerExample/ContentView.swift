//
//  ContentView.swift
//  UndoControllerExample
//
//  Created by Никита Белокриницкий on 07.05.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ListExample()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            
            AppExample()
                .tabItem {
                    Label("App", systemImage: "app")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
