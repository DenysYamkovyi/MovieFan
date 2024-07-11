import Foundation

struct FetchMoviesResponse: Decodable {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [Movie]
    
    private enum CodingKeys : String, CodingKey {
        case page, totalPages = "total_pages", totalResults = "total_results", results
    }
}

struct Movie: Decodable {
    let title: String
    let thumbnail: String
    let overview: String
    
    private enum CodingKeys : String, CodingKey {
        case title, thumbnail = "poster_path", overview
    }
}
