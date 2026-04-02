import Foundation
import Carbon.HIToolbox

class HotkeyService {
    private var hotkeyRef: EventHotKeyRef?
    private var onToggle: (() -> Void)?

    static var shared: HotkeyService?

    init() {
        HotkeyService.shared = self
    }

    func register(onToggle: @escaping () -> Void) {
        self.onToggle = onToggle

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x544D_4143) // "TMAC"
        hotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                HotkeyService.shared?.onToggle?()
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        let keyCode = AppConstants.Hotkey.toggleTimerKeyCode
        let modifiers = AppConstants.Hotkey.toggleTimerModifiers

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
    }
}
