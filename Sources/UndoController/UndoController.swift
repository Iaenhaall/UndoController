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
    @Published private(set) var isPresented: Bool = false
    /// Time in seconds remaining before the `UndoController` disappears.
    @Published private(set) var seconds: Double = .zero
    /// The content that is displayed on the `UndoController`. The content can be any view, such as `Text`, `Label`, `VStack`, etc.
    private(set) var content: AnyView?
    /// The action that will be performed if the `UndoController`'s life time has expired.
    private(set) var timerAction: (() -> ())?
    /// The action that will be performed if a user undoes the action.
    private(set) var undoAction: (() -> ())?
    fileprivate let indents: EdgeInsets
    private var timer: Timer?
    fileprivate(set) var id: Double = .zero
    
    /**
     Creates an UndoController instance.
     
     - parameter padding: An optional parameter that allows to set indents for UndoController from the boundaries of the view to which it is added.
     */
    public init(indents: EdgeInsets = EdgeInsets(top: .zero, leading: 20, bottom: 20, trailing: 20)) {
        self.indents = indents
    }
    
    /**
     Displays the `UndoController` with the specified parameters.
     
     - parameter seconds: The `UndoController` lifetime.
     - parameter timerAction: The action that will be performed if the `UndoController`'s life time has expired.
     - parameter undoAction: The action that will be performed if a user undoes the action.
     - parameter content: The content that is displayed on the `UndoController`. The content can be any view, such as `Text`, `Label`, `VStack`, etc.
     */
    public func show<Content: View>(time seconds: UInt = 5, timerAction: (() -> ())? = nil, undoAction: @escaping () -> (), @ViewBuilder content: @escaping () -> Content) {
        DispatchQueue.main.async {
            // Executes timerAction if the controller has already been presented.
            self.timerAction?()
            self.id = Double(Date().timeIntervalSince1970)
            self.content = AnyView(content())
            self.seconds = Double(seconds > 99 ? 99 : seconds)
            self.timerAction = timerAction
            self.undoAction = undoAction
            
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.seconds -= 1
                if self.seconds == .zero {
                    // A small delay so that 0 can be displayed before the UndoController is hidden.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.hide()
                    }
                }
            }
            
            withAnimation { self.isPresented = true }
        }
    }
    
    /// Immediately ends the lifetime of the `UndoController`.
    public func hide() {
        self.hide(by: self.timerAction)
    }
    
    /// Immediately ends the lifetime of the `UndoController` with the specified action.
    fileprivate func hide(by action: (() -> ())?) {
        if self.isPresented {
            withAnimation { self.isPresented = false }
            action?()
            self.reset()
        }
    }
    
    /// Resets the controller parameters to their initial values.
    private func reset() {
        self.timer?.invalidate()
        self.timer = nil
        self.seconds = .zero
        self.content = nil
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
    public func add(_ undoController: UndoController) -> some View {
        ZStack(alignment: .bottom) {
            self

            if undoController.isPresented {
                HStack(alignment: .center, spacing: 10) {
                    Text(String(Int8(undoController.seconds)))
                        .font(.title)
                        .frame(width: 36) // The fixed width prevents the jerking of the controller during timer operation.
                        .id(undoController.seconds)
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)).combined(with: .opacity))

                    undoController.content

                    Button(action: { undoController.hide(by: undoController.undoAction) },
                           label: {
                            Text("Undo", comment: "The undo button text on the UndoController.")
                                .font(.headline)
                           })
                }
                .clipped()
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .background(
                    Capsule()
                        .foregroundColor(Color(UIColor.tertiarySystemBackground))
                        .shadow(color: Color(.black).opacity(0.35), radius: 12, x: 0, y: 5)
                )
                .padding(undoController.indents)
                .id(undoController.id)
                .zIndex(undoController.id)
                .transition(.move(edge: .bottom))
                .animation(.default)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
            // Executes timerAction if a user or the system has terminated the application.
            // Warning: Not called from background.
            undoController.hide()
        }
    }
}
