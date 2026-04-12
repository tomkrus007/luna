import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()

    private init() {}

    var isEnabled: Bool {
        guard #available(macOS 13.0, *) else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    func syncRegistration(isEnabled: Bool) {
        guard #available(macOS 13.0, *) else { return }

        let service = SMAppService.mainApp
        let status = service.status

        if isEnabled, status == .enabled {
            return
        }

        if !isEnabled, status == .notRegistered {
            return
        }

        do {
            if isEnabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            NSLog("LaunchAtLogin registration failed: %@", error.localizedDescription)
        }
    }
}
