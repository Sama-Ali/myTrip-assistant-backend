import Foundation

struct MockFlightStatusService: FlightStatusService {
    // ================================ flights list ================================
    private let flights: [FlightStatusResponse]

    // ================================ get the flights once flights are loaded ================================ 
    init(flights: [FlightStatusResponse]) {
        self.flights = flights
    }

    func getFlightStatus(
        request: FlightStatusRequest
    ) async throws -> FlightStatusResult {
        let flightNumber = request.flightNumber

        guard let date = request.date else {
            return .failure(
                ToolErrorResponse(
                    error: ToolErrorBody(
                        code: .missingInput,
                        message: "A resolved flight date is required",
                        retryable: false,
                        missing: ["date"]
                    )
                )
            )
        }

        guard let flight = flights.first(where: {
            $0.flightNumber == flightNumber &&
            $0.date == date
        }) else {
            return .failure(
                ToolErrorResponse(
                    error: ToolErrorBody(
                        code: .flightNotFound,
                        message: "No flight found for this number and date",
                        retryable: false,
                        missing: nil
                    )
                )
            )
        }

        return .success(flight)
    }
}