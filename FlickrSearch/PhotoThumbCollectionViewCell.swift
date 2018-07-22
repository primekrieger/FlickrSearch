import UIKit

class PhotoThumbCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "PhotoThumbCollectionViewCell"
    static let reuseIdentifier = "photoThumbCollectionViewCell"
    
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var failedLabel: UILabel!
    
    func setImage(_ image: UIImage) {
        downloadIndicator.stopAnimating()
        failedLabel.isHidden = true
        photoImageView.image = image
    }
    
    func showDownloadIndicator() {
        photoImageView.image = nil
        failedLabel.isHidden = true
        downloadIndicator.startAnimating()
    }
    
    func setFailed() {
        photoImageView.image = nil
        downloadIndicator.stopAnimating()
        failedLabel.isHidden = false
    }
    
}
