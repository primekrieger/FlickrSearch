import UIKit

protocol HomeViewModelDelegate: class {
    func dataSourceDidChange()
    func searchingStateChanged(searching: Bool)
    func searchFailed()
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
    var isSearchInProgress = false {
        didSet (value) {
            delegate?.searchingStateChanged(searching: value)
        }
    }
    var downloadedPhotos: [IndexPath: UIImage] = [:]
    private var photosUrlStringsDataSource = [String]() {
        didSet {
            delegate?.dataSourceDidChange()
        }
    }
    
    func getNumberOfCells() -> Int {
        return photosUrlStringsDataSource.count
    }
    
    private func getPhotoUrlString(for indexPath: IndexPath) -> String {
        return photosUrlStringsDataSource[indexPath.row]
    }
    
    func searchFlickr(for searchTerm: String) {
        let searchText = searchTerm.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        if searchText != currentSearchTerm {
            resetSearch()
            currentSearchTerm = searchText
            if currentSearchTerm.count > 2 {
                isSearchInProgress = true
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performPhotoSearch), userInfo: nil, repeats: false)
            }
        }
    }
    
    private func resetSearch() {
        isSearchInProgress = false
        timer?.invalidate()
        photosUrlStringsDataSource.removeAll()
        downloadedPhotos.removeAll()
        ImageDownloadManager.shared.cancelAllDownloadsInProgress()
        page = 1
        maxPages = 1
    }
    
    func subsequentSearch() {
        page += 1
        if page <= maxPages {
            performPhotoSearch()
        }
    }
    
    @objc private func performPhotoSearch() {
        isSearchInProgress = true
        NetworkManager.shared.searchImages(for: currentSearchTerm, page: page) { [weak self] photosSearchResponseModel in
            self?.isSearchInProgress = false
            if let responseModel = photosSearchResponseModel {
                self?.maxPages = responseModel.photos.pages
                self?.photosUrlStringsDataSource.append(contentsOf: responseModel.getUrlStringsForAllPhotosThumbs())
            } else {
                self?.delegate?.searchFailed()
            }
        }
    }
    
    func getImage(for indexPath: IndexPath, completion: @escaping (UIImage?, ImageDownloadState) -> Void) {
        ImageDownloadManager.shared.getImage(for: getPhotoUrlString(for: indexPath)) { [weak self] image, state in
            if image != nil {
                self?.downloadedPhotos[indexPath] = image!
            }
            completion(image, state)
        }
    }
    
    func isLastPage() -> Bool {
        return page >= maxPages
    }
    
    func reduceDownloadPriorityForImage(at indexPath: IndexPath) {
        if indexPath.row < getNumberOfCells() && downloadedPhotos[indexPath] == nil {
            ImageDownloadManager.shared.reducePriorityForDownload(with: photosUrlStringsDataSource[indexPath.row])
        }
    }
    
}
