struct BookingResponseValidationError: Error {
    let message: String
    let missing: [String]

    init(
        message: String,
        missing: [String] = []
    ) {
        self.message = message
        self.missing = missing
    }

    var body: ToolErrorBody {
        ToolErrorBody(
            code: .badSourceData,
            message: message,
            retryable: true,
            missing: missing.isEmpty ? nil : missing
        )
    }
}