import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var cancellable: AnyCancellable?
    private var hotkeyService: HotkeyService?

    // Set externally by TogglMacApp after viewModel is created
    var timerViewModel: TimerViewModel? {
        didSet {
            observeViewModel()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyService?.unregister()
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

    private func observeViewModel() {
        cancellable?.cancel()
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
    }
}
