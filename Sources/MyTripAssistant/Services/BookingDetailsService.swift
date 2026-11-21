import Foundation

enum BookingDetailsResult: Sendable {
    case success(BookingDetailsResponse)
    case failure(ToolErrorResponse)
}

protocol BookingDetailsService: Sendable {
    func getBookingDetails(
        userID: UUID,
        request: BookingDetailsRequest
    ) async throws -> BookingDetailsResult
}