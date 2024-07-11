import XCTest
import Combine
@testable import MovieFan

final class FetchMoviesUseCaseTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        cancellables = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }

    func testFetchMoviesSuccess() {
        // Given
        let useCase = FetchMoviesUseCase()
        let expectation = XCTestExpectation(description: "Movies fetched successfully")
        let mockResponseData = """
        {
            "page": 1,
            "results": [
                {
                    "title": "Test Movie",
                    "poster_path": "/test.jpg",
                    "overview": "Test Overview"
                }
            ],
            "total_pages": 1,
            "total_results": 1
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockResponseData)
        }

        // When
        useCase.fetchMovies()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            }, receiveValue: { movies in
                // Then
                XCTAssertEqual(movies.count, 1)
                XCTAssertEqual(movies.first?.title, "Test Movie")
                XCTAssertEqual(movies.first?.thumbnail, "/test.jpg")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchMoviesFailure() {
        // Given
        let useCase = FetchMoviesUseCase()
        let expectation = XCTestExpectation(description: "Movies fetch failed")
        let mockError = URLError(.badServerResponse)

        MockURLProtocol.requestHandler = { request in
            throw mockError
        }

        // When
        useCase.fetchMovies()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
                    expectation.fulfill()
                default:
                    XCTFail("Expected failure, got \(completion) instead")
                }
            }, receiveValue: { movies in
                XCTFail("Expected no movies, but got \(movies) instead")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

