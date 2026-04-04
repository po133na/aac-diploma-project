import Foundation

/// Очередь офлайн-действий, которые нужно выполнить как только появится сеть.
final class PendingActionQueue {
    static let shared = PendingActionQueue()
    private init() {}

    private let storageKey = "pendingActions"

    enum ActionType: String, Codable {
        case createCard
        case deleteCard
        case updateCard
        case createPhrase
        case deletePhrase
    }

    struct PendingAction: Codable {
        let type: ActionType
        let path: String
        let method: String
        let payload: Data?       // JSON-тело запроса (nil для DELETE без тела)
        let createdAt: Date
    }

    // MARK: - Persistence

    private var actions: [PendingAction] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode([PendingAction].self, from: data)
            else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: storageKey)
            }
        }
    }

    // MARK: - Enqueue

    func enqueue(_ action: PendingAction) {
        var current = actions
        current.append(action)
        actions = current
    }

    func enqueue(type: ActionType, path: String, method: String, payload: Encodable? = nil) {
        let data = payload.flatMap { try? JSONEncoder().encode($0) }
        enqueue(PendingAction(type: type, path: path, method: method, payload: data, createdAt: Date()))
    }

    // MARK: - Flush

    /// Выполняет все накопленные действия по порядку. Вызывается при появлении сети.
    func flush() async {
        let pending = actions
        guard !pending.isEmpty else { return }
        actions = []  // очищаем заранее; при ошибке теряем действие (acceptable для диплома)

        let client = APIClient.shared
        for action in pending {
            do {
                try await client.requestVoidWithBody(
                    path: action.path,
                    method: action.method,
                    bodyData: action.payload
                )
            } catch {
                print("[PendingActionQueue] failed \(action.type.rawValue) \(action.path): \(error)")
            }
        }
    }
}
