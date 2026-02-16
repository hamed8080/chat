//
// Logger.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import CoreData
import Foundation
#if canImport(OSLog)
import OSLog
#endif

public final class Logger: @unchecked Sendable {
    public weak var delegate: LogDelegate?
    internal var config: LoggerConfig
    private var timer: TimerProtocol
    private var urlSession: URLSessionProtocol
    internal let persistentManager = PersistentManager()
    
    /// Persistent manager only for all logs.
    nonisolated(unsafe) private static var pms: [String: PersistentManager] = [:]

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
#if canImport(OSLog)
        if config.isDebuggingLogEnabled {
            if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                let logger = os.Logger(subsystem: config.prefix, category: config.prefix)
                logger.info("\(message)")
            }
        }
#endif
        /// Persist it in CDLog entity, whether send it to the server or not.
        if persist {
            addLogToCache(log)
            
            /// We don't send new request if there is an active timer or valid timer.
            if config.persistLogsOnServer, !timer.isValid {
                startSending()
            }
        }
    }

    private func startSending() {
        if config.persistLogsOnServer == false { return }
        timer.scheduledTimer(interval: config.sendLogInterval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                await self.onSendingTimer()
            }
        }
    }
    
    private func onSendingTimer() async {
        if let bgTask = self.persistentManager.newBgTask, timer.isValid {
            if let log = await getFirstLog(bgTask: bgTask)?.log {
                await sendToLogServer(log: log, context: bgTask)
            } else {
                timer.invalidateTimer()
            }
        }
    }
    
    private func getFirstLog(bgTask: NSManagedObjectContext) async -> CDLogSendableWrapper? {
        await withCheckedContinuation { continuation in
            CDLog.firstLog(self, bgTask) { log in
                continuation.resume(with: .success(CDLogSendableWrapper(log: log)))
            }
        }
    }

    private func sendToLogServer(log: CDLog, context: NSManagedObjectContext) async {
        let sendable = context.sendable
        guard let url = URL(string: config.spec.server.log) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = config.logServerMethod
        req.httpBody = try? JSONEncoder().encode(log.codable)
        req.allHTTPHeaderFields = config.logServerRequestheaders
        do {
            let (_, response) = try await urlSession.data(req)
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
        Task { @MainActor [weak self] in
            guard let self = self else { return }
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
    
    public class func allLogs(completion: @escaping ([Log]) -> Void) {
        let uniqueId = UUID().uuidString
        let pm = PersistentManager(autoLoadContainer: false)
        pms[uniqueId] = pm
        try? pm.loadContainer { _ in
            guard let context = pm.context else { return }
            CDLog.logs(context) { logs in
                completion(logs)
                pms.removeValue(forKey: uniqueId)
            }
        }
    }
    
    public static func allLogs(fromTime: Date, completion: @escaping ([Log]) -> Void) {
        let uniqueId = UUID().uuidString
        let pm = PersistentManager(autoLoadContainer: false)
        pms[uniqueId] = pm
        try? pm.loadContainer { _ in
            guard let context = pm.context else { return }
            CDLog.allLogs(fromTime, context) { logs in
                completion(logs)
                pms.removeValue(forKey: uniqueId)
            }
        }
    }
}

public struct CDLogSendableWrapper: Sendable {
    public let log: CDLog?
}
