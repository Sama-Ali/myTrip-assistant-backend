import Vapor
import Foundation

// ================================ الحالات المسموحة، حتى لا نكتب قيمًا مختلفة لنفس الحالة. ================================
enum FlightStatus: String, Codable, Sendable {
    case scheduled
    case delayed
    case boarding
    case departed
    case landed
    case cancelled
    case diverted
}

// ================================ بيانات النتيجة الناجحة، مطابقة لحقول FlightStatusOk في عقد الفريق ================================
struct FlightStatusResponse: Content {
    let ok: Bool = true

    let flightNumber: String
    let date: String
    let status: FlightStatus
    let delayMinutes: Int

    let origin: String?
    let destination: String?

    let scheduledDeparture: Date
    let estimatedDeparture: Date?
    let scheduledArrival: Date?
    let estimatedArrival: Date?

    let terminal: String?
    let gate: String?

    let updatedAt: Date
    let source: String

    enum CodingKeys: String, CodingKey {
        case ok
        case flightNumber = "flight_number"
        case date
        case status
        case delayMinutes = "delay_minutes"
        case origin
        case destination
        case scheduledDeparture = "scheduled_departure"
        case estimatedDeparture = "estimated_departure"
        case scheduledArrival = "scheduled_arrival"
        case estimatedArrival = "estimated_arrival"
        case terminal
        case gate
        case updatedAt = "updated_at"
        case source
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(ok, forKey: .ok)
        try container.encode(flightNumber, forKey: .flightNumber)
        try container.encode(date, forKey: .date)
        try container.encode(status, forKey: .status)
        try container.encode(delayMinutes, forKey: .delayMinutes)
        try container.encode(origin, forKey: .origin)
        try container.encode(destination, forKey: .destination)
        try container.encode(scheduledDeparture, forKey: .scheduledDeparture)
        try container.encode(estimatedDeparture, forKey: .estimatedDeparture)
        try container.encode(scheduledArrival, forKey: .scheduledArrival)
        try container.encode(estimatedArrival, forKey: .estimatedArrival)
        try container.encode(terminal, forKey: .terminal)
        try container.encode(gate, forKey: .gate)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(source, forKey: .source)
    }
}