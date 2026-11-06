import Foundation

/// The app's name (the same in every language) and bundle ID, kept apart from Satsuma so both apps are never confused. A debug build is
/// "Swivel Dev" with an ID of its own, so it never shares settings, keychain items or the Services menu with the real app by accident;
/// the two never run at the same time (`SingleInstance`). `scripts/build.sh` uses the same values (checked by a test).
enum AppIdentity {
    #if DEBUG
    static let name = "Swivel Dev"
    static let bundleID = "io.github.jonasnlt.swivel.debug"
    #else
    static let name = "Swivel"
    static let bundleID = "io.github.jonasnlt.swivel"
    #endif
    /// Both builds, for messages about the other one.
    static let releaseName = "Swivel"
    static let debugName = "Swivel Dev"
    /// "1.0.0", and for Swivel Dev "1.0.0 (Dev)" (its Info.plist has the same numbers as the release).
    static var versionText: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        return short + (buildMark.map { " (\($0))" } ?? "")
    }

    /// What the About window shows in brackets after the version: the build number, or "Dev".
    static var buildMark: String? {
        #if DEBUG
        return "Dev"
        #else
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        #endif
    }

    /// Where the source code is (GPL-3.0). The app only hands these addresses to the browser; it never connects anywhere itself.
    static let repositoryURL = URL(string: "https://github.com/jonasnlt/swivel")!
    /// "Check for Updates …" opens this page; Swivel has no update function of its own.
    static let releasesURL = URL(string: "https://github.com/jonasnlt/swivel/releases")!
    /// Shown in the About window and in Info.plist (`scripts/build.sh` writes the same line).
    static let copyright = "Copyright © 2026 jonasnlt"
}
