//
// Logger.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import CoreData
import Foundation

public final class Logger: @unchecked Sendable {
    public weak var delegate: LogDelegate?
    internal var config: LoggerConfig
    private var timer: TimerProtocol
    private var urlSession: URLSessionProtocol
    internal let persistentManager = PersistentManager()

    public init(config: LoggerConfig, delegate: LogDelegate? = nil, timer: TimerProtocol = Timer(), urlSession: URLSessionProtocol = URLSession.shared) {
        self.config = config
        self.delegate = delegate
        self.timer = timer
        self.urlSession = urlSession
        startSending()
    }

    public func logJSON(title: String = "", jsonString: String = "", persist: Bool, type: LogEmitter, userInfo: [String: String]? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            createLog(message: "\(config.prefix): \(title)\(jsonString != "" ? "\n" : "")\(jsonString.prettyJsonString())", persist: persist, type: type, userInfo: userInfo)
        }
    }

    public func log(title: String = "", message: String = "", persist: Bool, type: LogEmitter, userInfo: [String: String]? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            createLog(message: "\(config.prefix): \(title)\(message != "" ? "\n" : "")\(message)", persist: persist, type: type, userInfo: userInfo)
        }
    }

    public func logHTTPRequest(_ request: URLRequest, _ decodeType: String, persist: Bool, type: LogEmitter, userInfo: [String: String]? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            var output = "Start Of Request====\n"
            output += " REST Request With Method:\(request.method.rawValue) - url:\(request.url?.absoluteString ?? "")\n"
            output += " With Headers:\(request.allHTTPHeaderFields?.debugDescription ?? "[]")\n"
            output += " With HttpBody:\(request.httpBody?.string ?? "nil")\n"
            output += " Expected DecodeType:\(decodeType)\n"
            output += "End Of Request====\n"
            output += "\n"
            log(message: output, persist: persist, type: type, userInfo: userInfo)
        }
    }

    public func logHTTPResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?, persist: Bool, type: LogEmitter, userInfo: [String: String]? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            var output = "Start Of Response====\n"
            output += " REST Response For url:\(response?.url?.absoluteString ?? "")\n"
            output += " With Data Result in Body:\(data?.utf8String ?? "nil")\n"
            output += "End Of Response====\n"
            output += "\n"
            output += "Error:\(error?.localizedDescription ?? "nil")"
            if error != nil {
                let output = "\(config.prefix): \n\(output)"
                createLog(message: output, persist: persist, level: .error, type: type, userInfo: userInfo)
            } else {
                log(message: output, persist: persist, type: type, userInfo: userInfo)
            }
        }
    }

    public func createLog(message: String, persist: Bool, level: LogLevel = .verbose, type: LogEmitter, userInfo: [String: String]? = nil) {
        let log = Log(
            prefix: config.prefix,
            message: message,
            level: level,
            type: type,
            userInfo: userInfo
        )
        delegate?.onLog(log: log)
        if persist, config.persistLogsOnServer {
            addLogToCache(log)
            if !timer.isValid {
                startSending()
            }
        }
    }

    private func startSending() {
        if config.persistLogsOnServer == false { return }
        timer.scheduledTimer(interval: config.sendLogInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.onSendingTimer()
            }
        }
    }
    
    private func onSendingTimer() async {
        if let bgTask = self.persistentManager.newBgTask, timer.isValid {
            let log = await CDLog.firstLog(self, bgTask)
            if let log = log {
                await sendLog(log: log, context: bgTask)
            } else {
                timer.invalidateTimer()
            }
        }
    }

    private func sendLog(log: CDLog, context: NSManagedObjectContext) async {
        let sendable = context.sendable
        guard let url = URL(string: config.spec.server.log) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = config.logServerMethod
        req.httpBody = try? JSONEncoder().encode(log.codable)
        req.allHTTPHeaderFields = config.logServerRequestheaders
        do {
            let (data, response) = await try urlSession.data(req)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                deleteLogFromCache(log: log, context: sendable.context)
            }
        } catch {
#if DEBUG
            print("error to send log \(error)")
#endif            
        }
    }

    private func deleteLogFromCache(log: CDLog, context: NSManagedObjectContext) {
        let sendable = context.sendable
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            CDLog.delete(logger: self, context: sendable.context, logs: [log])
        }
    }

    
    private func addLogToCache(_ log: Log) {
        Task { @MainActor in
            guard let context = persistentManager.context else { return }
            CDLog.insert(self, context, [log])
        }
    }

    public class func clear(prefix: String, completion: (() -> Void)? = nil) {
        CDLog.clear(prefix: prefix, completion: completion)
    }

    public func dispose() {
        timer.invalidateTimer()
    }
}
