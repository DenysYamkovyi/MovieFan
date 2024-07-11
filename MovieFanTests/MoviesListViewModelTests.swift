import XCTest
import Combine
@testable import MovieFan

class MoviesListViewModelTests: XCTestCase {
    var viewModel: MoviesListViewModel!
    var mockUseCase: MockMoviesListViewModelUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = MockMoviesListViewModelUseCase()
        viewModel = MoviesListViewModel(fetchMoviesUseCase: mockUseCase)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadDataSuccess() {
        // Given
        let movies = [MovieModel(title: "Test Movie", thumbnail: "Test Thumbnail", overview: "Test Overview")]
        mockUseCase.moviesPublisher = Just(movies)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Movies loaded")
        
        // When
        viewModel.loadData()

        // Then
        viewModel.$movies
            .dropFirst() // Skip the initial value
            .sink { loadedMovies in
                XCTAssertEqual(loadedMovies, movies)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadDataFailure() {
        // Given
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockUseCase.moviesPublisher = Fail(error: error)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Error received")

        // When
        viewModel.loadData()

        // Then
        viewModel.error
            .sink { receivedError in
                XCTAssertEqual(receivedError.localizedDescription, error.localizedDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testUserDidSelect() {
        // Given
        let movie = MovieModel(title: "Test Movie", thumbnail: "Test Thumbnail", overview: "Test Overview")
        let expectation = XCTestExpectation(description: "Movie overview shown")

        // When
        viewModel.showMovieOverview
            .sink { selectedMovie in
                XCTAssertEqual(selectedMovie, movie)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.userDidSelect(movie)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

// Mock Use Case
class MockMoviesListViewModelUseCase: MoviesListViewModelUseCase {
    var moviesPublisher: AnyPublisher<[MovieModel], Error>!
    
    func fetchMovies() -> AnyPublisher<[MovieModel], Error> {
        return moviesPublisher
    }
}
