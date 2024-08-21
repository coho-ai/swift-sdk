import Foundation
import UIKit

public class CohoSDK {
    private let tenantId: String
    private let endpoint: URL
    private let retries: Int
    private let retryDelay: TimeInterval
    private let enableLogging: Bool
    private let urlSession: URLSession
    private var userId: String?

    public enum CohoSDKError: Error {
        case serverError
        case failedAfterRetries
        case missingUserId
    }

    public init(options: CohoSDKOptions, urlSession: URLSession = .shared) {
        self.tenantId = options.tenantId
        self.endpoint = CohoSDK.getEndpoint(for: options.region)
        self.retries = options.retries
        self.retryDelay = options.retryDelay
        self.enableLogging = options.enableLogging
        self.urlSession = urlSession
    }

    public func setUserId(_ userId: String) {
        self.userId = userId
        log("userId set to: \(userId)")
    }

    public func sendEvent(eventName: String, additionalProperties: [String: Any] = [:], completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        guard let userId = self.userId else {
            log("Error: userId is not set. Please call setUserId before sending events.")
            completion(.failure(CohoSDKError.missingUserId))
            return
        }

        do {
            let jsonData = try encodeEvent(eventName: eventName, userId: userId, additionalProperties: additionalProperties)
            sendRequest(with: jsonData, attempts: 0, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    private static func getEndpoint(for region: CohoSDKOptions.Region) -> URL {
        switch region {
        case .US:
            return URL(string: Constants.Endpoints.usEndpoint)!
        case .EU:
            return URL(string: Constants.Endpoints.euEndpoint)!
        }
    }

    private func log(_ message: String) {
        if enableLogging {
            print("[CohoSDK] \(message)")
        }
    }
    
    private func encodeEvent(eventName: String, userId: String, additionalProperties: [String: Any]) throws -> Data {
        var event: [String: Any] = [
            "eventName": eventName,
            "userId": userId,
            "clientTimestamp": Date().iso8601String,
            "timeZone": TimeZone.current.identifier,
            "localClientTime": Date().localIso8601String,
            "country": Locale.current.regionCode ?? "Unknown",
            "language": Locale.current.languageCode ?? "Unknown",
            "os": UIDevice.current.systemName,
            "osVersion": UIDevice.current.systemVersion,
            "device": UIDevice.current.model,
            "manufacturer": "Apple",
            "deviceType": UIDevice.current.userInterfaceIdiom == .pad ? "Tablet" : "Mobile"
        ]
        
        additionalProperties.forEach { event[$0.key] = $0.value }

        let payload: [String: Any] = ["events": [event]]
        return try JSONSerialization.data(withJSONObject: payload, options: [])
    }
    
    private func sendRequest(with body: Data, attempts: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = createRequest()

        log("Sending request to URL: \(request.url?.absoluteString ?? "No URL")")
        log("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        log("Request body: \(String(data: body, encoding: .utf8) ?? "Unable to encode body")")

        urlSession.uploadTask(with: request, from: body) { [weak self] data, response, error in
            if let error = error {
                self?.handleError(error, attempts: attempts, with: body, completion: completion)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: Constants.Messages.serverError])
                self?.handleError(error, attempts: attempts, with: body, completion: completion)
                return
            }

            self?.log("Event sent successfully")
            completion(.success(()))
        }.resume()
    }

    private func createRequest() -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(Constants.Headers.applicationJson, forHTTPHeaderField: Constants.Headers.contentType)
        request.setValue(Constants.Headers.acceptAll, forHTTPHeaderField: Constants.Headers.accept)
        request.setValue(tenantId, forHTTPHeaderField: Constants.Headers.tenantIdKey)
        request.setValue(Constants.Headers.userId, forHTTPHeaderField: Constants.Headers.userIdKey)
        request.setValue("sdk", forHTTPHeaderField: Constants.Headers.dataSourceContext)
        
        return request
    }

    private func handleError(_ error: Error, attempts: Int, with body: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        log("Error: \(error.localizedDescription)")

        let statusCode = (error as NSError).code
        if attempts < retries && Constants.RetryableErrorCodes.codes.contains(statusCode) {
            log("Retrying in \(retryDelay) seconds...")
            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                self?.sendRequest(with: body, attempts: attempts + 1, completion: completion)
            }
        } else {
            log("Failed to send event after \(retries) attempts or non-retryable error encountered")
            let finalError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: Constants.Messages.failedAfterRetries])
            completion(.failure(finalError))
        }
    }
}

private extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time
        return formatter.string(from: self)
    }
    
    var localIso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current // Local time zone
        return formatter.string(from: self)
    }
}
