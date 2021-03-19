//
//  AppExample.swift
//  UndoController
//
//  Created by Никита Белокриницкий on 19.03.2021.
//

import SwiftUI

struct AppExample: View {
    @State private var text: String = ""
    @EnvironmentObject private var undoController: UndoController
    
    var body: some View {
        VStack {
            Button("Show UndoController") {
                undoController.show(message: "UndoController message!",
                                    time: 3,
                                    timerAction: {
                                        print("Timer")
                                    },
                                    undoAction: {
                                        print("Undo!")
                                    })
            }
            
            TextField("Enter text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}

struct AppExample_Previews: PreviewProvider {
    static var previews: some View {
        AppExample()
    }
}
