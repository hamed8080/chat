//
// Routes.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

internal enum Routes: String {
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
    case images = "/api/images"
}
