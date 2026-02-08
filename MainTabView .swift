import SwiftUI
import FirebaseAuth

struct MainTabView: View {

    var body: some View {
        TabView {

            // 🌤 Weather (7-й ассайнмент)
            ContentView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }

            // ⭐ Favorites (8-й ассайнмент)
            if let uid = Auth.auth().currentUser?.uid {
                FavoritesView(
                    vm: FavoritesViewModel(uid: uid)
                )
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
            } else {
                Text("Signing in...")
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
            }
        }
    }
}
