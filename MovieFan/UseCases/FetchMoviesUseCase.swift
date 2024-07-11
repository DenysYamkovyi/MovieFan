import Combine
import Foundation

struct FetchMoviesUseCase: MoviesListViewModelUseCase {
    
    private let url = URL(string: "https://api.themoviedb.org/3/discover/movie")!
    
    func fetchMovies() -> AnyPublisher<[MovieModel], Error> {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "with_people", value: "71580"),
        ]
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNzhkYWU0NGI2ODFiNDdiODVhN2MyNjAwODg0ZDYyYiIsIm5iZiI6MTcyMDY1NzI3OC44MTg0NzksInN1YiI6IjY2OGVmODc5MDQ3OWU0NDMxNjI4MWFlYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AXycQWx1mhEsgd4hnye7ZkDRPKvtVYyNalmC7EUAvSI"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: FetchMoviesResponse.self, decoder: JSONDecoder())
            .map { data -> [MovieModel] in
                data.results.map { .init(movie: $0) }
            }
            .eraseToAnyPublisher()
    }
}
