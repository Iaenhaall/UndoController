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
                undoController.show(time: 10,
                                    timerAction: {
                                        print("Timer")
                                    },
                                    undoAction: {
                                        print("Undo!")
                                    })
                {
                    VStack(alignment: .center, spacing: 5) {
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25, alignment: .center)
                            .foregroundColor(.gray)
                        
                        Text("Content of UndoController that contains the Image and Text inside VStack!")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    .frame(minWidth: .zero, maxWidth: .infinity, alignment: .center) // Makes the UndoController fill the entire width of the View.
                }
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
