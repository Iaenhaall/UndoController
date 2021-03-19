//
//  UndoController.swift
//  UndoController
//
//  Created by Никита Белокриницкий on 17.03.2021.
//

import SwiftUI

/// The controller that allows a user to undo an action within a few seconds. It looks like the system HUDs.
final public class UndoController: ObservableObject {
    /// Boolean variable indicating whether the `UndoController` is currently displayed or not.
    @Published fileprivate(set) var isPresented: Bool = false
    /// Time in seconds remaining before the `UndoController` disappears.
    @Published private(set) var seconds: Double = 0
    /// The message text that is displayed on the `UndoController`.
    private(set) var message: String = ""
    /// The action that will be performed if the `UndoController`'s life time has expired.
    private(set) var timerAction: (() -> ())?
    /// The action that will be performed if a user undoes the action.
    private(set) var undoAction: (() -> ())?
    fileprivate let indents: EdgeInsets
    private var timer: Timer?
    
    /**
     Creates an UndoController instance.
     
     - parameter padding: An optional parameter that allows to set indents for UndoController from the boundaries of the view to which it is added.
     */
    public init(indents: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)) {
        self.indents = indents
    }
    
    /**
     Displays the `UndoController` with the specified parameters.
     
     - parameter message: The message text that is displayed on the `UndoController`.
     - parameter seconds: The `UndoController` lifetime.
     - parameter timerAction: The action that will be performed if the `UndoController`'s life time has expired.
     - parameter undoAction: The action that will be performed if a user undoes the action.
     */
    public func show(message: String, time seconds: UInt = 5, timerAction: (() -> ())? = nil, undoAction: @escaping () -> ()) {
        DispatchQueue.main.async {
            self.reset()
            self.message = message
            self.seconds = Double(seconds > 99 ? 99 : seconds)
            self.timerAction = timerAction
            self.undoAction = undoAction
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.seconds -= 1
                if self.seconds == 0 {
                    withAnimation { self.isPresented = false }
                    if let timerAction = timerAction { timerAction() }
                    self.reset()
                }
            }
            
            withAnimation { self.isPresented = true }
        }
    }
    
    /// Resets the controller parameters to their initial values.
    fileprivate func reset() {
        self.timer?.invalidate()
        self.timer = nil
        self.seconds = 0
        self.message = ""
        self.timerAction = nil
        self.undoAction = nil
    }
}

extension View {
    /**
     Adds the `UndoController` to the view.
     
     - parameter undoController: `UndoController` with the specified parameters.
     - returns: ZStack that contains the view and UndoController.
     
     # Notes: #
     1. It is recommended to embed in a view that takes up the entire screen area.
     2. To access `UndoController` from nested views, `EnvironmentObject` wrapper can be used.
     */
    func add(_ undoController: UndoController) -> some View {
        ZStack(alignment: .bottom) {
            self

            if undoController.isPresented {
                HStack(alignment: .center, spacing: 10) {
                    Text(String(Int8(undoController.seconds)))
                        .font(.title)
                        .frame(width: 36) // The fixed width prevents the jerking of the controller during timer operation.

                    Text(undoController.message)

                    Button(action: {
                        withAnimation { undoController.isPresented = false }
                        undoController.undoAction!()
                        undoController.reset()
                    }, label: {
                        Text("Undo", comment: "The undo button text on the UndoController.")
                            .font(.headline)
                    })
                }
                .padding(EdgeInsets(top: 16, leading: 23, bottom: 16, trailing: 23))
                .background(
                    Capsule()
                        .foregroundColor(Color(UIColor.tertiarySystemBackground))
                        .shadow(color: Color(.gray).opacity(0.35), radius: 12, x: 0, y: 5)
                )
                .padding(undoController.indents)
                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                .zIndex(.infinity)
            }
        }
    }
}
