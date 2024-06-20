import Foundation

class MockURLProtocol: URLProtocol {
    static var mockResponses: [String: [(Int, Data)]] = [:]
    static var lastRequest: URLRequest?
    static var requestCount = 0

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url?.absoluteString,
              var responses = MockURLProtocol.mockResponses[url], !responses.isEmpty else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocolErrorDomain", code: 404, userInfo: nil))
            return
        }

        MockURLProtocol.requestCount += 1
        MockURLProtocol.lastRequest = request

        let (statusCode, data) = responses.removeFirst()
        MockURLProtocol.mockResponses[url] = responses.isEmpty ? nil : responses

        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
