import Vapor

// ================================ save the service in the application storage ================================
private struct FlightStatusServiceKey: StorageKey {
    typealias Value = any FlightStatusService
}

// ================================ Makes the registered service accessible through app.flightStatusService. ================================
extension Application {
    var flightStatusService: any FlightStatusService {
        get {
            guard let service = storage[FlightStatusServiceKey.self] else {
                fatalError("FlightStatusService has not been configured")
            }

            return service
        }

        set {
            storage[FlightStatusServiceKey.self] = newValue
        }
    }
}