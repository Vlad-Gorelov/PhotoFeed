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

   /* private enum CodingKeys: String, CodingKey {
        case trumbImageURL = "thumb"
        case fullImageURL = "full"
    } */
}

struct LikeResult: Decodable {
    let photo: PhotoResult?
}

