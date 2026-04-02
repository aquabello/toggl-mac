import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var updateTimer: Timer?
    private var hotkeyService: HotkeyService?

    var timerViewModel: TimerViewModel? {
        didSet {
            startUpdateTimer()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyService?.unregister()
        updateTimer?.invalidate()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItem()

        if let button = statusItem?.button {
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

    private func setupHotkey() {
        let service = HotkeyService()
        hotkeyService = service
        service.register { [weak self] in
            DispatchQueue.main.async {
                self?.timerViewModel?.toggle()
            }
        }
    }

    @objc private func statusItemClicked() {
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        if let vm = timerViewModel, vm.isRunning {
            button.image = nil
            button.title = vm.formattedElapsedTime
        } else {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "TogglMac")
            button.title = ""
        }
    }

    private func startUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusItem()
        }
    }
}
