import Vapor

enum FlightToolErrorCode: String, Codable, Sendable {
    case missingInput = "MISSING_INPUT"
    case invalidFlightNumber = "INVALID_FLIGHT_NUMBER"
    case invalidDate = "INVALID_DATE"
    case flightNotFound = "FLIGHT_NOT_FOUND"
    case sourceUnavailable = "SOURCE_UNAVAILABLE"
}

struct ToolErrorBody: Content {
    let code: FlightToolErrorCode
    let message: String
    let retryable: Bool
    let missing: [String]?
}

struct ToolErrorResponse: Content {
    let ok: Bool = false
    let error: ToolErrorBody
}