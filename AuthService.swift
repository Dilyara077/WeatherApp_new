import FirebaseAuth

final class AuthService {
    static let shared = AuthService()

    private init() {}

    func signInAnonymouslyIfNeeded() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("Auth error:", error.localizedDescription)
                } else {
                    print("Signed in anonymously, uid:", result?.user.uid ?? "")
                }
            }
        }
    }
}
