import Combine
import UIKit

protocol MoviesListViewModelUseCase {
    func fetchMovies() -> AnyPublisher<[MovieModel], Error>
}

final class MoviesListViewModel: MoviesListViewControllerViewModel {
    @Published var movies: [MovieModel] = []
    @Published var isLoading: Bool = false
    
    private let fetchMoviesUseCase: MoviesListViewModelUseCase
    
    private var originalMoviesList: [MovieModel] = [] {
        didSet {
            movies = originalMoviesList
        }
    }
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    @Passthrough var showMovieOverview: AnyPublisher<MovieModel, Never>
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(fetchMoviesUseCase: MoviesListViewModelUseCase) {
        self.fetchMoviesUseCase = fetchMoviesUseCase
    }
    
    func loadData() {
        guard !isLoading else { return }
        isLoading = true
        
        fetchMoviesUseCase
            .fetchMovies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case let .failure(error):
                    self?.error.send(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] movies in
                self?.originalMoviesList = movies
            })
            .store(in: &cancellables)
    }
    
    func userDidSelect(_ item: MovieModel) {
        _showMovieOverview.subject.send(item)
    }
}

