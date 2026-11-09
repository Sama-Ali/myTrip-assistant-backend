// ================================ Defines the service protocol and its possible results: .success or .failure. ================================

enum FlightStatusResult: Sendable {
    case success(FlightStatusResponse)
    case failure(ToolErrorResponse)
}

protocol FlightStatusService: Sendable {
    func getFlightStatus(
        request: FlightStatusRequest
    ) async throws -> FlightStatusResult
}