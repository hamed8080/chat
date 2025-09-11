//
// CallState.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import ChatDTO

public struct CurrentCall {
    public var call: CreateCall?
    
    /// It will be set to true if I accept or start a call on this device.
    public var initOnThisDevice: Bool
    
    public var requestedCallUniqueId: String?
    
    public init(call: CreateCall? = nil, initOnThisDevice: Bool = false) {
        self.call = call
        self.initOnThisDevice = initOnThisDevice
    }
    
    public mutating func reset() {
        call = nil
        initOnThisDevice = false
        requestedCallUniqueId = nil
    }
    
    public mutating func resetIfNeeded(_ request: GeneralSubjectIdRequest) {
        if request.subjectId == call?.callId {
            reset()
        }
    }
    
    public mutating func resetIfNeededOnCallEnded(callId: Int?) {
        if let callId = callId, call?.callId == callId {
            reset()
        }
    }
}

