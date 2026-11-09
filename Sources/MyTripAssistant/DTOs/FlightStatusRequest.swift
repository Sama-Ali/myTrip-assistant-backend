import Vapor

struct FlightStatusRequest: Content {
    let flightNumber: String
    let date: String?

    enum CodingKeys: String, CodingKey {
        // ================================ يربط اسم flightNumber في Swift باسم flight_number ================================
        case flightNumber = "flight_number"
        case date
    }
}

// ================================مثلًا، هذا الطلب:================================
// {
//   "flight_number": "SV1021",
//   "date": "2026-11-10"
// }
// سيصبح داخل Swift:
// payload.flightNumber // "SV1021"
// payload.date         // "2026-11-10"