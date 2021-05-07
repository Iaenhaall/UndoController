# UndoController

The controller that allows a user to undo an action within seconds. It looks like the system HUDs.

![Example](Images/Example.gif)



## Installation

#### Via Swift Package Manager

1. In Xcode 11 or greater select `File ▸ Swift Packages ▸ Add Package Dependency`.
2. Paste the link to this repo https://github.com/Iaenhaall/UndoController.git and click **Next**.
3. Define the package options for this package or select the default. Click **Next**.
4. Xcode downloads the code from GitHub and adds the package to the your project target. Click **Finish**.

#### Manually

1. Add **[UndoController.swift](https://github.com/Iaenhaall/UndoController/blob/master/Sources/UndoController/UndoController.swift)** file to your project.

   That's all. There are no dependencies.



## Usage

You can clone the repo and run the **UndoControllerExample** project to explore the `UndoController` features.

These are the main points to pay attention to.

1. Create an `UndoController` instance.

   ```swift
   @StateObject private var undoController: UndoController = UndoController()
   ```

   If you are not satisfied with the standard indents, use the `UndoController(indents:)` initializer.

   ```swift
   @StateObject private var undoController: UndoController = UndoController(indents: EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
   ```

2. Add `UndoController` to the desired View.

   It is recommended to add to the view that occupies the entire screen area. For example, to `NavigationView`.

   ```swift
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
   //  .add(undoController) // The next View in the NavigationView stack overlaps UndoController when the NavigationLink is activated.
   }
   .add(undoController) // Stays above NavigationView when NavigationLink is activated.
   ```

   To access `UndoController` from nested Views, `EnvironmentObject` wrapper can be used.

   In this case, the `UndoController`, will be available from any application View.

   ```swift
   struct Application: App {
       @StateObject private var undoController: UndoController = UndoController()
       
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(undoController)
                   .add(undoController)
           }
       }
   }
   ```

   **Note**, in this case the `UndoController` will overlap Views such as `TabView`. To avoid this, add the controller only to necessary Views (`NavigationView`, `List`, etc.) or increase its indentations. The behavior of the `UndoController` depends on which View you add it to. For example, when it is added to a `NavigationView`, it will be displayed above all views in the navigation stack. When it is added to a specific View that is inside the navigation stack, it will only appear above that View.

3. Call the `UndoController` when needed. In the example, it happens when user deletes a name from the `List`.

   The **Show** function accepts the following parameters:

   * **time**: The `UndoController` lifetime. *The default value is 5 sec.*
   * **timerAction**: The action that will be performed if the `UndoController`'s life time has expired. *It can be nil.*
   * **undoAction**: The action that will be performed if a user undoes the action.
   * **content**: The content that is displayed on the `UndoController`. The content can be any view, such as `Text`, `Label`, `VStack`, etc.

   **Please note** that when the **Show** method is called again (while `UndoController` is present) the **timerAction** closure from the previous method call is executed.

   ```swift
   func delete(at offsets: IndexSet) {
       ...
       // Shows UndoController after name is deleted.
       undoController.show(time: 5,
                           undoAction: {
                               // Actions required to undo name deletion.
                           })
       {
           // UndoController context.
           Text("After deletion, the name cannot be restored!")
       }
   }
   ```

   To undo actions you can write your own code or use the system [UndoManager](https://developer.apple.com/documentation/foundation/undomanager).

