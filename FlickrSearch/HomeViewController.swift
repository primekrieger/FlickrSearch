import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak private var photosCollectionView: UICollectionView!
    
    lazy private var viewModel = HomeViewModel(delegate: self)
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.register(UINib(nibName: PhotoThumbCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: PhotoThumbCollectionViewCell.reuseIdentifier)
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

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoThumbCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoThumbCollectionViewCell
        cell.photoImageView.image = nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoCell = cell as! PhotoThumbCollectionViewCell
        
        ImageDownloadManager.shared.getImage(for: viewModel.getPhotoUrlString(for: indexPath)) { image, state in
            if image != nil {
                DispatchQueue.main.async {
                    photoCell.photoImageView.image = image
                }
                
            }
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottom >= scrollView.contentSize.height {
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
    
}
