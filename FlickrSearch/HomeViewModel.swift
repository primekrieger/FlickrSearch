import Foundation

protocol HomeViewModelDelegate: class {
    func dataSourceDidChange()
}

class HomeViewModel {
    
    weak private var delegate: HomeViewModelDelegate?
    
    init(delegate: HomeViewModelDelegate) {
        self.delegate = delegate
    }
    
    private var timer: Timer?
    private var currentSearchTerm = ""
    var photosUrlStringsDataSource = [String]() {
        didSet {
            delegate?.dataSourceDidChange()
        }
    }
    
    func searchFlickr(for searchTerm: String) {
        timer?.invalidate()
        if searchTerm.count > 2 {
            currentSearchTerm = searchTerm.lowercased()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performPhotoSearch), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func performPhotoSearch() {
        NetworkManager.shared.searchImages(for: currentSearchTerm, page: 1) { [weak self] photosSearchResponseModel in
            if let responseModel = photosSearchResponseModel {
                self?.photosUrlStringsDataSource.append(contentsOf: responseModel.getUrlStringsForAllPhotosThumbs())
            }
        }
    }
    
}
