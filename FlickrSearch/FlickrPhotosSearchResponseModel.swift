struct FlickrPhotosSearchResponseModel: Codable {
    
    let photos: Photos
    
    struct Photos: Codable {
        let photo: [PhotoInfo]
        
        struct PhotoInfo: Codable {
            let id: String
            let secret: String
            let server: String
            let farm: Int
        }
    }
    
    
    
}
