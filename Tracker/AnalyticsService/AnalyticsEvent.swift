import AppMetricaCore

enum AnalyticsEvent {
    enum Event: String {
        case open, close, click
    }

    enum Screen: String {
        case main = "Main"
    }

    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }

    static func log(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String: String] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item = item, event == .click {
            params["item"] = item.rawValue
        }
        print("---> Отправка события в AppMetrica: \(params)")
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("---> AppMetrica error: \(error.localizedDescription)")
        }
    }
}
