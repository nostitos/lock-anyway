import ApplicationServices
import AppKit
import Foundation

public protocol LockControlling {
    func availability(promptForAccessibility: Bool) -> LockAvailability
    func lockNow() throws
}

public struct LockStrategyResolver {
    public var cgSessionCandidates: [String]
    public var isExecutableFile: (String) -> Bool
    public var isAccessibilityTrusted: () -> Bool

    public init(
        cgSessionCandidates: [String] = LockService.defaultCGSessionCandidates,
        isExecutableFile: @escaping (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) },
        isAccessibilityTrusted: @escaping () -> Bool = { AXIsProcessTrusted() }
    ) {
        self.cgSessionCandidates = cgSessionCandidates
        self.isExecutableFile = isExecutableFile
        self.isAccessibilityTrusted = isAccessibilityTrusted
    }

    public func resolve() -> LockAvailability {
        if let path = cgSessionCandidates.first(where: isExecutableFile) {
            return .available(.cgSession(path: path))
        }

        if isAccessibilityTrusted() {
            return .available(.keyboardShortcut)
        }

        return .unavailable(
            "Accessibility permission is required to send Control-Command-Q on this macOS version.",
            requiresAccessibilityPermission: true
        )
    }
}

public final class LockService: LockControlling {
    public static let defaultCGSessionCandidates = [
        "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession",
        "/System/Library/CoreServices/CGSession",
        "/usr/bin/CGSession",
        "/bin/CGSession"
    ]

    private let logger: IdleLockLogger
    private let resolverFactory: () -> LockStrategyResolver

    public init(
        logger: IdleLockLogger,
        resolverFactory: @escaping () -> LockStrategyResolver = { LockStrategyResolver() }
    ) {
        self.logger = logger
        self.resolverFactory = resolverFactory
    }

    public func availability(promptForAccessibility: Bool = false) -> LockAvailability {
        let resolved = resolverFactory().resolve()
        if resolved.strategy != nil || !promptForAccessibility || !resolved.requiresAccessibilityPermission {
            return resolved
        }

        requestAccessibilityPermission()
        return resolverFactory().resolve()
    }

    public func lockNow() throws {
        let available = availability(promptForAccessibility: true)
        guard let strategy = available.strategy else {
            throw IdleLockError.lockUnavailable(available.reason ?? "No lock strategy is available.")
        }

        switch strategy {
        case .cgSession(let path):
            try runCGSession(path: path)
        case .keyboardShortcut:
            try postLockShortcut()
        }
    }

    public func requestAccessibilityPermission() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]
        _ = AXIsProcessTrustedWithOptions(options)
    }

    public func openAccessibilityPermissionHelp() {
        requestAccessibilityPermission()
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func runCGSession(path: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["-suspend"]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw IdleLockError.lockCommandFailed("Unable to run CGSession: \(error.localizedDescription)")
        }

        guard process.terminationStatus == 0 else {
            throw IdleLockError.lockCommandFailed("CGSession exited with status \(process.terminationStatus).")
        }

        logger.log("Lock command sent with CGSession")
    }

    private func postLockShortcut() throws {
        guard AXIsProcessTrusted() else {
            throw IdleLockError.lockUnavailable("Accessibility permission is required to send Control-Command-Q.")
        }

        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: false)
        else {
            throw IdleLockError.lockCommandFailed("Unable to create Control-Command-Q events.")
        }

        let flags: CGEventFlags = [.maskControl, .maskCommand]
        keyDown.flags = flags
        keyUp.flags = flags
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        logger.log("Lock command sent with Control-Command-Q")
    }
}
