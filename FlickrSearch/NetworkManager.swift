import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    
    func searchImages(for searchTerm: String, page: Int, completion: @escaping (FlickrPhotosSearchResponseModel?) -> Void) {
        // TODO: Handle spaces in search term
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=eec93a2b3390c8735ab2e6671612de59&text=\(searchTerm)&per_page=30&page=\(page)&format=json&nojsoncallback=1"
        Alamofire.request(url).responseJSON { response in
            if let data = response.data, let responseModel = try? JSONDecoder().decode(FlickrPhotosSearchResponseModel.self, from: data) {
                completion(responseModel)
            } else {
                completion(nil)
            }
        }
    }
}
