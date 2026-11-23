import Vapor
import Foundation

struct FlightStatusController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("tools", "flight-status", use: getFlightStatus)
    }

    func getFlightStatus(req: Request) async throws -> Response {
        let payload: FlightStatusRequest

        // 1. Decode the JSON request.
        do {
            payload = try req.content.decode(FlightStatusRequest.self)
        } catch DecodingError.keyNotFound(let key, _)
            where key.stringValue == "flight_number" {
            return try inputError(
                code: .missingInput,
                message: "flight_number is required",
                missing: ["flight_number"]
            )
        } catch DecodingError.valueNotFound(_, let context)
            where context.codingPath.last?.stringValue == "flight_number" {
            return try inputError(
                code: .missingInput,
                message: "flight_number cannot be null",
                missing: ["flight_number"]
            )
        } catch DecodingError.typeMismatch(_, let context)
            where context.codingPath.last?.stringValue == "flight_number" {
            return try inputError(
                code: .invalidFlightNumber,
                message: "flight_number must be a string"
            )
        } catch DecodingError.typeMismatch(_, let context)
            where context.codingPath.last?.stringValue == "date" {
            return try inputError(
                code: .invalidDate,
                message: "date must be a string in YYYY-MM-DD format"
            )
        }

        // 2. Normalize and validate the input.
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

        // 3. Ask the registered service for flight data.
        let result = try await req.application.flightStatusService
            .getFlightStatus(request: validatedRequest)

        // 4. Return the result as JSON.
        switch result {
        case .success(let flight):
        do {
            try FlightStatusResponseValidator.validate(flight)
        } catch let error as FlightResponseValidationError {
            return try makeErrorResponse(
                ToolErrorResponse(error: error.body),
                status: error.body.code.httpStatus
            )
        }

        let response = Response(status: .ok)
        try response.content.encode(flight)
        return response

        case .failure(let error):
            return try makeErrorResponse(
                  error,
                  status: error.error.code.httpStatus
              )
         }
    }

    // Builds a structured 400 response for invalid input.
    private func inputError(
        code: ToolErrorCode,
        message: String,
        missing: [String]? = nil
    ) throws -> Response {
        try makeErrorResponse(
            ToolErrorResponse(
                error: ToolErrorBody(
                    code: code,
                    message: message,
                    retryable: false,
                    missing: missing
                )
            ),
            status: .badRequest
        )
    }

    // Encodes an error body with the supplied HTTP status.
    private func makeErrorResponse(
        _ error: ToolErrorResponse,
        status: HTTPResponseStatus
    ) throws -> Response {
        let response = Response(status: status)
        try response.content.encode(error)
        return response
    }
}