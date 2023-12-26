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
        UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4, animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1, animations: {
                self.likeButton.transform = .identity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.4, animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                self.likeButton.transform = .identity
            })
        })

        delegate?.imagesListCellDidTapLike(self)
        feedbackGenerator.notificationOccurred(.success)
    }
}

