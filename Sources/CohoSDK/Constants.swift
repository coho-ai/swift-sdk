import Foundation

struct Constants {
    struct Endpoints {
        static let usEndpoint = "https://app.us.coho.ai/api/raw-data/custom"
        static let euEndpoint = "https://app.coho.ai/api/raw-data/custom"
    }

    struct Headers {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let acceptAll = "*/*"
        static let tenantIdKey = "X-Coho-TenantId"
        static let userIdKey = "X-Coho-UserId-Key"
        static let applicationJson = "application/json"
        static let userId = "userId"
    }

    struct Messages {
        static let serverError = "Server error"
        static let failedAfterRetries = "Failed to send event after retries"
    }

    struct RetryableErrorCodes {
        static let codes = [408, 429, 500, 502, 503, 504]
    }
}
