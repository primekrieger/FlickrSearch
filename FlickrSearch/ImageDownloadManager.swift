import UIKit

class ImageDownloadManager {
    
    enum DownloadState {
        case downloaded, inProgress, failed
    }
    
    static let shared = ImageDownloadManager()
    
    lazy var downloadsInProgress: [String: URLSessionDataTask] = [:]
    let imageCache = NSCache<NSString, UIImage>()
    
    func getImage(for urlString: String, completion: @escaping (UIImage?, DownloadState) -> Void) {
        if let imageUrl = URL(string: urlString) {
            if let downloadTaskInProgress = downloadsInProgress[imageUrl.absoluteString] {
                downloadTaskInProgress.priority = URLSessionTask.highPriority
                completion(nil, .inProgress)
            } else if let cachedImage = imageCache.object(forKey: imageUrl.absoluteString as NSString) {
                completion(cachedImage, .downloaded)
            } else {
                let request = URLRequest(url: imageUrl)
                let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    self?.downloadsInProgress.removeValue(forKey: imageUrl.absoluteString)
                    if error == nil, let imageData = data, let image = UIImage(data: imageData) {
                        self?.imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
                        completion(image, .downloaded)
                    } else {
                        completion(nil, .failed)
                    }
                }
                downloadsInProgress[imageUrl.absoluteString] = task
                task.resume()
            }
        } else {
            completion(nil, .failed)
        }
    }
    
}
