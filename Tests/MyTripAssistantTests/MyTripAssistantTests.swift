@testable import MyTripAssistant
import Testing
import Foundation

@Suite("Flight response validation")
struct FlightStatusResponseValidatorTests {
    @Test("Accepts all valid sample flights")
    func acceptsValidSampleFlights() throws {
        let flights = try FlightSampleData.make()

        #expect(flights.count == 4)

        for flight in flights {
            try FlightStatusResponseValidator.validate(flight)
        }
    }

    @Test("Rejects a landed flight without actual arrival")
func rejectsLandedFlightWithoutArrival() throws {
    let flight = FlightStatusResponse(
        flightNumber: "SV1023",
        marketingAirline: Airline(code: "SV", name: "Saudia"),
        operatingAirline: Airline(code: "SV", name: "Saudia"),
        operatingFlightNumber: nil,
        date: "2026-11-10",
        status: .landed,
        departureDelayMinutes: 0,
        arrivalDelayMinutes: nil,
        origin: "RUH",
        destination: "JED",
        scheduledDeparture: Date(timeIntervalSince1970: 1_800_000_000),
        estimatedDeparture: nil,
        actualDeparture: Date(timeIntervalSince1970: 1_800_000_000),
        scheduledArrival: nil,
        estimatedArrival: nil,
        actualArrival: nil, // الخطأ المقصود
        cancellationNotifiedAt: nil,
        terminal: nil,
        gate: nil,
        updatedAt: Date(timeIntervalSince1970: 1_800_000_100),
        source: "mock"
    )

    do {
        try FlightStatusResponseValidator.validate(flight)
        Issue.record("Expected validation to reject missing actual_arrival")
    } catch let error as FlightResponseValidationError {
        #expect(error.missing == ["actual_arrival"])
        #expect(error.body.code == .badSourceData)
    }
}
}