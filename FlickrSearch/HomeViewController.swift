import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak private var photosCollectionView: UICollectionView!
    
    lazy private var viewModel = HomeViewModel(delegate: self)
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var collectionViewCellCalculatedWidth = CGFloat()
    
    private var cellsPerRow: CGFloat = 3 {
        didSet {
            viewDidLayoutSubviews()
            photosCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "GridIcon"), style: .plain, target: self, action: #selector(displayActionSheet))
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.register(UINib(nibName: PhotoThumbCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: PhotoThumbCollectionViewCell.reuseIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(">>>>>>>>>>>>>>")
        collectionViewCellCalculatedWidth = (view.frame.width - (cellsPerRow + 1) * 10) / cellsPerRow
    }
    
    @objc private func displayActionSheet() {
        let alert = UIAlertController(title: "Select no. of images displayed per row", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "2", style: .default, handler: { _ in
            self.cellsPerRow = 2
        }))
        alert.addAction(UIAlertAction(title: "3", style: .default, handler: { _ in
             self.cellsPerRow = 3
        }))
        alert.addAction(UIAlertAction(title: "4", style: .default, handler: { _ in
             self.cellsPerRow = 4
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Enter image name to search"
        navigationItem.titleView = searchController.searchBar
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchFlickr(for: searchController.searchBar.text ?? "")
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func dataSourceDidChange() {
        photosCollectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoThumbCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoThumbCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoCell = cell as! PhotoThumbCollectionViewCell
        if let photo = viewModel.downloadedPhotos[indexPath] {
            photoCell.photoImageView.image = photo
        } else {
            photoCell.photoImageView.image = nil
            
            ImageDownloadManager.shared.getImage(for: viewModel.getPhotoUrlString(for: indexPath)) { [weak self] image, state in
                if image != nil {
                    self?.viewModel.downloadedPhotos[indexPath] = image!
                    DispatchQueue.main.async {
                        if let cell = self?.photosCollectionView.cellForItem(at: indexPath) as? PhotoThumbCollectionViewCell {
                            cell.photoImageView.image = image
                        }
                    }
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.reduceDownloadPriorityForImage(at: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        checkAndPerformSubsequentSearch()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkAndPerformSubsequentSearch()
    }
    
    func checkAndPerformSubsequentSearch() {
        let bottom = photosCollectionView.contentOffset.y + photosCollectionView.frame.size.height
        if bottom >= photosCollectionView.contentSize.height {
            if !viewModel.isSearchInProgress {
                viewModel.subsequentSearch()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let loadingFooterView = photosCollectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: LoadingFooterCollectionReusableView.reuseIdentifier,
                                                                         for: indexPath) as! LoadingFooterCollectionReusableView
        if viewModel.getNumberOfCells() == 0 {
            loadingFooterView.showInfoLabel(with: "No data")
        } else if viewModel.isLastPage() {
            loadingFooterView.showInfoLabel(with: "No more results")
        } else {
            loadingFooterView.showLoadingIndicator()
        }
        return loadingFooterView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellCalculatedWidth, height: collectionViewCellCalculatedWidth)
    }
    
}
