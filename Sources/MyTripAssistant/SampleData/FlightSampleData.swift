import Foundation

enum FlightSampleData {
    static func make() throws -> [FlightStatusResponse] {
        let formatter = ISO8601DateFormatter()

        func timestamp(_ value: String) throws -> Date {
            guard let date = formatter.date(from: value) else {
                throw SampleDataError.invalidTimestamp(value)
            }

            return date
        }

        return [
            FlightStatusResponse(
                flightNumber: "SV1021",
                marketingAirline: Airline(code: "SV", name: "Saudia"),
                operatingAirline: Airline(code: "SV", name: "Saudia"),
                operatingFlightNumber: nil,
                date: "2026-11-10",
                status: .delayed,
                departureDelayMinutes: 25,
                arrivalDelayMinutes: nil,
                origin: "RUH",
                destination: "JED",
                scheduledDeparture: try timestamp(
                    "2026-11-10T16:30:00+03:00"
                ),
                estimatedDeparture: try timestamp(
                    "2026-11-10T16:55:00+03:00"
                ),
                actualDeparture: nil,
                scheduledArrival: nil,
                estimatedArrival: nil,
                actualArrival: nil,
                cancellationNotifiedAt: nil,
                terminal: "5",
                gate: nil,
                updatedAt: try timestamp(
                    "2026-11-10T15:10:00+03:00"
                ),
                source: "mock"
            ),
            FlightStatusResponse(
                flightNumber: "SV1022",
                marketingAirline: Airline(code: "SV", name: "Saudia"),
                operatingAirline: Airline(code: "SV", name: "Saudia"),
                operatingFlightNumber: nil,
                date: "2026-11-10",
                status: .scheduled,
                departureDelayMinutes: 0,
                arrivalDelayMinutes: nil,
                origin: "JED",
                destination: "RUH",
                scheduledDeparture: try timestamp(
                    "2026-11-10T18:00:00+03:00"
                ),
                estimatedDeparture: nil,
                actualDeparture: nil,
                scheduledArrival: nil,
                estimatedArrival: nil,
                actualArrival: nil,
                cancellationNotifiedAt: nil,
                terminal: "1",
                gate: "A12",
                updatedAt: try timestamp(
                    "2026-11-10T15:10:00+03:00"
                ),
                source: "mock"
            )
        ]
    }

    private enum SampleDataError: Error {
        case invalidTimestamp(String)
    }
}