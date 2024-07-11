import Foundation

struct MovieModel: MovieTableViewCellViewModel, Hashable {
    let title: String
    let thumbnail: String
    let overview: String
}

extension MovieModel {
    init(movie: Movie) {
        self.title = movie.title
        self.thumbnail = movie.thumbnail
        self.overview = movie.overview
    }
}
