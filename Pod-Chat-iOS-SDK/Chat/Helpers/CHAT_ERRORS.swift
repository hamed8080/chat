//
//  CHAT_ERRORS.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum CHAT_ERRORS: String {
    
    // Socket Errors
    case err6000 = "No Active Device found for this Token!"
    case err6001 = "Invalid Token!"
    case err6002 = "User not found!"
    
    // Get User Info Errors
    case err6100 = "Cant get UserInfo!"
    case err6101 = "Getting User Info Retry Count exceeded 5 times; Connection Can Not Estabilish!"
    
    // Http Request Errors
    case err6200 = "Network Error"
    case err6201 = "URL is not clarified!"
    
    // File Uploads Errors
    case err6300 = "Error in uploading File!"
    case err6301 = "Not an image!"
    case err6302 = "No file has been selected!"
    
    // Map Errors
    case err6700 = "You should Enter a Center Location like {lat: \" \", lng: \" \"}"
    
    
    
}


