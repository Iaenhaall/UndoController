//
//  ListExample.swift
//  UndoController
//
//  Created by Никита Белокриницкий on 18.03.2021.
//

import SwiftUI

struct ListExample: View {
    @State private var names: [String] = [
        "Elizabeth", "James", "Jennifer", "John", "Linda", "Mary", "Michael", "Patricia", "Robert", "William"
    ]
    @StateObject private var undoController: UndoController = UndoController()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(names, id: \.self) { name  in
                    NavigationLink(destination: Text(name).padding().font(.largeTitle)) {
                        Text(name)
                            .padding()
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Names")
//            .add(undoController) // The next View in the NavigationView stack overlaps UndoController when the NavigationLink is activated.
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .add(undoController) // Stays above NavigationView when NavigationLink is activated.
    }
    
    func delete(at offsets: IndexSet) {
        var removedNames: [Int: String] = [:]
        
        for index in offsets {
            removedNames.updateValue(names[index], forKey: index)
            names.remove(at: index)
        }
        
        // Shows UndoController after name is deleted.
        undoController.show(message: "After deletion, the name cannot be restored!", time: 5) {
            for index in removedNames.keys.sorted() {
                names.insert(removedNames[index]!, at: index)
            }
        }
    }
}

struct ListExample_Previews: PreviewProvider {
    static var previews: some View {
        ListExample()
    }
}
