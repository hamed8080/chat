//
//  ServiceAddresses.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
public struct SERVICE_ADDRESSES_ENUM {
    public var SSO_ADDRESS          = "http://172.16.110.76"
    public var PLATFORM_ADDRESS     = "http://172.16.106.26:8080/hamsam"
    public var FILESERVER_ADDRESS   = "http://172.16.106.26:8080/hamsam"
    public var PODSPACE_FILESERVER_ADDRESS = "https://podspace.pod.ir"
    public var MAP_ADDRESS          = "https://api.neshan.org/v1"
    
//    public func stringValue() -> String {
//        switch self {
//        case .SSO_ADDRESS:          return "http://172.16.110.76"
//        case .PLATFORM_ADDRESS:     return "http://172.16.106.26:8080/hamsam"
//        case .FILESERVER_ADDRESS:   return "http://172.16.106.26:8080/hamsam"
//        case .MAP_ADDRESS:          return "https://api.neshan.org/v1"
//        }
//    }
    
}

public enum SERVICES_PATH: String {
    
    // Devices:
    case SSO_DEVICES        = "/oauth2/grants/devices"
    case SSO_GENERATE_KEY   = "/handshake/users/"
    case SSO_GET_KEY        = "/handshake/keys/"
    
    // Contacts:
    case ADD_CONTACTS       = "/nzh/addContacts"
    case UPDATE_CONTACTS    = "/nzh/updateContacts"
    case REMOVE_CONTACTS    = "/nzh/removeContacts"
    case SEARCH_CONTACTS    = "/nzh/listContacts"
    
    // File/Image Upload and Download
    case UPLOAD_IMAGE       = "/nzh/uploadImage"
    case GET_IMAGE          = "/nzh/image/"
    case UPLOAD_FILE        = "/nzh/uploadFile"
    case GET_FILE           = "/nzh/file/"
    
    // PodDrive
//    case DRIVE_UPLOAD_FILE          = "/nzh/drive/uploadFile"
    case DRIVE_UPLOAD_FILE_FROM_URL = "/nzh/drive/uploadFileFromUrl"
//    case DRIVE_UPLOAD_IMAGE         = "/nzh/drive/uploadImage"
    case DRIVE_DOWNLOAD_FILE        = "/nzh/drive/downloadFile"
    case DRIVE_DOWNLOAD_IMAGE       = "/nzh/drive/downloadImage"
    
    // PodSpace
    case PODSPACE_UPLOAD_FILE           = "/nzh/drive/uploadFile"
    case PODSPACE_PUBLIC_UPLOAD_FILE    = "/userGroup/uploadFile"
    case PODSPACE_UPLOAD_IMAGE          = "/nzh/drive/uploadImage"
    case PODSPACE_PUBLIC_UPLOAD_IMAGE   = "/userGroup/uploadImage"
    
    //To Thread withUserGrouphash
    case UPLOAD_FILE_WITH_USER_GROUP   = "/api/usergroups/{userGroupHash}/files"
    case UPLOAD_IMAGE_WITH_USER_GROUP  = "/api/usergroups/{userGroupHash}/images"
    
    //Public
    case FILES         = "/api/files"
    case IMAGES        = "/api/images"
    
    // Neshan Map
    case MAP_REVERSE            = "/reverse"
    case MAP_SEARCH             = "/search"
    case MAP_ROUTING            = "/routing"
    case MAP_STATIC_IMAGE       = "/static"
    
    
    public func stringValue() -> String {
        switch self {
        
        // Devices:
        case .SSO_DEVICES:      return "/oauth2/grants/devices"
        case .SSO_GENERATE_KEY: return "/handshake/users/"
        case .SSO_GET_KEY:      return "/handshake/keys/"
        
        // Contacts:
        case .ADD_CONTACTS:     return "/nzh/addContacts"
        case .UPDATE_CONTACTS:  return "/nzh/updateContacts"
        case .REMOVE_CONTACTS:  return "/nzh/removeContacts"
        case .SEARCH_CONTACTS:  return "/nzh/listContacts"
        
        // File/Image Upload and Download
        case .UPLOAD_IMAGE: return "/nzh/uploadImage"
        case .GET_IMAGE:    return "/nzh/image/"
        case .UPLOAD_FILE:  return "/nzh/uploadFile"
        case .GET_FILE:     return "/nzh/file/"
        
        // PodDrive
//        case .DRIVE_UPLOAD_FILE:            return "/nzh/drive/uploadFile"
        case .DRIVE_UPLOAD_FILE_FROM_URL:   return "/nzh/drive/uploadFileFromUrl"
//        case .DRIVE_UPLOAD_IMAGE:           return "/nzh/drive/uploadImage"
        case .DRIVE_DOWNLOAD_FILE:          return "/nzh/drive/downloadFile"
        case .DRIVE_DOWNLOAD_IMAGE:         return "/nzh/drive/downloadImage"
        
        // PodSpace
        case .PODSPACE_UPLOAD_FILE:         return "/nzh/drive/uploadFile"
        case .PODSPACE_PUBLIC_UPLOAD_FILE:  return "/userGroup/uploadFile"
        case .PODSPACE_UPLOAD_IMAGE:        return "/nzh/drive/uploadImage"
        case .PODSPACE_PUBLIC_UPLOAD_IMAGE: return "/userGroup/uploadImage"
        
        //To Thread withUserGrouphash
        case .UPLOAD_FILE_WITH_USER_GROUP:   return "/api/usergroups/{userGroupHash}/files"
        case .UPLOAD_IMAGE_WITH_USER_GROUP:  return "/api/usergroups/{userGroupHash}/images"
            
        // PUBLIC PodSpace
        case .FILES:                 return "/api/files/"
        case .IMAGES:                return "/api/images/"
            
        // Neshan Map
        case .MAP_REVERSE:      return "/reverse"
        case .MAP_SEARCH:       return "/search"
        case .MAP_ROUTING:      return "/routing"
        case .MAP_STATIC_IMAGE: return "/static"
        }
    }
    
}


