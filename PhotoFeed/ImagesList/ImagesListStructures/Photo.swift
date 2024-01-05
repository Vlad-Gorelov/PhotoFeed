import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String?
    let fullImageURL: String?
    let isLiked: Bool
}
