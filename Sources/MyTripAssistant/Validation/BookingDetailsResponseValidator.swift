import Foundation

struct BookingDetailsResponseValidator {
       private static func validateDate(_ value: String) throws {
       let formatter = DateFormatter()
       formatter.locale = Locale(identifier: "en_US_POSIX")
       formatter.calendar = Calendar(identifier: .gregorian)
       formatter.timeZone = TimeZone(secondsFromGMT: 0)
       formatter.dateFormat = "yyyy-MM-dd"
       formatter.isLenient = false

       guard value.range(
           of: #"\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z"#,
           options: .regularExpression
       ) != nil,
       let date = formatter.date(from: value),
       formatter.string(from: date) == value else {
           throw BookingResponseValidationError(
               message: "date must be a valid calendar date in YYYY-MM-DD format"
           )
       }
    }
    static func validate(_ booking: BookingDetailsResponse) throws {
        guard booking.flightNumber.range(
            of: #"\A[A-Z0-9]{2}[0-9]{3,4}\z"#,
            options: .regularExpression
        ) != nil else {
            throw BookingResponseValidationError(
                message: "flight_number has an invalid format"
            )
        }

        try validateDate(booking.date)

        // At least one allowance must be available.
        guard booking.baggageAllowanceKg != nil ||
              booking.baggageAllowancePieces != nil else {
            throw BookingResponseValidationError(
                message: "At least one of baggage_allowance_kg or baggage_allowance_pieces must be provided"
            )
        }

        // A per-piece weight requires a piece allowance.
        if booking.baggagePieceMaxKg != nil,
           booking.baggageAllowancePieces == nil {
            throw BookingResponseValidationError(
                message: "baggage_piece_max_kg requires baggage_allowance_pieces",
                missing: ["baggage_allowance_pieces"]
            )
        }

        // All provided baggage values must be non-negative.
        for (field, value) in [
            ("baggage_allowance_kg", booking.baggageAllowanceKg),
            ("baggage_allowance_pieces", booking.baggageAllowancePieces),
            ("baggage_piece_max_kg", booking.baggagePieceMaxKg)
        ] {
            if let value, value < 0 {
                throw BookingResponseValidationError(
                    message: "\(field) must not be negative"
                )
            }
        }
    }
}