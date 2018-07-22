import UIKit

class LoadingFooterCollectionReusableView: UICollectionReusableView {

    static let reuseIdentifier = "LoadingFooterCollectionReusableView"
    
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var infoLabel: UILabel!
    
    func showInfoLabel(with text: String) {
        loadingIndicator.stopAnimating()
        infoLabel.isHidden = false
        infoLabel.text = text
    }
    
    func showLoadingIndicator() {
        infoLabel.isHidden = true
        loadingIndicator.startAnimating()
    }
}
