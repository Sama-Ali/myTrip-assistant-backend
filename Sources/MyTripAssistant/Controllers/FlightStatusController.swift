import Vapor
struct FlightStatusController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("tools", "flight-status", use: getFlightStatus)
    }
    func getFlightStatus(req: Request) async throws -> Response {
let payload: FlightStatusRequest
do {
    payload = try req.content.decode(FlightStatusRequest.self)
} catch DecodingError.keyNotFound(let key, _)
    where key.stringValue == "flight_number" {
    return try makeErrorResponse(
        ToolErrorResponse(
            error: ToolErrorBody(
                code: .missingInput,
                message: "flight_number is required",
                retryable: false,
                missing: ["flight_number"]
            )
        ),
        status: .badRequest
    )
}catch DecodingError.valueNotFound(_, let context)
    where context.codingPath.last?.stringValue == "flight_number" {
    return try makeErrorResponse(
        ToolErrorResponse(
            error: ToolErrorBody(
                code: .missingInput,
                message: "flight_number cannot be null",
                retryable: false,
                missing: ["flight_number"]
            )
        ),
        status: .badRequest
    )
}catch DecodingError.typeMismatch(_, let context)
    where context.codingPath.last?.stringValue == "flight_number" {
    return try makeErrorResponse(
        ToolErrorResponse(
            error: ToolErrorBody(
                code: .invalidFlightNumber,
                message: "flight_number must be a string",
                retryable: false,
                missing: nil
            )
        ),
        status: .badRequest
    )
}catch DecodingError.typeMismatch(_, let context)
    where context.codingPath.last?.stringValue == "date" {
    return try makeErrorResponse(
        ToolErrorResponse(
            error: ToolErrorBody(
                code: .invalidDate,
                message: "date must be a string in YYYY-MM-DD format",
                retryable: false,
                missing: nil
            )
        ),
        status: .badRequest
    )
}
        let validatedRequest: FlightStatusRequest
        do {
            validatedRequest = try FlightStatusRequestValidator.validate(
                payload
            )
        } catch let error as FlightRequestValidationError {
            return try makeErrorResponse(
                ToolErrorResponse(error: error.body),
                status: .badRequest
            )
        }
        let result = try await req.application.flightStatusService
            .getFlightStatus(request: validatedRequest)
        switch result {
        case .success(let flight):
            let response = Response(status: .ok)
            try response.content.encode(flight)
            return response
        case .failure(let error):
            let status: HTTPResponseStatus
            switch error.error.code {
            case .missingInput, .invalidFlightNumber, .invalidDate:
                status = .badRequest
            case .flightNotFound:
                status = .notFound
            case .sourceUnavailable:
                status = .serviceUnavailable
            }
            return try makeErrorResponse(error, status: status)
        }
    }
    private func makeErrorResponse(
        _ error: ToolErrorResponse,
status: HTTPResponseStatus
    ) throws -> Response {
        let response = Response(status: status)
        try response.content.encode(error)
        return response
    }
}