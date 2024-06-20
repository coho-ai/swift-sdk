import Foundation

public struct CohoSDKOptions {
    public enum Region {
        case US, EU
    }

    public let tenantId: String
    public let region: Region
    public let retries: Int
    public let retryDelay: TimeInterval
    public let enableLogging: Bool

    public init(
        tenantId: String,
        region: Region,
        retries: Int = 0,
        retryDelay: TimeInterval = 100,
        enableLogging: Bool = false
    ) {
        self.tenantId = tenantId
        self.region = region
        self.retries = retries
        self.retryDelay = retryDelay
        self.enableLogging = enableLogging
    }
}
