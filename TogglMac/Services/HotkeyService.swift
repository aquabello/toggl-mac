import SwiftUI

class HotkeyService {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var onToggle: (() -> Void)?

    func register(onToggle: @escaping () -> Void) {
        self.onToggle = onToggle

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil
            }
            return event
        }
    }

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let requiredFlags: NSEvent.ModifierFlags = [.control, .command]
        let keyCode: UInt16 = 17 // T key

        if event.keyCode == keyCode &&
           event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(requiredFlags) {
            DispatchQueue.main.async { [weak self] in
                self?.onToggle?()
            }
            return true
        }
        return false
    }

    func unregister() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
