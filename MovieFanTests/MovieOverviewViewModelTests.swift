import XCTest
import Combine
@testable import MovieFan

final class MovieOverviewViewModelTests: XCTestCase {
    var viewModel: MovieOverviewViewModel!
    var mockImageLoaderService: MockImageLoaderService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockImageLoaderService = MockImageLoaderService()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockImageLoaderService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInit_SetsTitleAndOverview() {
        // Given
        let movie = MovieModel(title: "Test Movie", thumbnail: "path/to/image", overview: "Test Overview")
        
        // When
        viewModel = MovieOverviewViewModel(movie: movie, imageLoader: mockImageLoaderService)
        
        // Then
        XCTAssertEqual(viewModel.title, "Test Movie")
        XCTAssertEqual(viewModel.overview, "Test Overview")
    }
    
    func testLoadImage_SetsImage() {
        // Given
        let movie = MovieModel(title: "Test Movie", thumbnail: "path/to/image", overview: "Test Overview")
        let testImage = UIImage(systemName: "photo")!
        mockImageLoaderService.result = .success(testImage)
        
        // When
        viewModel = MovieOverviewViewModel(movie: movie, imageLoader: mockImageLoaderService)
        
        // Wait for the image loading to complete
        let expectation = XCTestExpectation(description: "Image loaded")
        viewModel.$image
            .sink { image in
                if image != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(viewModel.image, testImage)
    }
    
    func testLoadImage_HandlesError() {
        // Given
        let movie = MovieModel(title: "Test Movie", thumbnail: "path/to/image", overview: "Test Overview")
        let testError = NSError(domain: "", code: -1, userInfo: nil)
        mockImageLoaderService.result = .failure(testError)
        
        // When
        viewModel = MovieOverviewViewModel(movie: movie, imageLoader: mockImageLoaderService)
        
        // Wait for the error to be emitted
        let expectation = XCTestExpectation(description: "Error emitted")
        viewModel.error
            .sink { error in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
}
