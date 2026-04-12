import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        LaunchAtLoginService.shared.syncRegistration(isEnabled: SettingsStore.shared.launchAtLogin)
    }
}
