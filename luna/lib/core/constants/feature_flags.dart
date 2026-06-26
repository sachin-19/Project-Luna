/// Feature flags — one place to enable/disable major features.
/// Flip kClaudeEnabled to true once the Firebase Cloud Function is deployed
/// and the Anthropic API key is configured server-side.
const bool kClaudeEnabled = false;

/// Flip to true after adding google-services.json to android/app/ and running
/// `flutter pub get`. Without the file, Firebase.initializeApp() will throw.
const bool kFirebaseEnabled = true;
