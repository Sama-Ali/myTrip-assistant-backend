import Vapor
import Foundation

// ================================ represents the verified identity for the current request ================================
struct AuthenticatedUser: Authenticatable, Sendable {
    let id: UUID
}