import SwiftUI

struct ContentView: View {
    @State private var isSearching = false

    var body: some View {
        if isSearching {
            CompassView()
        } else {
            StartView(onStart: { isSearching = true })
        }
    }
}
