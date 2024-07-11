import Combine

extension AnyPublisher {
    static func never() -> Self {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}
