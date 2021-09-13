import SwiftUI

@main
struct AsyncAwaitSampleApp: App {
    
    @State private var isPresented: Bool = false
    
    // deinitを確認するためにSheetで表示している
    var body: some Scene {
        WindowGroup {
            VStack {
                Button("Home") {
                    isPresented = true
                }
            }.sheet(isPresented: $isPresented) {
                isPresented = false
            } content: {
                ContentView(viewModel: AsyncViewModel())
            }

        }
    }
}
