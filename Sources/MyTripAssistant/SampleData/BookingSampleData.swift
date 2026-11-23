import Foundation

enum BookingSampleData {
    static func make(
        userAID: UUID,
        userBID: UUID
    ) -> [SampleBooking] {
        [
            SampleBooking(
                userID: userAID,
                details: BookingDetailsResponse(
                    bookingReference: "ABC123",
                    flightNumber: "SV1021",
                    date: "2026-11-10",
                    cabinClass: .economy,
                    seat: "14C",
                    baggageAllowanceKg: nil,
                    baggageAllowancePieces: 2,
                    baggagePieceMaxKg: 23
                )
            ),
            SampleBooking(
                userID: userAID,
                details: BookingDetailsResponse(
                    bookingReference: "DEF456",
                    flightNumber: "SV1021",
                    date: "2026-11-20",
                    cabinClass: .business,
                    seat: "2A",
                    baggageAllowanceKg: 32,
                    baggageAllowancePieces: nil,
                    baggagePieceMaxKg: nil
                )
            ),
            SampleBooking(
                userID: userBID,
                details: BookingDetailsResponse(
                    bookingReference: "GHI789",
                    flightNumber: "SV1022",
                    date: "2026-11-12",
                    cabinClass: .economy,
                    seat: nil,
                    baggageAllowanceKg: 23,
                    baggageAllowancePieces: nil,
                    baggagePieceMaxKg: nil
                )
            )
        ]
    }
}