import AppKit
import SwiftUI

public final class PreferencesWindowController {
    private let settings: AppSettings
    private let monitor: IdleMonitor
    private let launchAgent: LaunchAgentService
    private let lockService: LockService
    private let logger: IdleLockLogger
    private var window: NSWindow?

    public init(
        settings: AppSettings,
        monitor: IdleMonitor,
        launchAgent: LaunchAgentService,
        lockService: LockService,
        logger: IdleLockLogger
    ) {
        self.settings = settings
        self.monitor = monitor
        self.launchAgent = launchAgent
        self.lockService = lockService
        self.logger = logger
    }

    public func show() {
        if window == nil {
            let view = PreferencesView(
                settings: settings,
                monitor: monitor,
                launchAgent: launchAgent,
                lockService: lockService,
                logger: logger
            )
            let hosting = NSHostingController(rootView: view)
            let created = NSWindow(contentViewController: hosting)
            created.title = "Idle Lock Preferences"
            created.styleMask = [.titled, .closable, .miniaturizable]
            created.setContentSize(NSSize(width: 520, height: 460))
            created.center()
            window = created
        }

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    let monitor: IdleMonitor
    let launchAgent: LaunchAgentService
    let lockService: LockService
    let logger: IdleLockLogger

    @State private var customDelayText: String = ""
    @State private var statusMessage: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Idle Lock")
                .font(.system(size: 24, weight: .semibold))

            GroupBox("Timing") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Lock after", selection: delayBinding) {
                        ForEach(IdleLockDefaults.delayPresetSeconds, id: \.self) { seconds in
                            Text(DurationFormatter.menuDelayLabel(seconds)).tag(seconds)
                        }
                        Text("Custom").tag(settings.customDelaySeconds)
                    }
                    .pickerStyle(.menu)

                    HStack {
                        TextField("Custom seconds", text: $customDelayText)
                            .textFieldStyle(.roundedBorder)
                        Button("Apply") {
                            applyCustomDelay()
                        }
                    }

                    Picker("Countdown warning", selection: countdownBinding) {
                        ForEach(IdleLockDefaults.countdownPresetSeconds, id: \.self) { seconds in
                            Text(DurationFormatter.menuDelayLabel(seconds)).tag(seconds)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(8)
            }

            GroupBox("Controls") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button("Test Countdown") {
                            monitor.testCountdown()
                        }
                        Button("Lock Now") {
                            monitor.lockNow()
                        }
                        Button("Grant Accessibility Permission") {
                            lockService.openAccessibilityPermissionHelp()
                            monitor.refreshSoon()
                        }
                    }

                    HStack {
                        Button("Pause 30 min") {
                            monitor.pause(for: 1_800)
                        }
                        Button("Pause 1 hour") {
                            monitor.pause(for: 3_600)
                        }
                        Button("Until resumed") {
                            monitor.pauseUntilResumed()
                        }
                        Button("Resume") {
                            monitor.resume()
                        }
                    }

                    Toggle("Sound at countdown start", isOn: soundBinding)
                    Toggle("Start at Login", isOn: startAtLoginBinding)
                }
                .padding(8)
            }

            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(22)
        .onAppear {
            customDelayText = DurationFormatter.compact(settings.customDelaySeconds)
            refreshStatus()
        }
    }

    private var delayBinding: Binding<TimeInterval> {
        Binding(
            get: {
                if IdleLockDefaults.delayPresetSeconds.contains(settings.lockDelaySeconds) {
                    return settings.lockDelaySeconds
                }
                return settings.customDelaySeconds
            },
            set: { value in
                settings.setLockDelaySeconds(value)
                monitor.refreshSoon()
                refreshStatus()
            }
        )
    }

    private var countdownBinding: Binding<TimeInterval> {
        Binding(
            get: { settings.countdownSeconds },
            set: { value in
                settings.setCountdownSeconds(value)
                monitor.refreshSoon()
                refreshStatus()
            }
        )
    }

    private var soundBinding: Binding<Bool> {
        Binding(
            get: { settings.soundEnabled },
            set: { settings.setSoundEnabled($0) }
        )
    }

    private var startAtLoginBinding: Binding<Bool> {
        Binding(
            get: { settings.startAtLogin },
            set: { enabled in
                do {
                    if enabled {
                        try launchAgent.installLaunchAgent(loadNow: false)
                    } else {
                        try launchAgent.disableLaunchAgent()
                    }
                    settings.setStartAtLogin(enabled)
                    statusMessage = enabled ? "Start at Login enabled." : "Start at Login disabled."
                } catch {
                    settings.setStartAtLogin(false)
                    statusMessage = error.localizedDescription
                    logger.log("Start at Login change failed: \(error.localizedDescription)")
                }
            }
        )
    }

    private func applyCustomDelay() {
        guard let seconds = DurationParser.parseSeconds(customDelayText) else {
            statusMessage = "Could not parse custom delay."
            return
        }
        settings.setCustomDelaySeconds(seconds)
        customDelayText = DurationFormatter.compact(settings.customDelaySeconds)
        monitor.refreshSoon()
        refreshStatus()
    }

    private func refreshStatus() {
        let availability = lockService.availability(promptForAccessibility: false)
        if let strategy = availability.strategy {
            statusMessage = "Lock method: \(strategy.description)."
        } else {
            statusMessage = availability.reason ?? "No lock method available."
        }
    }
}
