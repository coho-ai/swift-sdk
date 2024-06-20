import XCTest
@testable import CohoSDK

class CohoSDKTests: XCTestCase {

    var sdkOptions: CohoSDKOptions!
    var sdk: CohoSDK!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)

        sdkOptions = CohoSDKOptions(
            tenantId: "test-tenant-id",
            region: .US,
            retries: 3,
            retryDelay: 1.0,
            enableLogging: true
        )
        sdk = CohoSDK(options: sdkOptions, urlSession: mockSession)
    }

    override func tearDown() {
        super.tearDown()
        MockURLProtocol.mockResponses = [:]
        MockURLProtocol.requestCount = 0
    }

    func testSendSingleEventSuccess() {
        let expectation = self.expectation(description: "Event sent successfully")

        MockURLProtocol.mockResponses["https://app.us.coho.ai/api/raw-data/custom"] = [(200, Data())]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTAssertEqual(MockURLProtocol.requestCount, 1)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRequestURLAndPath() {
        let expectation = self.expectation(description: "Correct URL and path")

        MockURLProtocol.mockResponses["https://app.us.coho.ai/api/raw-data/custom"] = [(200, Data())]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                if let request = MockURLProtocol.lastRequest {
                    XCTAssertEqual(request.url?.path, "/api/raw-data/custom")
                    XCTAssertEqual(request.httpMethod, "POST")
                } else {
                    XCTFail("Request not captured")
                }
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSendSingleEventFailure() {
        let expectation = self.expectation(description: "Event send failure")

        MockURLProtocol.mockResponses["https://app.us.coho.ai/api/raw-data/custom"] = [(500, Data()), (500, Data()), (500, Data())]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Failed to send event after retries")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRetryMechanismSuccessOnSecondAttempt() {
        let expectation = self.expectation(description: "Retry mechanism success on second attempt")

        // Set up mock responses
        MockURLProtocol.requestCount = 0
        MockURLProtocol.mockResponses = [
            "https://app.us.coho.ai/api/raw-data/custom": [(500, Data()), (200, Data())]
        ]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTAssertEqual(MockURLProtocol.requestCount, 2)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRetryMechanismExhaustion() {
        let expectation = self.expectation(description: "Retry mechanism exhaustion")

        MockURLProtocol.requestCount = 0

        MockURLProtocol.mockResponses["https://app.us.coho.ai/api/raw-data/custom"] = [(500, Data()), (500, Data()), (500, Data())]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error.localizedDescription.contains("Failed to send event after retries"))
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSendEventWithoutUserId() {
        let expectation = self.expectation(description: "Event should not be sent without userId")

        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to missing userId but got success")
            case .failure(let error):
                XCTAssertEqual((error as? CohoSDK.CohoSDKError), CohoSDK.CohoSDKError.missingUserId, "Error should be missingUserId due to missing userId")
                XCTAssertEqual(MockURLProtocol.requestCount, 0, "There should be no request made")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNoRetryOnNonRetryableError() {
        let expectation = self.expectation(description: "Event should not be retried on non-retryable error")

        // Set up a mock response with a non-retryable error code (e.g., 400 Bad Request)
        MockURLProtocol.mockResponses["https://app.us.coho.ai/api/raw-data/custom"] = [(400, Data())]

        sdk.setUserId("12345")
        sdk.sendEvent(eventName: "testEvent", additionalProperties: ["customField": "customValue"]) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(_):
                XCTAssertEqual(MockURLProtocol.requestCount, 1, "There should be exactly one request made")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
