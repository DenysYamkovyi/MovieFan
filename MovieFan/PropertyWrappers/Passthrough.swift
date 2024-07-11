import Combine
import Foundation

@propertyWrapper
public struct Passthrough<Output, Failure: Error> {
    public let subject: PassthroughSubject<Output, Failure> = .init()
    
    public var wrappedValue: AnyPublisher<Output, Failure> {
        subject.eraseToAnyPublisher()
    }
    
    public init() {}
}