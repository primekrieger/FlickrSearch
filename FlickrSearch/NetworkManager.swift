import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    
    func searchImages(for searchTerm: String, completion: @escaping ([FlickrPhotosSearchResponseModel]?) -> Void) {
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=eec93a2b3390c8735ab2e6671612de59&text=dog&per_page=50&page=2&format=json&nojsoncallback=1&api_sig=a9748818066b72c475010d11830b3f6e"
        Alamofire.request(url).responseJSON { response in
            print(response.result)
            
            
            
            if let respmodel = try? JSONDecoder().decode(FlickrPhotosSearchResponseModel.self, from: response.data!) {
                print("success")
            } else {
                print("failure")
            }
            
            
        }
    }
    
    
}
