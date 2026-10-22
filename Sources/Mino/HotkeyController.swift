// SPDX-License-Identifier: MIT
import Carbon

/// RegisterEventHotKey requires no Accessibility or Input Monitoring permission.
@MainActor
final class HotkeyController {
    private var hotkey: EventHotKeyRef?
    private var handler: EventHandlerRef?
    var onPressed: (() -> Void)?

    func register() -> OSStatus {
        unregister()
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let context = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            guard let userData else { return OSStatus(eventNotHandledErr) }
            let controller = Unmanaged<HotkeyController>.fromOpaque(userData).takeUnretainedValue()
            MainActor.assumeIsolated { controller.onPressed?() }
            return noErr
        }, 1, &eventType, context, &handler)
        guard status == noErr else { return status }
        let identifier = EventHotKeyID(signature: 0x4D494E4F, id: 1)
        let result = RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey | optionKey),
                                         identifier, GetApplicationEventTarget(), 0, &hotkey)
        if result != noErr { unregister() }
        return result
    }

    func unregister() {
        if let hotkey { UnregisterEventHotKey(hotkey) }
        if let handler { RemoveEventHandler(handler) }
        hotkey = nil
        handler = nil
    }
}
