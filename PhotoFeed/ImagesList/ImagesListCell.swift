import UIKit
import Kingfisher

//MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}


final class ImagesListCell: UITableViewCell {
    
    //MARK: - Constants
    
    static let reuseIdentifier = "ImagesListCell"
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    weak var delegate: ImagesListCellDelegate?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: - Functions
    
    func setIsLiked(entryValue: Bool) {
        let image = entryValue ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        
        likeButton.setImage(image, for: .normal)
    }
    
    //MARK: - Button Actions
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
        feedbackGenerator.notificationOccurred(.success)
    }
}

