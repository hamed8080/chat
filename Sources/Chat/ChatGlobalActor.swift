//
// ChatGlobalActor.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

@globalActor public actor ChatGlobalActor: GlobalActor {
    public static let shared = ChatGlobalActor()
}

