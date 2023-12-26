import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int?
    let height: Int?
    let isLiked: Bool?
    let description: String?
    let urls: UrlsResult?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case isLiked = "liked_by_user"
        case description = "description"
        case urls = "urls"
    }
}

struct UrlsResult: Decodable {
    let thumbImageURL: String?
    let fullImageURL: String?

    private enum CodingKeys: String, CodingKey {
    case thumbImageURL = "thumb"
    case fullImageURL = "full"
    }
}



struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String?
    let fullImageURL: String?
    let isLiked: Bool
    
}

struct LikeResult: Decodable {
    let photo: PhotoResult?
}

