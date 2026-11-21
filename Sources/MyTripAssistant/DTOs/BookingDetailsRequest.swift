import Vapor

struct BookingDetailsRequest: Content {
    let bookingReference: String?
    let flightNumber: String?

    enum CodingKeys: String, CodingKey {
        case bookingReference = "booking_reference"
        case flightNumber = "flight_number"
    }
}