import Foundation

class JailbreakDetector {
    static func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #endif

        let jailbreakFiles = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Icy.app",
            "/Applications/FakeCarrier.app",
            "/Library/MobileSubstrate/DynamicLibraries/",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia/",
            "/private/var/mobile/Library/SBSettings/Themes/",
            "/private/var/stash",
            "/usr/libexec/ssh-keysign",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/etc/ssh/sshd_config",
            "/bin/bash",
            "/usr/bin/sudo",
            "/usr/bin/su",
        ]

        for file in jailbreakFiles {
            if FileManager.default.fileExists(atPath: file) {
                return true
            }
        }

        if canWriteToSystemDirectory() { return true }
        if canOpenCydiaURL() { return true }
        if hasEnvironmentVariableForInjection() { return true }
        if FileManager.default.fileExists(atPath: "/etc/apt") { return true }

        return false
    }

    private static func canWriteToSystemDirectory() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
        #endif
    }

    private static func canOpenCydiaURL() -> Bool {
        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
    }

    private static func hasEnvironmentVariableForInjection() -> Bool {
        return ProcessInfo.processInfo.environment["DYLD_INSERT_LIBRARIES"] != nil
    }
}
