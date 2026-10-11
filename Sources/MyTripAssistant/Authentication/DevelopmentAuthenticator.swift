// ================================ Now:   Test token → DevelopmentAuthenticator → AuthenticatedUser ================================
// ================================ Later: Real token → Production authenticator → AuthenticatedUser ================================
import Vapor
import Foundation

struct DevelopmentAuthenticator: AsyncBearerAuthenticator {
    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
        // Never authenticate with development tokens in production.
        guard request.application.environment == .development else {
            throw Abort(
                .forbidden,
                reason: "Development authentication is disabled"
            )
        }

        guard
            let tokenA = Environment.get("DEV_USER_A_TOKEN"),
            let tokenB = Environment.get("DEV_USER_B_TOKEN"),
            !tokenA.isEmpty,
            !tokenB.isEmpty,
            tokenA != tokenB,
            let rawIDA = Environment.get("DEV_USER_A_ID"),
            let rawIDB = Environment.get("DEV_USER_B_ID"),
            let idA = UUID(uuidString: rawIDA),
            let idB = UUID(uuidString: rawIDB),
            idA != idB
        else {
            throw Abort(
                .internalServerError,
                reason: "Invalid development authentication configuration"
            )
        }

        if bearer.token == tokenA {
            request.auth.login(AuthenticatedUser(id: idA))
        } else if bearer.token == tokenB {
            request.auth.login(AuthenticatedUser(id: idB))
        }
    }
}