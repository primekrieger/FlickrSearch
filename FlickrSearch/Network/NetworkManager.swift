import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private var executingRequest: DataRequest?
    
    func searchImages(for searchTerm: String, page: Int, completion: @escaping (FlickrPhotosSearchResponseModel?) -> Void) {
        executingRequest?.cancel()
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.flickrAPIKey)&text=\(searchTerm.replacingOccurrences(of: " ", with: "%20"))&per_page=30&page=\(page)&format=json&nojsoncallback=1"
        
        executingRequest = Alamofire.request(url).responseJSON { [weak self] response in
            self?.executingRequest = nil
            if let data = response.data, let responseModel = try? JSONDecoder().decode(FlickrPhotosSearchResponseModel.self, from: data) {
                completion(responseModel)
            } else {
                completion(nil)
            }
        }
    }
    
    func cancelSearchRequest() {
        executingRequest?.cancel()
    }
}
