import UIKit

class ImageDownloadManager {
    
    enum DownloadState {
        case downloaded, inProgress, failed
    }
    
    static let shared = ImageDownloadManager()
    
    private var downloadsInProgress: [String: URLSessionDataTask] = [:]
    private let imageCache = NSCache<NSString, UIImage>()
    
    func getImage(for urlString: String, completion: @escaping (UIImage?, DownloadState) -> Void) {
        if let imageUrl = URL(string: urlString) {
            if let downloadTaskInProgress = downloadsInProgress[urlString] {
                downloadTaskInProgress.priority = URLSessionTask.highPriority
                completion(nil, .inProgress)
            } else if let cachedImage = imageCache.object(forKey: urlString as NSString) {
                completion(cachedImage, .downloaded)
            } else {
                let request = URLRequest(url: imageUrl)
                let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    self?.downloadsInProgress.removeValue(forKey: urlString)
                    if error == nil, let imageData = data, let image = UIImage(data: imageData) {
                        self?.imageCache.setObject(image, forKey: urlString as NSString)
                        completion(image, .downloaded)
                    } else {
                        completion(nil, .failed)
                    }
                }
                downloadsInProgress[urlString] = task
                task.resume()
            }
        } else {
            completion(nil, .failed)
        }
    }
    
    func reducePriorityForDownload(with urlString: String) {
        if let downloadTaskInProgress = downloadsInProgress[urlString] {
            downloadTaskInProgress.priority = URLSessionTask.lowPriority
        }
    }
    
    func cancelAllDownloadsInProgress() {
        for (key, task) in downloadsInProgress {
            task.cancel()
            downloadsInProgress.removeValue(forKey: key)
        }
    }
    
}
