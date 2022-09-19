//
//  ChatDelegate.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation


public enum Routes: String {
    
    // Devices:
    case SSO_DEVICES                    = "/oauth2/grants/devices"
    case SSO_GENERATE_KEY               = "/handshake/users/"
    case SSO_GET_KEY                    = "/handshake/keys/"
    
    // Contacts:
    case ADD_CONTACTS                   = "/nzh/addContacts"
    case UPDATE_CONTACTS                = "/nzh/updateContacts"
    case REMOVE_CONTACTS                = "/nzh/removeContacts"
    case SEARCH_CONTACTS                = "/nzh/listContacts"
    
    // File/Image Upload and Download
    case UPLOAD_IMAGE                   = "/nzh/uploadImage"
    case GET_IMAGE                      = "/nzh/image/"
    case UPLOAD_FILE                    = "/nzh/uploadFile"
    case GET_FILE                       = "/nzh/file/"
    
    // PodDrive
    case DRIVE_UPLOAD_FILE_FROM_URL     = "/nzh/drive/uploadFileFromUrl"
    case DRIVE_DOWNLOAD_FILE            = "/nzh/drive/downloadFile"
    case DRIVE_DOWNLOAD_IMAGE           = "/nzh/drive/downloadImage"
    
    // PodSpace
    case PODSPACE_UPLOAD_FILE           = "/nzh/drive/uploadFile"
    case PODSPACE_PUBLIC_UPLOAD_FILE    = "/userGroup/uploadFile"
    case PODSPACE_UPLOAD_IMAGE          = "/nzh/drive/uploadImage"
    case PODSPACE_PUBLIC_UPLOAD_IMAGE   = "/userGroup/uploadImage"
    
    //To Thread withUserGrouphash
    case UPLOAD_FILE_WITH_USER_GROUP    = "/api/usergroups/{userGroupHash}/files"
    case UPLOAD_IMAGE_WITH_USER_GROUP   = "/api/usergroups/{userGroupHash}/images"
    
    //Public
    case FILES                          = "/api/files"
    case IMAGES                         = "/api/images"
    
    // Neshan Map
    case MAP_REVERSE                    = "/reverse"
    case MAP_SEARCH                     = "/search"
    case MAP_ROUTING                    = "/routing"
    case MAP_STATIC_IMAGE               = "/static"
    
}


