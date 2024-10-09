//
// LoggerError.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

enum LoggerError: String, Error {
    case momdFile = "Couldn't find momd file in bundle."
    case modelFile = "The content is not a NSManagedObjectModel."
    case persistentStore = "The persistent store is nil."
}
