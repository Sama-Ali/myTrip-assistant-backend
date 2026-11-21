import Vapor

private struct BookingDetailsServiceKey: StorageKey {
    typealias Value = any BookingDetailsService
}

extension Application {
    var bookingDetailsService: any BookingDetailsService {
        get {
            guard let service = storage[BookingDetailsServiceKey.self] else {
                fatalError("BookingDetailsService has not been configured")
            }

            return service
        }

        set {
            storage[BookingDetailsServiceKey.self] = newValue
        }
    }
}