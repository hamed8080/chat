//
// AsyncGlobalActor.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

@globalActor public actor AsyncGlobalActor: GlobalActor {
    public static let shared = AsyncGlobalActor()
}
