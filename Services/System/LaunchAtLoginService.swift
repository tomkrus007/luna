import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()

    private init() {}

    func syncRegistration(isEnabled: Bool) {
        guard #available(macOS 13.0, *) else { return }

        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("LaunchAtLogin registration failed: %@", error.localizedDescription)
        }
    }
}
