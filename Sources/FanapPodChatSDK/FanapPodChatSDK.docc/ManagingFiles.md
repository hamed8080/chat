# Managing Files
You could manage download and upload and so more in terms of working with files.


### Get A File

To get a file from the cache or download it directly from the server. If you want to get a file from the cache just set ``FileRequest/forceToDownloadFromServer`` to false to search through a cache and if it has contained it, it will immediately back the file else it will download the file from the server. Call method ``Chat/getFile(req:downloadProgress:completion:cacheResponse:uniqueIdResult:)`` like this:
```swift
let req = FileRequest(hashCode: "XYZ...", checkUserGroupAccess: false, forceToDownloadFromServer: true)
Chat.sharedInstance.getFile(req: req) { downloadProgress in
    // Write your code
} completion: { data, fileModel, error in
    // Write your code
} cacheResponse: { data, fileModel, error in
    // Write your code
} uniqueIdResult: { uniqueId in
    // Write your code
}
```


### Get An Image

To get an image from the cache or download it directly from the server. If you want to get an image from the cache just set ``FileRequest/forceToDownloadFromServer`` to false to search through a cache and if it has contained it, it will immediately back the image else it will download the image from the server. Call method ``Chat/getImage(req:downloadProgress:completion:cacheResponse:uniqueIdResult:)`` like this:

>Tip: You could set the ideal size of an image you wish to receive inside the initializer of ``ImageRequest``.

```swift
let req = ImageRequest(hashCode: "XYZ...")
Chat.sharedInstance.getImage(req: req) { downloadProgress in
    // Write your code
} completion: { data, imageModel, error in
    // Write your code
} cacheResponse: { data, imageModel, error in
    // Write your code
} uniqueIdResult: { uniqueId in
    // Write your code
}
```


### Upload a file

To upload a file to server use ``UploadFileRequest/userGroupHash`` if you want to send it inside a thread. Please visit all properties that you could manage for uploading a file in class ``UploadFileRequest``. Call method ``Chat/uploadFile(req:uploadUniqueIdResult:uploadProgress:uploadCompletion:)`` like this:

```swift
let req = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
Chat.sharedInstance.uploadFile(req: req) { uploadProgress, error in
    // Write your code
} uploadCompletion: { uploadFileResponse, fileMetaData, error in
    // Write your code
}
```

### Upload an image

To upload an image to server use ``UploadFileRequest/userGroupHash`` if you want to send it inside a thread. Please visit all properties that you could manage for uploading an image in class ``UploadFileRequest``. Call method ``Chat/uploadImage(req:uploadUniqueIdResult:uploadProgress:uploadCompletion:)`` like this:

```swift
let req = UploadFileRequest(data: imageData, fileName: "test.png", mimeType: "image/png" , userGroupHash: "XYZ....")
Chat.sharedInstance.uploadImage(req: req) { uploadProgress, error in
    // Write your code
} uploadCompletion: { uploadImageResponse, fileMetaData, error in
    // Write your code
}
```

### Reply with file

To reply to a message with uploading a file use the method ``Chat/replyFileMessage(replyMessage:uploadFile:uploadProgress:onSent:onSeen:onDeliver:uploadUniqueIdResult:messageUniqueIdResult:)`` like this:

```swift
let replyMsg = ReplyMessageRequest(threadId: 123456, repliedTo: 567890, textMessage: "Use This File", messageType: .POD_SPACE_FILE)
let uploadFile = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
Chat.sharedInstance.replyFileMessage(replyMessage: replyMsg, uploadFile: uploadFile) { uploadProgress, error in
    // Write your code
}
```


### Send a file message

To send a new message with uploading a file use the method ``Chat/sendFileMessage(textMessage:uploadFile:uploadProgress:onSent:onSeen:onDeliver:uploadUniqueIdResult:messageUniqueIdResult:)`` like this:

```swift
let replyMsg = SendTextMessageRequest(threadId: 123456, textMessage: "Use This File", messageType: .POD_SPACE_FILE)
let uploadFile = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
Chat.sharedInstance.sendFileMessage(replyMessage: replyMsg, uploadFile: uploadFile) { uploadProgress, error in
    // Write your code
}
```

### Send an image message
To send a new image message use the method ``Chat/sendFileMessage(textMessage:uploadFile:uploadProgress:onSent:onSeen:onDeliver:uploadUniqueIdResult:messageUniqueIdResult:)`` like this:
```swift
let message = SendTextMessageRequest(threadId: threadId, textMessage: "Test text", messageType: .POD_SPACE_PICTURE)
let imageRequest = UploadImageRequest(data: imaageData, hC: height, wC: width , fileName: "Test.png", mimeType: "image/png" , userGroupHash: "XYZ..." )
Chat.sharedInstance.sendFileMessage(textMessage: message, uploadFile: imageRequest){ uploadFileProgress, error in
    // Write your code
}
```

### Managing a upload
To ``DownloaUploadAction/suspend``, ``DownloaUploadAction/resume`` and comletely ``DownloaUploadAction/cancel`` a file which is uploading right now use the method ``Chat/manageUpload(uniqueId:action:isImage:completion:)`` like this:
>Tip: To distinguish between a file or image set `isImage` on this funcion
```swift
Chat.sharedInstance.manageUpload(uniqueId: "XYZ...": action: .resume, isImage: false){ stringResult, completed in
    // Write your code
}
```

### Managing a download
To ``DownloaUploadAction/suspend``, ``DownloaUploadAction/resume`` and comletely ``DownloaUploadAction/cancel`` a file which is downloading right now use the method ``Chat/manageDownload(uniqueId:action:isImage:completion:)`` like this:
>Tip: To distinguish between a file or image set `isImage` on this funcion
```swift
Chat.sharedInstance.manageDownload(uniqueId: "XYZ...": action: .resume, isImage: false){ stringResult, completed in
    // Write your code
}
```
