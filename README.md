# Coho Swift SDK

## Overview

The Coho Swift SDK provides an easy way to integrate with Coho's services, allowing you to send custom events to Coho's endpoint. The SDK supports retry mechanisms for transient errors and provides extensive logging capabilities.

## Installation

To add the Coho Swift SDK to your project, install it using Swift Package Manager:

1. Open your project in Xcode.
2. Go to File > Add Package Dependencies... .
3. Enter the repository URL for the Coho SDK: https://github.com/coho-ai/swift-sdk .
4. Select the version you want to use.
5. Add the package to your targets.

## Usage

### Initializing the SDK

Before using the SDK, you need to initialize it with the appropriate options.

```swift
import CohoSDK

let sdkOptions = CohoSDKOptions(
    tenantId: "your-tenant-id",
    region: .US, // or .EU
    retries: 3, // default is 0
    retryDelay: 1000, // default is 100ms
    enableLogging: true
)

let cohoSDK = CohoSDK(options: sdkOptions)
```

### Setting the User ID

Before sending events, you need to set the user ID using the `setUserId` method.

```swift
cohoSDK.setUserId("user-id")
```

### Sending Events

To send an event, use the `sendEvent` method. This method takes the event name and an optional dictionary of additional properties.

```swift
cohoSDK.sendEvent(eventName: "EventName", additionalProperties: ["customField": "customValue"]) { result in
    switch result {
    case .success:
        print("Event sent successfully")
    case .failure(let error):
        print("Error sending event: \(error)")
    }
}
```

### Example

Here's a complete example that initializes the SDK, sets the user ID, and sends an event.

```swift
import CohoSDK

let sdkOptions = CohoSDKOptions(
    tenantId: "your-tenant-id",
    region: .US,
    retries: 3,
    retryDelay: 1000,
    enableLogging: true
)

let cohoSDK = CohoSDK(options: sdkOptions)

cohoSDK.setUserId("user-id")

cohoSDK.sendEvent(eventName: "EventName", additionalProperties: [
    "customField1": "customValue1",
    "customField2": 123,
    "customField3": true
])
```

## Detailed API

### CohoSDKOptions

`CohoSDKOptions` is used to configure the SDK.

```swift
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
```

### CohoSDK

`CohoSDK` provides methods to set the user ID and send events.

#### setUserId

Sets the user ID for the SDK. This method must be called before sending any events.

```swift
public func setUserId(_ userId: String)
```

#### sendEvent

Sends an event to Coho's endpoint. This method takes the event name and an optional dictionary of additional properties.

```swift
public func sendEvent(
    eventName: String,
    additionalProperties: [String: Any] = [:],
    completion: @escaping (Result<Void, Error>) -> Void = { _ in }
)
```

## Error Handling

The SDK provides robust error handling mechanisms, including retries for transient errors. If the user ID is not set or is empty, the event will not be sent, and a log message will indicate that the user ID is missing.

## Logging

Logging can be enabled by setting the `enableLogging` flag in `CohoSDKOptions`. When enabled, the SDK logs detailed information about requests and responses, which can be useful for debugging.

## License

The Coho Swift SDK is released under the MIT License. See [LICENSE](https://opensource.org/licenses/MIT) for details.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](https://github.com/coho-ai/swift-sdk-test/blob/main/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

For any questions or issues, please open an issue on GitHub.
