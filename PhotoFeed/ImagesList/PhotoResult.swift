import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int?
    let height: Int?
    let likedByUser: Bool? 
    let description: String?
    let urls: UrlsResult?
}

struct UrlsResult: Decodable {
    let thumb: String?
    let full: String?
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

