import Vapor

enum CabinClass: String, Codable, Sendable {
    case economy
    case premiumEconomy = "premium_economy"
    case business
    case first
}

struct BookingDetailsResponse: Content {
    let ok: Bool = true

    let bookingReference: String
    let flightNumber: String
    let date: String
    let cabinClass: CabinClass
    let seat: String?
    let baggageAllowanceKg: Int

    enum CodingKeys: String, CodingKey {
        case ok
        case bookingReference = "booking_reference"
        case flightNumber = "flight_number"
        case date
        case cabinClass = "cabin_class"
        case seat
        case baggageAllowanceKg = "baggage_allowance_kg"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(ok, forKey: .ok)
        try container.encode(bookingReference, forKey: .bookingReference)
        try container.encode(flightNumber, forKey: .flightNumber)
        try container.encode(date, forKey: .date)
        try container.encode(cabinClass, forKey: .cabinClass)
        try container.encode(seat, forKey: .seat)
        try container.encode(
            baggageAllowanceKg,
            forKey: .baggageAllowanceKg
        )
    }
}