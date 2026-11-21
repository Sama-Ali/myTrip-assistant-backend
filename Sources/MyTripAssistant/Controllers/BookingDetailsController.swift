import Vapor
import Foundation

struct BookingDetailsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("tools", "booking-details", use: getBookingDetails)
    }

    func getBookingDetails(req: Request) async throws -> Response {
        // 1. Get the trusted user identity.
        let userID = try req.auth.require(AuthenticatedUser.self).id

        // 2. Decode the request.
        let payload: BookingDetailsRequest

        do {
            payload = try req.content.decode(BookingDetailsRequest.self)
        } catch DecodingError.typeMismatch(_, let context)
            where context.codingPath.last?.stringValue
                == "booking_reference" {
            return try inputError(
                code: .invalidBookingReference,
                message: "booking_reference must be a string"
            )
        } catch DecodingError.typeMismatch(_, let context)
            where context.codingPath.last?.stringValue
                == "flight_number" {
            return try inputError(
                code: .invalidFlightNumber,
                message: "flight_number must be a string"
            )
        }

        // 3. Normalize and validate the optional filters.
        let validatedRequest: BookingDetailsRequest

        do {
            validatedRequest = try BookingDetailsRequestValidator.validate(
                payload
            )
        } catch let error as BookingRequestValidationError {
            return try makeErrorResponse(
                ToolErrorResponse(error: error.body)
            )
        }

        // 4. Search only the authenticated user's bookings.
        let result = try await req.application.bookingDetailsService
            .getBookingDetails(
                userID: userID,
                request: validatedRequest
            )

        // 5. Return the result.
        switch result {
        case .success(let booking):
            let response = Response(status: .ok)
            try response.content.encode(booking)
            return response

        case .failure(let error):
            return try makeErrorResponse(error)
        }
    }

    private func inputError(
        code: ToolErrorCode,
        message: String
    ) throws -> Response {
        try makeErrorResponse(
            ToolErrorResponse(
                error: ToolErrorBody(
                    code: code,
                    message: message,
                    retryable: false,
                    missing: nil
                )
            )
        )
    }

    private func makeErrorResponse(
        _ error: ToolErrorResponse
    ) throws -> Response {
        let response = Response(
            status: error.error.code.httpStatus
        )
        try response.content.encode(error)
        return response
    }
}