struct Quote: Decodable {
    let id: String
    let content: String
    let author: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case author
        case tags
    }
}
