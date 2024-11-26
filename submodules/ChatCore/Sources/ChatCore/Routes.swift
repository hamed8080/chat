//
// Routes.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum Routes: String {
    // Devices:
    case ssoDevices = "/oauth2/grants/devices"
    case ssoGenerateKey = "/handshake/users/"
    case ssoGetKey = "/handshake/keys/"

    // Contacts:
    case addContacts = "/nzh/addContacts"
    case updateContacts = "/nzh/updateContacts"
    case removeContacts = "/nzh/removeContacts"
    case searchContacts = "/nzh/listContacts"

    // File/Image Upload and Download
    case uploadImage = "/nzh/uploadImage"
    case getImage = "/nzh/image/"
    case uploadFile = "/nzh/uploadFile"
    case getFile = "/nzh/file/"

    // PodDrive
    case driveUploadFileFromUrl = "/nzh/drive/uploadFileFromUrl"
    case driveDownloadFile = "/nzh/drive/downloadFile"
    case driveDownloadImage = "/nzh/drive/downloadImage"

    // PodSpace
    case podspaceUploadFile = "/nzh/drive/uploadFile"
    case podspacePublicUploadFile = "/userGroup/uploadFile"
    case podspaceUploadImage = "/nzh/drive/uploadImage"
    case podspacePublicUploadImage = "/userGroup/uploadImage"

    // To Thread withUserGrouphash
    case uploadFileWithUserGroup = "/api/usergroups/{userGroupHash}/files"
    case uploadImageWithUserGroup = "/api/usergroups/{userGroupHash}/images"

    // Public
    case files = "/api/files"
    case images = "/api/v2/images"
    case thumbnail = "/api/files/{hashCode}/thumbnail"

    // Neshan Map
    case mapReverse = "/reverse"
    case mapSearch = "/search"
    case mapRouting = "/routing"
    case mapStaticImage = "/static"

    case baseMapLink = "https://maps.neshan.org/@"
}
