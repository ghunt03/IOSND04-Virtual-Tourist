//
//  FlickrConvience.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 11/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
import CoreData
import UIKit
extension FlickrClient {
    
    func getPages(location: Pin, context: NSManagedObjectContext, completionHandlerForGetPages: (result: AnyObject?, error:String?) -> Void) {
        // Retrieve number of pages available for the location
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
                completionHandlerForGetPages(result: nil, error: "Unable to download data")
                return
            }
            guard let photosDictionary = results[ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForGetPages(result: nil, error: "Cannot find keys '\(ResponseKeys.Photos)' in \(results)")
                return
            }
            
            let pages = photosDictionary["pages"] as! Int
            
            //limit to 40 pages due to flickr Limitations
            let pageLimit = min(pages, Constants.MaxPages)
            location.pages = pageLimit
            completionHandlerForGetPages(result: pages, error: nil)
        }
    }
    
    
    func getImages(location: Pin, context: NSManagedObjectContext, completionHandlerForGetImages: (result: AnyObject?, error: String?)->Void) {
        
        let parameters = [
            ParameterKeys.Method: ParameterValues.SearchMethod,
            ParameterKeys.APIKey: ParameterValues.APIKey,
            ParameterKeys.BoundingBox: bboxString(Double(location.latitude!), longitude: Double(location.longitude!)),
            ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch,
            ParameterKeys.Extras: ParameterValues.MediumURL,
            ParameterKeys.Format: ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage: ParameterValues.PerPage,
            ParameterKeys.Page: "\(getRandomPageNumber(location.pages!))"
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
            

            for photoDictionary in photos {
                let p = Photo(id: photoDictionary[ResponseKeys.Id] as! String,
                    photoURL: photoDictionary[ResponseKeys.ImageUrl] as! String,
                    title: photoDictionary[ResponseKeys.Title] as! String,
                    context: context)
                p.pin = location
                self.getImageFromURL(p) {
                    (result, error) in
                }
            }
            
            
            completionHandlerForGetImages(result: true, error: nil)
        }
        
    }
    
   
    
    func getImageFromURL(photo: Photo, completionHandlerForGetImageFromURL: (result: AnyObject?, error: String?)->Void) {
        // retrieve image based on url
        taskForGETImageMethod(photo.url!) {
            (results, error) in
            if (error == nil) {
                photo.photoData = results
                completionHandlerForGetImageFromURL(result: "Image downloaded from \(photo.url)", error: nil)
            }
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
    
    private func getRandomPageNumber(pages: NSNumber) -> UInt32 {
        // select a random page number
        let randomPage = arc4random_uniform(UInt32(pages.integerValue)) + 1
        return randomPage
    }
    

}