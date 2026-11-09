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
                date: "2026-11-10",
                status: .delayed,
                delayMinutes: 25,
                origin: "RUH",
                destination: "JED",
                scheduledDeparture: try timestamp(
                    "2026-11-10T16:30:00+03:00"
                ),
                estimatedDeparture: try timestamp(
                    "2026-11-10T16:55:00+03:00"
                ),
                scheduledArrival: nil,
                estimatedArrival: nil,
                terminal: "5",
                gate: nil,
                updatedAt: try timestamp(
                    "2026-11-10T15:10:00+03:00"
                ),
                source: "mock"
            ),
            FlightStatusResponse(
                flightNumber: "SV1022",
                date: "2026-11-10",
                status: .scheduled,
                delayMinutes: 0,
                origin: "JED",
                destination: "RUH",
                scheduledDeparture: try timestamp(
                    "2026-11-10T18:00:00+03:00"
                ),
                estimatedDeparture: nil,
                scheduledArrival: nil,
                estimatedArrival: nil,
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