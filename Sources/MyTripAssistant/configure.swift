import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Foundation

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateConversation())
    app.migrations.add(CreateMessage())

    // ================================ this will be replaced with the actual assistant service ================================
    app.assistantService = MockAssistantService()

    // ================================ this will be replaced with the actual flight status service ================================
    let sampleFlights = try FlightSampleData.make()

    app.flightStatusService = MockFlightStatusService(
        flights: sampleFlights
    )
    
    // ================================ this will be replaced with the actual booking details service ================================
    if app.environment == .development {
        guard
            let rawIDA = Environment.get("DEV_USER_A_ID"),
            let rawIDB = Environment.get("DEV_USER_B_ID"),
            let userAID = UUID(uuidString: rawIDA),
            let userBID = UUID(uuidString: rawIDB),
            userAID != userBID
        else {
            throw Abort(
                    .internalServerError,
                    reason: "Invalid sample booking user configuration"
            )
        }

        let sampleBookings = BookingSampleData.make(
            userAID: userAID,
            userBID: userBID
        )

        app.bookingDetailsService = MockBookingDetailsService(
            bookings: sampleBookings
        )
    }


    try routes(app)
}
