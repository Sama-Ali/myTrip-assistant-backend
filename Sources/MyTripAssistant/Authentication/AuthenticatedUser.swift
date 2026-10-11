import Vapor
import Foundation

struct AuthenticatedUser: Authenticatable, Sendable {
    let id: UUID
}