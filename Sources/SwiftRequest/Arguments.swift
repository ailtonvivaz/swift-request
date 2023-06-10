@propertyWrapper
public struct Body<Value: Encodable> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct PathParam<Value: CustomStringConvertible> {
    public var wrappedValue: Value
    let name: String?
    
    public init(wrappedValue: Value, _ name: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

@propertyWrapper
public struct QueryParam<Value: CustomStringConvertible> {
    public var wrappedValue: Value
    let name: String?
    
    public init(wrappedValue: Value, _ name: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

@propertyWrapper
public struct Header<Value: CustomStringConvertible> {
    public var wrappedValue: Value
    let name: String?
    
    public init(wrappedValue: Value, _ name: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

@propertyWrapper
public struct FieldParam<Value: CustomStringConvertible> {
    public var wrappedValue: Value
    let name: String?
    
    public init(wrappedValue: Value, _ name: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

extension Optional: CustomStringConvertible where Wrapped: CustomStringConvertible {
    public var description: String {
        self?.description ?? "nil"
    }
}
