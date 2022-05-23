//
//  ProgressImplementation.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/1/21.
//

import Foundation
class ProgressImplementation : NSObject ,URLSessionDataDelegate , URLSessionTaskDelegate{
    
    private let uploadProgress   :UploadFileProgressType?
    private let downloadProgress :DownloadProgressType?
    
    
    private var buffer   : NSMutableData = NSMutableData()
    private var downloadCompletion:((Data?,HTTPURLResponse?,Error?)->())? = nil
    private var downloadFileProgress = DownloadFileProgress(percent: 0, totalSize: 0, bytesRecivied: 0)
    private var response:HTTPURLResponse?
    private var uniqueId:String
    
    private var delegate:ChatDelegate?{
        return Chat.sharedInstance.delegate
    }
    
    init(uniqueId:String, uploadProgress:UploadFileProgressType? = nil , downloadProgress:DownloadProgressType? = nil ,downloadCompletion:((Data?,HTTPURLResponse?,Error?)->())? = nil){
        self.uniqueId           = uniqueId
        self.uploadProgress     = uploadProgress
        self.downloadProgress   = downloadProgress
        self.downloadCompletion = downloadCompletion
    }

    //MARK:- Upload progress Delegates
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let percent = ( Float(totalBytesSent) / Float(totalBytesExpectedToSend) ) * 100
        Chat.sharedInstance.logger?.log(title: "Upload progress:\(percent)")
        uploadProgress?(UploadFileProgress(percent: Int64(percent), totalSize: totalBytesExpectedToSend, bytesSend: totalBytesSent),nil)
        delegate?.chatEvent(event: .File(.UPLOADING(uniqueId: uniqueId)))
    }
    //MARK:- END Upload progress Delegates
    
    //MARK:- Download progress Delegates
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void){
        self.response = response as? HTTPURLResponse
        downloadFileProgress.totalSize = response.expectedContentLength
        downloadProgress?(downloadFileProgress)
        Chat.sharedInstance.logger?.log(title: "Download progress:\(downloadFileProgress.percent)")
        completionHandler(.allow)
        delegate?.chatEvent(event: .File(.DOWNLOADING(uniqueId: uniqueId)))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        let percentageDownloaded:Double
        if downloadFileProgress.totalSize == -1{
            percentageDownloaded = 0
        }else{
            percentageDownloaded = Double(buffer.count) / Double(downloadFileProgress.totalSize)
        }
        downloadFileProgress.bytesRecivied = Int64(buffer.count)
        downloadFileProgress.percent = Int64(percentageDownloaded * 100)
        downloadProgress?(downloadFileProgress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        guard let url = response?.url else {return}
        let headers = response?.allHeaderFields as? [String:String] ?? [:]
        let resultResponse = HTTPURLResponse(url: url, statusCode: error == nil ? 200 : 400 , httpVersion: "HTTP/1.1" , headerFields: headers)
        downloadCompletion?(buffer as Data, resultResponse, error)
    }
    //MARK:- END Download progress Delegates
}
