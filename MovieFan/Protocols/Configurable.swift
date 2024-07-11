protocol Configurable {
    associatedtype ConfigurationItem
    func configure(with item: ConfigurationItem)
}
