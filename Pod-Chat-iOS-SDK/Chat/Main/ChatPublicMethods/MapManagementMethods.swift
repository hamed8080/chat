//
//  MapManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON
import Alamofire


// MARK: - Public Methods -
// MARK: - Map Management

extension Chat {
    
    /// MapRevers:
    /// get location details from client location.
    ///
    /// By calling this function, HTTP request of type (REVERSE to the MAP_ADDRESS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MapReverseRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter mapReverseInput:    (input) you have to send your parameters insid this model. (MapReverseRequestModel)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! MapReverseModel)
    public func mapReverse(mapReverseInput: MapReverseRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.REVERSE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key":   mapApiKey]
        let parameters: Parameters  = ["lat":       mapReverseInput.lat,
                                       "lng":       mapReverseInput.lng,
                                       "uniqueId":  theUniqueId]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  parameters)
        { (jsonResponse) in
            if let theResponse = jsonResponse as? JSON {
                let mapReverseModel = MapReverseModel(messageContent:   theResponse,
                                                      hasError:         false,
                                                      errorMessage:     "",
                                                      errorCode:        0)
                completion(mapReverseModel)
            }
        }
        
    }
    
    
    /// MapSearch:
    /// search near thing inside the map, whoes where close to the client location.
    ///
    /// By calling this function, HTTP request of type (SEARCH to the MAP_ADDRESS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MapSearchRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter mapSearchInput: (input) you have to send your parameters insid this model. (MapSearchRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! MapSearchModel)
    public func mapSearch(mapSearchInput:   MapSearchRequestModel,
                          uniqueId:         @escaping (String) -> (),
                          completion:       @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.SEARCH.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key": mapApiKey]
        let parameters: Parameters  = ["lat":   mapSearchInput.lat,
                                       "lng":   mapSearchInput.lng,
                                       "term":  mapSearchInput.term]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  parameters)
        { (jsonResponse) in
            if let theResponse = jsonResponse as? JSON {
                let mapSearchModel = MapSearchModel(messageContent: theResponse,
                                                    hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0)
                completion(mapSearchModel)
            }
        }
        
    }
    
    
    /// MapRouting:
    /// send 2 locations, and then give routing suggesston.
    ///
    /// By calling this function, HTTP request of type (SEARCH to the MAP_ADDRESS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MapRoutingRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter mapRoutingInput:    (input) you have to send your parameters insid this model. (MapRoutingRequestModel)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! MapRoutingModel)
    public func mapRouting(mapRoutingInput: MapRoutingRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.ROUTING.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key": mapApiKey]
        let parameters: Parameters  = ["origin":        "\(mapRoutingInput.originLat),\(mapRoutingInput.originLng)",
                                       "destination":   "\(mapRoutingInput.destinationLat),\(mapRoutingInput.destinationLng)",
                                       "alternative":   mapRoutingInput.alternative]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  parameters)
        { (jsonResponse) in
            if let theResponse = jsonResponse as? JSON {
                let mapRoutingModel = MapRoutingModel(messageContent:   theResponse,
                                                      hasError:         false,
                                                      errorMessage:     "",
                                                      errorCode:        0)
                completion(mapRoutingModel)
            }
        }
        
    }
    
    
    /// MapStaticImage:
    /// get a static image from the map based on the location that user wants.
    ///
    /// By calling this function, HTTP request of type (STATIC_IMAGE to the MAP_ADDRESS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MapStaticImageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter mapStaticImageInput:    (input) you have to send your parameters insid this model. (MapStaticImageRequestModel)
    /// - parameter uniqueId:               (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter progress:               (response)  it will returns the progress of the downloading request by a value between 0 and 1. (Float)
    /// - parameter completion:             (response) it will returns the response that comes from server to this request. (Any as! Data)
    public func mapStaticImage(mapStaticImageInput: MapStaticImageRequestModel,
                               uniqueId:            @escaping (String) -> (),
                               progress:            @escaping (Float) -> (),
                               completion:          @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.STATIC_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let parameters: Parameters  = ["key":       mapApiKey,
                                       "type":      mapStaticImageInput.type,
                                       "zoom":      mapStaticImageInput.zoom,
                                       "center":    "\(mapStaticImageInput.centerLat),\(mapStaticImageInput.centerLng)",
                                       "width":     mapStaticImageInput.width,
                                       "height":    mapStaticImageInput.height]
        
        Networking.sharedInstance.download(toUrl: url,
                                           withMethod: method,
                                           withHeaders: nil,
                                           withParameters: parameters,
                                           progress: { (downloadProgress) in
                                            progress(downloadProgress)
        }) { (myResponse, jsonResponse) in
            guard let image = myResponse else { print("Value is empty!!!"); return }
            completion(image)
        }
        
    }
    
    
    
}
