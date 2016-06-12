//
//  FlickrConvience.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 11/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getImages(location: Pin, completionHandlerForGetImages: (result: AnyObject?, error: String?)->Void) {
        let parameters = [
            ParameterKeys.Method: ParameterValues.SearchMethod,
            ParameterKeys.APIKey: ParameterValues.APIKey,
            ParameterKeys.BoundingBox: bboxString(Double(location.latitude!), longitude: Double(location.longitude!)),
            ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch,
            ParameterKeys.Extras: ParameterValues.MediumURL,
            ParameterKeys.Format: ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage: ParameterValues.PerPage
        ]
        taskForGETMethod(parameters) {
            (results, error) in
            guard (error == nil) else {
                completionHandlerForGetImages(result: nil, error: "Unable to download data")
                return
            }
            guard let photosDictionary = results[ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForGetImages(result: nil, error: "Cannot find keys '\(ResponseKeys.Photos)' in \(results)")
                return
            }
            guard let photos = photosDictionary[ResponseKeys.PhotoList] as? [[String:AnyObject]] else {
                completionHandlerForGetImages(result: nil, error: "Cannot find keys '\(ResponseKeys.PhotoList)' in \(photosDictionary)")
                return
            }
            completionHandlerForGetImages(result: photos, error: nil)
        }
        
    }
    
    func getImageFromURL(imageUrlString: String, completionHandlerForGetImageFromURL: (result: AnyObject?, error: String?)->Void) {
        let imageURL = NSURL(string: imageUrlString)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            completionHandlerForGetImageFromURL(result: imageData, error: nil)
        }
        else {
            completionHandlerForGetImageFromURL(result: nil, error: "Image does not exist at \(imageURL)")
        }
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        
    }
}