//
// NetworkAvailability.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Network

public protocol NetworkAvailabilityProtocol {
    var onNetworkChange: (@Sendable (Bool) -> Void)? { get set }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
open class NativeNetworkAvailability: NetworkAvailabilityProtocol, @unchecked Sendable {
    private var lastStatus: NWPath.Status?
    public var onNetworkChange: (@Sendable (Bool) -> Void)?
    private let path = NWPathMonitor()
    private let queue: DispatchQueueProtocol = DispatchQueue(label: "NetworkObserverQueue")

    public init() {
        path.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if lastStatus == .unsatisfied && path.status == .satisfied {
                onNetworkChange?(true)
            } else if lastStatus == .satisfied && path.status == .unsatisfied  {
                onNetworkChange?(false)
            }
            lastStatus = path.status
        }
        path.start(queue: queue as! DispatchQueue)
    }
}

open class CompatibleNetworkAvailability: NetworkAvailabilityProtocol {
    public var onNetworkChange: (@Sendable (Bool) -> Void)?

    public init() {}
}

public final class NetworkAvailabilityFactory {
    public class func create() -> NetworkAvailabilityProtocol {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            return NativeNetworkAvailability()
        } else {
            return CompatibleNetworkAvailability()
        }
    }
}
