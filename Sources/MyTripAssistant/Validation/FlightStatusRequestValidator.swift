import Foundation

struct FlightRequestValidationError: Error {
    let body: ToolErrorBody
}

enum FlightStatusRequestValidator {
    static func validate(
        _ request: FlightStatusRequest,
        now: Date = Date()
    ) throws -> FlightStatusRequest {
        let flightNumber = request.flightNumber
            .filter { !$0.isWhitespace }
            .uppercased()

        guard !flightNumber.isEmpty else {
            throw FlightRequestValidationError(
                body: ToolErrorBody(
                    code: .missingInput,
                    message: "flight_number is required",
                    retryable: false,
                    missing: ["flight_number"]
                )
            )
        }

        let validFlightNumber =
            flightNumber.range(
                of: #"^[A-Z0-9]{2}[0-9]{3,4}$"#,
                options: .regularExpression
            ) != nil

        guard validFlightNumber else {
            throw FlightRequestValidationError(
                body: ToolErrorBody(
                    code: .invalidFlightNumber,
                    message: "Invalid flight number format",
                    retryable: false,
                    missing: nil
                )
            )
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Riyadh")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        let resolvedDate: String

        if let suppliedDate = request.date {
            guard
                suppliedDate.range(
                    of: #"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"#,
                    options: .regularExpression
                ) != nil,
                let parsedDate = formatter.date(from: suppliedDate),
                formatter.string(from: parsedDate) == suppliedDate
            else {
                throw FlightRequestValidationError(
                    body: ToolErrorBody(
                        code: .invalidDate,
                        message: "date must be a valid date in YYYY-MM-DD format",
                        retryable: false,
                        missing: nil
                    )
                )
            }

            resolvedDate = suppliedDate
        } else {
            resolvedDate = formatter.string(from: now)
        }

        return FlightStatusRequest(
            flightNumber: flightNumber,
            date: resolvedDate
        )
    }
}