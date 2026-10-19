import Vapor

private struct AssistantServiceKey: StorageKey {
    typealias Value = any AssistantService
}

extension Application {
    var assistantService: any AssistantService {
        get {
            guard let service = storage[AssistantServiceKey.self] else {
                fatalError("AssistantService is not configured")
            }
            return service
        }
        set {
            storage[AssistantServiceKey.self] = newValue
        }
    }
}