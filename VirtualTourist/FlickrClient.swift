//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Gareth Hunt on 11/06/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {

    var session = NSURLSession.sharedSession()
    static let sharedInstance = FlickrClient()
    
    override init() {
        super.init()
    }
    
    private func createRequest(methodType: String, methodURL: String, parameters: [String:AnyObject], jsonData: String?) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: FlickrClient.urlFromParameters(parameters, withPathExtension: methodURL))
        request.HTTPMethod = methodType
        if jsonData != nil {
            request.HTTPBody = jsonData!.dataUsingEncoding(NSUTF8StringEncoding)
        }
        return request
    }
    
    private func createTask(request: NSMutableURLRequest, completionHandlerForTask: (results: AnyObject!, error: NSError?)-> Void) ->NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            guard (error == nil) else {
                self.sendError("There was an error with your request \(error)", errorDomain: "errorConnecting", completionHandlerForError: completionHandlerForTask)
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.sendError("Your request returned a status code other than 2xx!", errorDomain: "invalidStatusCode", completionHandlerForError: completionHandlerForTask)
                return
            }
            guard let data = data else {
                self.sendError("No data was returned by the request!", errorDomain: "invalidData", completionHandlerForError: completionHandlerForTask)
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForTask)
        }
        task.resume()
        return task
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            self.sendError("Could not parse the data as JSON: '\(data)'", errorDomain: "convertDataWithCompletionHandler", completionHandlerForError: completionHandlerForConvertData)
        }
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    class func urlFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    //Send error -> creates NSError Message
    private func sendError(errorMessage: String, errorDomain: String, completionHandlerForError: (result: AnyObject!, error: NSError?) ->Void) {
        let userInfo = [NSLocalizedDescriptionKey: errorMessage,
            NSLocalizedFailureReasonErrorKey: errorDomain
        ]
        completionHandlerForError(result: nil, error: NSError(domain: errorDomain, code:1, userInfo: userInfo))
    }
    
    //GET Method
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (results: AnyObject!, error: NSError?)->Void) -> NSURLSessionDataTask {
        
        let request = createRequest("GET", methodURL: "", parameters: parameters, jsonData: nil)
        return createTask(request, completionHandlerForTask: completionHandlerForGET)
    }
}