//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 11/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

extension FlickrClient {
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        
        static let MaxImages = 10
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "07ec14edd93e1ac6b6a66b2e7f4ae117"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPage = "1"
    }
    
    struct ResponseKeys {
        static let Photos = "photos"
        static let PhotoList = "photo"
    }
}