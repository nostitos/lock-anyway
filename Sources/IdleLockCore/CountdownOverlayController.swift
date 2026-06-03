import AppKit
import SwiftUI

public final class CountdownOverlayController {
    fileprivate final class OverlayModel: ObservableObject {
        @Published var title: String
        @Published var detail: String
        @Published var remainingSeconds: Int
        @Published var showsRemaining: Bool

        init(title: String, detail: String, remainingSeconds: Int, showsRemaining: Bool) {
            self.title = title
            self.detail = detail
            self.remainingSeconds = remainingSeconds
            self.showsRemaining = showsRemaining
        }
    }

    private var panels: [NSPanel] = []
    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?
    private let model = OverlayModel(
        title: "Locking soon",
        detail: "Move mouse or press any key to stay unlocked.",
        remainingSeconds: 30,
        showsRemaining: true
    )

    public var onSnooze: ((TimeInterval) -> Void)?
    public var onLockNow: (() -> Void)?

    public init() {}

    public func showCountdown(remainingSeconds: Int) {
        model.title = "Locking in \(remainingSeconds) seconds"
        model.detail = "Move mouse or press any key to stay unlocked, or choose extra time."
        model.remainingSeconds = remainingSeconds
        model.showsRemaining = true
        ensurePanels()
        startKeyMonitors()
        panels.forEach { $0.orderFrontRegardless() }
    }

    public func updateCountdown(remainingSeconds: Int) {
        model.title = "Locking in \(remainingSeconds) seconds"
        model.remainingSeconds = remainingSeconds
    }

    public func showPostponed(message: String = "Lock postponed") {
        model.title = message
        model.detail = "Choose extra time or let this close automatically."
        model.remainingSeconds = 0
        model.showsRemaining = false
        ensurePanels()
        startKeyMonitors()
        panels.forEach { $0.orderFrontRegardless() }
    }

    public func showTestComplete() {
        model.title = "Countdown test complete"
        model.detail = "The test did not lock this Mac."
        model.remainingSeconds = 0
        model.showsRemaining = false
        ensurePanels()
        startKeyMonitors()
        panels.forEach { $0.orderFrontRegardless() }
    }

    public func hide() {
        stopKeyMonitors()
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }

    private func startKeyMonitors() {
        if localKeyMonitor == nil {
            localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard self?.handleKeyDown(event) == true else {
                    return event
                }
                return nil
            }
        }

        if globalKeyMonitor == nil {
            globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                DispatchQueue.main.async {
                    _ = self?.handleKeyDown(event)
                }
            }
        }
    }

    private func stopKeyMonitors() {
        if let localKeyMonitor {
            NSEvent.removeMonitor(localKeyMonitor)
            self.localKeyMonitor = nil
        }

        if let globalKeyMonitor {
            NSEvent.removeMonitor(globalKeyMonitor)
            self.globalKeyMonitor = nil
        }
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        let blockedModifiers: NSEvent.ModifierFlags = [.command, .control, .option]
        guard event.modifierFlags.intersection(blockedModifiers).isEmpty,
              let characters = event.charactersIgnoringModifiers,
              let index = Int(characters),
              SnoozeOption.all.indices.contains(index - 1)
        else {
            return false
        }

        onSnooze?(SnoozeOption.all[index - 1].seconds)
        return true
    }

    private func ensurePanels() {
        guard panels.isEmpty else {
            return
        }

        panels = NSScreen.screens.map { screen in
            let panel = NSPanel(
                contentRect: NSRect(origin: .zero, size: screen.frame.size),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            panel.setFrame(screen.frame, display: true)
            panel.isFloatingPanel = true
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false
            panel.ignoresMouseEvents = false

            let view = CountdownOverlayView(
                model: model,
                onSnooze: { [weak self] seconds in self?.onSnooze?(seconds) },
                onLockNow: { [weak self] in self?.onLockNow?() }
            )

            let container = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
            container.autoresizingMask = [.width, .height]
            let hostingView = NSHostingView(rootView: view)
            hostingView.frame = container.bounds
            hostingView.autoresizingMask = [.width, .height]
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: container.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            panel.contentView = container
            return panel
        }
    }
}

private struct CountdownOverlayView: View {
    @ObservedObject var model: CountdownOverlayController.OverlayModel
    let onSnooze: (TimeInterval) -> Void
    let onLockNow: () -> Void
    private let buttonColumns = [
        GridItem(.fixed(150), spacing: 10),
        GridItem(.fixed(150), spacing: 10),
        GridItem(.fixed(150), spacing: 10),
        GridItem(.fixed(150), spacing: 10)
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.46)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Text(model.title)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.black)
                    if model.showsRemaining {
                        Text("\(model.remainingSeconds)")
                            .font(.system(size: 76, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color(red: 0.78, green: 0.10, blue: 0.08))
                    }
                    Text(model.detail)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.74))
                }

                LazyVGrid(columns: buttonColumns, spacing: 10) {
                    ForEach(SnoozeOption.all) { option in
                        Button {
                            onSnooze(option.seconds)
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(option.key)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.05, green: 0.26, blue: 0.64))
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                                Text(option.title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 10)
                            .frame(width: 150, height: 64)
                            .background(Color(red: 0.05, green: 0.26, blue: 0.64))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button("Lock Now") {
                    onLockNow()
                }
                .buttonStyle(.bordered)
            }
            .padding(28)
            .frame(width: 720)
            .background(Color(red: 0.96, green: 0.96, blue: 0.93))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.black.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 26, x: 0, y: 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct SnoozeOption: Identifiable {
    static let all = [
        SnoozeOption(key: 1, seconds: 900, title: "15 minutes"),
        SnoozeOption(key: 2, seconds: 1_800, title: "30 minutes"),
        SnoozeOption(key: 3, seconds: 3_600, title: "1 hour"),
        SnoozeOption(key: 4, seconds: 7_200, title: "2 hours")
    ]

    let key: Int
    let seconds: TimeInterval
    let title: String

    var id: TimeInterval {
        seconds
    }
}
