//
// URL+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ImageIO
#if canImport(MobileCoreServices)
    import MobileCoreServices
#endif
import UniformTypeIdentifiers

public extension URL {
    /// 50% faster than normal UIImage resizing.
    /// It only steram small amount of data to memory and it will result to smaller bytes feed to memory.
    /// This also leads to less dirty Pages in memory.
    func imageScale(width: Int) -> (image: CGImage, properties: [String: Any]?)? {
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, nil) else { return nil }
        let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
        let opt: [NSString: Any] = [kCGImageSourceThumbnailMaxPixelSize: width, kCGImageSourceCreateThumbnailFromImageAlways: true]
        guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, opt as CFDictionary) else { return nil }
        return (scaledImage, properties as? [String: Any])
    }

    var fileNameWithExtension: String? {
        if fileName.isEmpty || fileExtension.isEmpty { return nil }
        return "\(fileName).\(fileExtension)"
    }

    var fileName: String {
        deletingPathExtension().lastPathComponent
    }

    var fileExtension: String {
        pathExtension.lowercased()
    }

    internal func makeQueryItems(encodable: Encodable) throws -> [URLQueryItem]? {
        let parameters = try encodable.asDictionary()
        if parameters.count > 0 {
            var queryItems = [URLQueryItem]()
            parameters.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            return queryItems
        }
        return nil
    }

    mutating func appendQueryItems(with encodable: Encodable) {
        do {
            guard let queryItems = try makeQueryItems(encodable: encodable) else { return }
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                appendQueryItemsiOS16(queryItems)
            } else {
                appendQueryItems(queryItems)
            }
        } catch {
            print("An error has happened when trying to appned query.")
        }
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    internal mutating func appendQueryItemsiOS16(_ queryItems: [URLQueryItem]) {
        append(queryItems: queryItems)
    }

    internal mutating func appendQueryItems(_ queryItems: [URLQueryItem]) {
        var urlComp = URLComponents(string: absoluteString)!
        if urlComp.queryItems == nil {
            urlComp.queryItems = []
        }
        urlComp.queryItems?.append(contentsOf: queryItems)
        if let url = urlComp.url?.absoluteString, let newURL = URL(string: url) {
            self = newURL
        }
    }

    var isMusicMimetype: Bool {
        let imageTypes = [
            "audio/mpeg",
            "audio/aac",
            "audio/ogg"
        ]
        return imageTypes.contains(mimeType)
    }
}

public extension URL {
    var mimeType: String {
        if let mimeType = ios15MimeType {
            return mimeType
        } else if let mimeType = ios14MimeType {
            return mimeType
        }
        return "application/octet-stream"
    }
    
    var ios15MimeType: String? {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *), let mimetype = UTType(filenameExtension: pathExtension)?.preferredMIMEType {
            return mimetype as String
        } else {
            return nil
        }
    }
    
    var ios14MimeType: String? {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(),
              let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() else { return nil }
        return mimetype as String
    }
    
    var isImageMimetype: Bool {
        let imageTypes = [
            "image/jpeg",
            "image/gif",
            "image/tiff",
            "image/png"
        ]
        return imageTypes.contains(mimeType)
    }
}
