# Managing Files
You could manage download and upload and so more in terms of working with files.


### Get a File
To get a file from the cache or download it directly from the server. If you want to get a file from the cache just set ``FileRequest/forceToDownloadFromServer`` to false to search through a cache and if it has contained it, it will immediately back the file else it will download the file from the server. Call method ``Chat/FileProtocol/get(_:)-9ru7k`` like this:
```swift
let req = FileRequest(hashCode: "XYZ...", checkUserGroupAccess: false, forceToDownloadFromServer: true)
ChatManager.activeInstance?.file.get(req)
```

### Get an Image
To get an image from the cache or download it directly from the server. If you want to get an image from the cache just set ``FileRequest/forceToDownloadFromServer`` to false to search through a cache and if it has contained it, it will immediately back the image else it will download the image from the server. Call method ``Chat/FileProtocol/get(_:)-4v4sz`` like this:

>Tip: You could set the ideal size of an image you wish to receive inside the initializer of ``ImageRequest``.

```swift
let req = ImageRequest(hashCode: "XYZ...")
ChatManager.activeInstance?.file.get(req)
```

### Upload a file
To upload a file to server use ``UploadFileRequest/userGroupHash`` if you want to send it inside a thread. Please visit all properties that you could manage for uploading a file in class ``UploadFileRequest``. Call method ``Chat/FileProtocol/upload(_:)-1sy1h`` like this:

```swift
let req = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
ChatManager.activeInstance?.file.upload(req)
```

### Upload an image
To upload an image to server use ``UploadFileRequest/userGroupHash`` if you want to send it inside a thread. Please visit all properties that you could manage for uploading an image in class ``UploadFileRequest``. Call method ``Chat/FileProtocol/upload(_:)-7rq44`` like this:

```swift
let req = UploadFileRequest(data: imageData, fileName: "test.png", mimeType: "image/png" , userGroupHash: "XYZ....")
ChatManager.activeInstance?.file.upload(req)
```

### Managing a upload
To ``DownloaUploadAction/suspend``, ``DownloaUploadAction/resume`` and comletely ``DownloaUploadAction/cancel`` a file which is uploading right now use the method ``Chat/FileProtocol/manageUpload(uniqueId:action:)`` like this:
>Tip: To distinguish between a file or image set `isImage` on this funcion
```swift
ChatManager.activeInstance?.file.manageUpload(uniqueId: "XYZ...": action: .resume, isImage: false)
```

### Managing a download
To ``DownloaUploadAction/suspend``, ``DownloaUploadAction/resume`` and comletely ``DownloaUploadAction/cancel`` a file which is downloading right now use the method ``Chat/FileProtocol/manageDownload(uniqueId:action:)`` like this:
>Tip: To distinguish between a file or image set `isImage` on this funcion
```swift
ChatManager.activeInstance?.file.manageDownload(uniqueId: "XYZ...": action: .resume, isImage: false)
```
