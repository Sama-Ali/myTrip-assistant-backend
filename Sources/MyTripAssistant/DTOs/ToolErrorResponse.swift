import Vapor

enum ToolErrorCode: String, Codable, Sendable {
    // Shared
    case sourceUnavailable = "SOURCE_UNAVAILABLE"
    case badSourceData = "BAD_SOURCE_DATA"
    case invalidRequest = "INVALID_REQUEST"
    case unsupportedMediaType = "UNSUPPORTED_MEDIA_TYPE"

    // Flight
    case missingInput = "MISSING_INPUT"
    case invalidFlightNumber = "INVALID_FLIGHT_NUMBER"
    case invalidDate = "INVALID_DATE"
    case flightNotFound = "FLIGHT_NOT_FOUND"

    // Booking
    case unauthenticated = "UNAUTHENTICATED"
    case bookingNotFound = "BOOKING_NOT_FOUND"
    case ambiguousBooking = "AMBIGUOUS_BOOKING"
    case forbidden = "FORBIDDEN"
    case invalidBookingReference = "INVALID_BOOKING_REFERENCE"
}

struct ToolErrorBody: Content {
    let code: ToolErrorCode
    let message: String
    let retryable: Bool
    let missing: [String]?
}

struct ToolErrorResponse: Content {
    let ok: Bool = false
    let error: ToolErrorBody
}

extension ToolErrorCode {
    var httpStatus: HTTPResponseStatus {
        switch self {
        case .missingInput,
             .invalidRequest,
             .invalidFlightNumber,
             .invalidDate,
             .invalidBookingReference:
            return .badRequest

        case .flightNotFound, .bookingNotFound:
            return .notFound

        case .unauthenticated:
            return .unauthorized

        case .forbidden:
            return .forbidden

        case .ambiguousBooking:
            return .conflict

        case .sourceUnavailable:
            return .serviceUnavailable

        case .badSourceData:
            return .badGateway

        case .unsupportedMediaType:
            return .unsupportedMediaType    
        }
    }
}