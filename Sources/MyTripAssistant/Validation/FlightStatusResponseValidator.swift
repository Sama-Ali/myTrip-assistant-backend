import Foundation

struct FlightStatusResponseValidator {
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
            throw FlightResponseValidationError(
                message: "date must be a valid calendar date in YYYY-MM-DD format"
           )
        }
    }
    static func validate(_ flight: FlightStatusResponse) throws {
        try validateDate(flight.date)
        // Flight number: two uppercase letters/digits, then 3–4 digits.
        guard flight.flightNumber.range(
            of: #"\A[A-Z0-9]{2}[0-9]{3,4}\z"#,
            options: .regularExpression
        ) != nil else {
            throw FlightResponseValidationError(
                message: "flight_number has an invalid format"
            )
        }

        if let number = flight.operatingFlightNumber {
            guard number.range(
                of: #"\A[A-Z0-9]{2}[0-9]{3,4}\z"#,
                options: .regularExpression
            ) != nil else {
                throw FlightResponseValidationError(
                    message: "operating_flight_number has an invalid format"
                )
            }
        }

        // Airline codes: exactly two uppercase letters/digits.
        for (field, code) in [
            ("marketing_airline.code", flight.marketingAirline.code),
            ("operating_airline.code", flight.operatingAirline.code)
        ] {
            guard code.range(
                of: #"\A[A-Z0-9]{2}\z"#,
                options: .regularExpression
            ) != nil else {
                throw FlightResponseValidationError(
                    message: "\(field) has an invalid format"
                )
            }
        }

        // Airport codes: exactly three uppercase letters.
        for (field, code) in [
            ("origin", flight.origin),
            ("destination", flight.destination)
        ] {
            if let code {
                guard code.range(
                    of: #"\A[A-Z]{3}\z"#,
                    options: .regularExpression
                ) != nil else {
                    throw FlightResponseValidationError(
                        message: "\(field) must contain three uppercase letters"
                    )
                }
            }
        }

        switch flight.status {
        case .scheduled, .boarding, .delayed, .cancelled:
            guard flight.actualDeparture == nil,
                  flight.actualArrival == nil else {
                throw FlightResponseValidationError(
                    message: "\(flight.status.rawValue) must not have actual departure or arrival"
                )
            }

        case .departed:
            guard flight.actualDeparture != nil else {
                throw FlightResponseValidationError(
                    message: "A departed flight must have actual_departure",
                    missing: ["actual_departure"]
                )
            }

            guard flight.actualArrival == nil else {
                throw FlightResponseValidationError(
                    message: "A departed flight must not have actual_arrival"
                )
            }

        case .landed:
            var missing: [String] = []

            if flight.actualDeparture == nil {
                missing.append("actual_departure")
            }

            if flight.actualArrival == nil {
                missing.append("actual_arrival")
            }

            guard missing.isEmpty else {
                throw FlightResponseValidationError(
                    message: "A landed flight must have actual departure and arrival",
                    missing: missing
                )
            }

        case .diverted:
            guard flight.actualDeparture != nil else {
                throw FlightResponseValidationError(
                    message: "A diverted flight must have actual_departure",
                    missing: ["actual_departure"]
                )
            }
        }

        // Actual arrival cannot precede actual departure.
        if let departure = flight.actualDeparture,
           let arrival = flight.actualArrival,
           arrival < departure {
            throw FlightResponseValidationError(
                message: "actual_arrival must not precede actual_departure"
            )
        }

        // Cancellation-specific fields.
        if flight.status == .cancelled {
            guard flight.arrivalDelayMinutes == nil else {
                throw FlightResponseValidationError(
                    message: "A cancelled flight must not have arrival_delay_minutes"
                )
            }
        } else {
            guard flight.cancellationNotifiedAt == nil else {
                throw FlightResponseValidationError(
                    message: "cancellation_notified_at is only allowed for cancelled flights"
                )
            }
        }

        // Delay values cannot be negative.
        guard flight.departureDelayMinutes >= 0 else {
            throw FlightResponseValidationError(
                message: "departure_delay_minutes must not be negative"
            )
        }

        if let delay = flight.arrivalDelayMinutes, delay < 0 {
            throw FlightResponseValidationError(
                message: "arrival_delay_minutes must not be negative"
            )
        }

        // Marketing airline must match the flight number prefix.
        guard flight.marketingAirline.code ==
                String(flight.flightNumber.prefix(2)) else {
            throw FlightResponseValidationError(
                message: "marketing_airline.code must match the flight_number prefix"
            )
        }

        // If provided, the operating flight number must match its airline.
        if let operatingNumber = flight.operatingFlightNumber {
            guard flight.operatingAirline.code ==
                    String(operatingNumber.prefix(2)) else {
                throw FlightResponseValidationError(
                    message: "operating_airline.code must match the operating_flight_number prefix"
                )
            }
        }
    }
}

// ===============================  ===============================
// - scheduled مع أوقات فعلية فارغة → يمر.
// - landed دون actualArrival → خطأ، مع اسم الحقل المفقود.
// - وصول فعلي قبل الإقلاع الفعلي → خطأ تناقض، دون حقول مفقودة.
// - cancelled دون وقت إشعار الإلغاء → يمر؛ المصدر قد لا يوفّره.
