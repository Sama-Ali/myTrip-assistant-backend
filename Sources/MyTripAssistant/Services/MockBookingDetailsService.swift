import Foundation

// Internal sample record: associates a booking with its owner.
// This is not an API response or a database model.
struct SampleBooking: Sendable {
    let userID: UUID
    let details: BookingDetailsResponse
}

struct MockBookingDetailsService: BookingDetailsService {
    private let bookings: [SampleBooking]

    init(bookings: [SampleBooking]) {
        self.bookings = bookings
    }

    func getBookingDetails(
        userID: UUID,
        request: BookingDetailsRequest
    ) async throws -> BookingDetailsResult {
        // Start with only this user's bookings.
        var matches = bookings.filter {
            $0.userID == userID
        }

        if let reference = request.bookingReference {
            matches = matches.filter {
                $0.details.bookingReference == reference
            }
        }

        if let flightNumber = request.flightNumber {
            matches = matches.filter {
                $0.details.flightNumber == flightNumber
            }
        }

        guard !matches.isEmpty else {
            return .failure(
                ToolErrorResponse(
                    error: ToolErrorBody(
                        code: .bookingNotFound,
                        message: "No matching booking found for this user",
                        retryable: false,
                        missing: nil
                    )
                )
            )
        }

        guard matches.count == 1 else {
            return .failure(
                ToolErrorResponse(
                    error: ToolErrorBody(
                        code: .ambiguousBooking,
                        message: "Multiple bookings match; specify a booking reference",
                        retryable: false,
                        missing: nil
                    )
                )
            )
        }

        return .success(matches[0].details)
    }
}