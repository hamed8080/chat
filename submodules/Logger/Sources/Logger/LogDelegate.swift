//
// LogDelegate.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

public protocol LogDelegate: AnyObject {
    func onLog(log: Log)
}
