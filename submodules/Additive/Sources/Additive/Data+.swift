//
// Data+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import ImageIO

public extension Data {
    /// A converter extension that converts data to string with UTF-8.
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }

    var utf8StringOrEmpty: String {
        utf8String ?? ""
    }

    /// 50% faster than normal UIImage resizing.
    /// It only steram small amount of data to memory and it will result to smaller bytes feed to memory.
    /// This also leads to less dirty Pages in memory.
    func imageScale(width: Int) -> (image: CGImage, properties: [String: Any]?)? {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else { return nil }
        let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
        let opt: [NSString: Any] = [kCGImageSourceThumbnailMaxPixelSize: width, kCGImageSourceCreateThumbnailFromImageAlways: true]
        guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, opt as CFDictionary) else { return nil }
        return (scaledImage, properties as? [String: Any])
    }
}
