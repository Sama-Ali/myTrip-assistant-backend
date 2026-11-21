import Foundation

struct BookingRequestValidationError: Error {
    let body: ToolErrorBody
}

enum BookingDetailsRequestValidator {
    static func validate(
        _ request: BookingDetailsRequest
    ) throws -> BookingDetailsRequest {
        var bookingReference: String?
        var flightNumber: String?

        if let rawReference = request.bookingReference {
            let normalized = rawReference
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased()

            guard normalized.range(
                of: #"^[A-Z0-9]{5,8}$"#,
                options: .regularExpression
            ) != nil else {
                throw BookingRequestValidationError(
                    body: ToolErrorBody(
                        code: .invalidBookingReference,
                        message: "booking_reference must contain 5–8 letters or digits",
                        retryable: false,
                        missing: nil
                    )
                )
            }

            bookingReference = normalized
        }

        if let rawFlightNumber = request.flightNumber {
            let normalized = rawFlightNumber
                .filter { !$0.isWhitespace }
                .uppercased()

            guard normalized.range(
                of: #"^[A-Z0-9]{2}[0-9]{3,4}$"#,
                options: .regularExpression
            ) != nil else {
                throw BookingRequestValidationError(
                    body: ToolErrorBody(
                        code: .invalidFlightNumber,
                        message: "Invalid flight number format",
                        retryable: false,
                        missing: nil
                    )
                )
            }

            flightNumber = normalized
        }

        return BookingDetailsRequest(
            bookingReference: bookingReference,
            flightNumber: flightNumber
        )
    }
}