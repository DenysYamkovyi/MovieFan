import UIKit
import Combine

protocol MovieTableViewCellViewModel {
    var title: String { get }
    var thumbnail: String { get }
}

class MovieTableViewCellView: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCellView"
    
    private var cancellables = Set<AnyCancellable>()
    
    // Subviews
    let image = UIImageView()
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Configure movie image view
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        
        let aspectRatio = image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 3.0)
        aspectRatio.isActive = true
        
        // Configure title label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Add subviews
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        // Image
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            image.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            image.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
        // Label
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
}

// Extension to conform to the Configurable protocol
extension MovieTableViewCellView: Configurable {
    func configure(with viewModel: MovieTableViewCellViewModel) {
        cancellables.removeAll()
        
        label.text = viewModel.title
        
        ImageLoader().loadImage(path: viewModel.thumbnail)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                
            }, receiveValue: { [weak self] image in
                self?.image.image = image
            })
            .store(in: &cancellables)
    }
}
