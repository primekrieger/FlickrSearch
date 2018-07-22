struct FlickrPhotosSearchResponseModel: Codable {
    let photos: Photos
    
    struct Photos: Codable {
        let pages: Int
        let photo: [PhotoInfo]
        
        struct PhotoInfo: Codable {
            let id: String
            let secret: String
            let server: String
            let farm: Int
        }
    }
    
    func getUrlStringsForAllPhotosThumbs() -> [String] {
        var result = [String]()
        for photo in photos.photo {
            let urlString = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_t.jpg"
            result.append(urlString)
        }
        return result
    }
    
    
}
