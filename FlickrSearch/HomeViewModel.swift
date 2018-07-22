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
    private var page = 1
    private var maxPages = 1
    var isSearchInProgress = false
    private var photosUrlStringsDataSource = [String]() {
        didSet {
            delegate?.dataSourceDidChange()
        }
    }
    
    func getNumberOfCells() -> Int {
        return photosUrlStringsDataSource.count
    }
    
    func getPhotoUrlString(for indexPath: IndexPath) -> String {
        return photosUrlStringsDataSource[indexPath.row]
    }
    
    func searchFlickr(for searchTerm: String) {
        timer?.invalidate()
        photosUrlStringsDataSource.removeAll()
        ImageDownloadManager.shared.cancelAllDownloadsInProgress()
        currentSearchTerm = searchTerm.lowercased()
        page = 1
        if searchTerm.count > 2 {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performPhotoSearch), userInfo: nil, repeats: false)
        }
    }
    
    func subsequentSearch() {
        page += 1
        if page <= maxPages {
            performPhotoSearch()
        }
    }
    
    @objc private func performPhotoSearch() {
        // TODO: Invalidate previous requests
        isSearchInProgress = true
        NetworkManager.shared.searchImages(for: currentSearchTerm, page: page) { [weak self] photosSearchResponseModel in
            self?.isSearchInProgress = false
            if let responseModel = photosSearchResponseModel {
                self?.maxPages = responseModel.photos.pages
                self?.photosUrlStringsDataSource.append(contentsOf: responseModel.getUrlStringsForAllPhotosThumbs())
            }
        }
    }
    
    func isLastPage() -> Bool {
        return page >= maxPages
    }
    
}
