import Network
import Foundation
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    /// Срабатывает когда соединение восстанавливается (false → true)
    let connectionRestored = PassthroughSubject<Void, Never>()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let nowConnected = path.status == .satisfied
                let wasOffline = !self.isConnected
                self.isConnected = nowConnected
                if wasOffline && nowConnected {
                    self.connectionRestored.send()
                }
            }
        }
        monitor.start(queue: queue)
    }
}
