import FanapPodAsyncSDK
import Sentry
import Foundation
import Alamofire
import SwiftyJSON


public struct ChatResponse{
    public var uniqueId        : String? = nil
    public var result          : Any?
    public var cacheResponse   : Any?
    public var error           : ChatError?
    public var contentCount    : Int = 0
}

public typealias CompletionTypeWithoutUniqueId<T>   = ( T? , ChatError? )->()
public typealias CompletionType<T>                  = ( T? , String? , ChatError? )->()
public typealias PaginationCompletionType<T>        = ( T? , String? , Pagination? , ChatError? )->()
public typealias CacheResponseType<T>               = ( T? , String? , ChatError? )->()
public typealias PaginationCacheResponseType<T>     = ( T? , String? , Pagination? , ChatError? )->()
public typealias UploadFileProgressType             = (UploadFileProgress? , ChatError?)->()
public typealias UploadCompletionType               = (NewUploadFileResponse? , FileMetaData? , ChatError?)->()
public typealias UniqueIdResultType                 = ( (String)->() )?
public typealias UniqueIdsResultType                = ( ([String])->() )?
public typealias UploadProgressType                 = (Float) -> ()
public typealias DownloadProgressType               = (DownloadFileProgress) -> ()
public typealias DownloadFileCompletionType         = (Data?, FileModel?  ,ChatError?)->()
public typealias DownloadImageCompletionType        = (Data?, ImageModel? ,ChatError?)->()
public typealias OnSeenType                         = ((SeenMessageResponse?    , String? , ChatError? ) -> ())?
public typealias OnDeliveryType                     = ((DeliverMessageResponse? , String? , ChatError? ) -> ())?
public typealias OnSentType                         = ((SentMessageResponse?    , String? , ChatError? ) -> ())?

//this extension merged after removed all deprecated method in Chat class
public extension Chat {
	
	//**************************** Intitializers ****************************
	func createChatObject(object:CreateChatModel){
		isCreateObjectFuncCalled = true
		createChatModel = object
        initAllOldProperties()
		initialize()
	}
    
    private func initAllOldProperties(){
        if let model = createChatModel{
            self.debuggingLogLevel                    = model.showDebuggingLogLevel
            self.captureSentryLogs                    = model.captureLogsOnSentry
            if captureSentryLogs {
                startCrashAnalytics()
            }
            
            self.socketAddress                        = model.socketAddress
            self.ssoHost                              = model.ssoHost
            self.platformHost                         = model.platformHost
            self.fileServer                           = model.fileServer
            self.serverName                           = model.serverName
            self.token                                = model.token
            self.enableCache                          = model.enableCache
            self.mapServer                            = model.mapServer
            
            cacheTimeStamp                            =  model.cacheTimeStampInSec
            if let mapApiKey                          = model.mapApiKey{
                self.mapApiKey                        = mapApiKey
            }
            
            if let typeCode                           = model.typeCode{
                self.generalTypeCode                  = typeCode
            }
            self.msgPriority                          = model.msgPriority
            self.msgTTL                               = model.msgTTL
            self.httpRequestTimeout                   = model.httpRequestTimeout
            self.actualTimingLog                      = model.actualTimingLog
            self.deviecLimitationSpaceMB              = model.deviecLimitationSpaceMB
            self.wsConnectionWaitTime                 = model.wsConnectionWaitTime
            self.connectionRetryInterval              = model.connectionRetryInterval
            self.connectionCheckTimeout               = model.connectionCheckTimeout
            self.messageTtl                           = model.messageTtl
            self.reconnectOnClose                     = model.reconnectOnClose
            self.maxReconnectTimeInterval             = model.maxReconnectTimeInterval
            
            self.SERVICE_ADDRESSES.SSO_ADDRESS        = ssoHost
            self.SERVICE_ADDRESSES.PLATFORM_ADDRESS   = platformHost
            self.SERVICE_ADDRESSES.FILESERVER_ADDRESS = fileServer
            self.SERVICE_ADDRESSES.MAP_ADDRESS        = mapServer
            
            self.localImageCustomPath                 = model.localImageCustomPath
            self.localFileCustomPath                  = model.localFileCustomPath
        }
    }
	
	func initialize(){
		if createChatModel?.captureLogsOnSentry == true {
			startCrashAnalytics()
		}
		
		if createChatModel?.getDeviceIdFromToken == false{
            DeviceIdRequestHandler.getDeviceIdAndCreateAsync(chat: self)
		}else{
			CreateAsync()
		}
		
		_ = DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: createChatModel?.deviecLimitationSpaceMB ?? 100, turnOffTheCache: true, errorDelegate: delegate)
	}
	
	func dispose() {
		stopAllChatTimers()
		asyncClient?.disposeAsyncObject()
		asyncClient = nil
		Chat.instance = nil
		print("Disposed Singleton instance")
	}
	//**************************** Intitializers ****************************
	
	func getContacts(_ request:ContactsRequest,completion:@escaping PaginationCompletionType<[Contact]>,cacheResponse:PaginationCacheResponseType<[Contact]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		GetContactsRequestHandler.handle(request,self, completion , cacheResponse , uniqueIdResult)
	}
	
	func getBlockedContacts(_ request:BlockedListRequest , completion:@escaping PaginationCompletionType<[BlockedUser]>,uniqueIdResult: UniqueIdResultType = nil){
		GetBlockedContactsRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
	func addContact(_ request:NewAddContactRequest,completion:@escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType? = nil){
        AddContactRequestHandler.handle(req: request, chat: self, completion: completion)
	}
	
//	func addContacts(_ request:[NewAddContactRequest],completion:@escaping CompletionType<[Contact]>,uniqueIdResult: UniqueIdResultType? = nil){
//		AddContactsRequestHandler.handle(req: request, chat: self, completion: completion)
//	}
	
	func contactNotSeen(_ request:NotSeenDurationRequest,completion:@escaping CompletionType<[UserLastSeenDuration]>,uniqueIdResult: UniqueIdResultType = nil){
		NotSeenContactRequestHandler.handle(request, self, completion)
	}
	
	func removeContact(_ request:NewRemoveContactsRequest,completion:@escaping CompletionType<Bool>,uniqueIdResult: UniqueIdResultType = nil){
		RemoveContactRequestHandler.handle(req: request, chat: self, completion: completion)
	}
	
	func searchContacts(_ request:ContactsRequest, completion:@escaping PaginationCompletionType<[Contact]>, cacheResponse: PaginationCacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        getContacts(request, completion: completion, cacheResponse:cacheResponse, uniqueIdResult: uniqueIdResult)
	}
	
//	func syncContacts(completion:@escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType = nil){
//		SyncContactsRequestHandler.handle(self, completion: completion,uniqueIdsResult: uniqueIdsResult)
//	}
	
    func updateContact(_ req: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult:UniqueIdResultType = nil ){
		UpdateContactRequestHandler.handle(req: req, chat: self, completion: completion)
	}
	
	func blockContact(_ request:NewBlockRequest,completion:@escaping CompletionType<BlockedUser>,uniqueIdResult: UniqueIdResultType = nil){
		BlockContactRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
	func unBlockContact(_ request:NewUnBlockRequest,completion:@escaping CompletionType<BlockedUser>,uniqueIdResult:UniqueIdResultType = nil){
		UnBlockContactRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
    func mapReverse(_ request:NewMapReverseRequest,completion:@escaping CompletionType<NewMapReverse>,uniqueIdResult: UniqueIdResultType = nil){
		MapReverseRequestHandler.handle(req: request, chat: self, uniqueIdResult:uniqueIdResult, completion: completion)
	}
	
	func mapSearch(_ request:NewMapSearchRequest,completion:@escaping CompletionType<[NewMapItem]>,uniqueIdResult: UniqueIdResultType = nil){
		MapSearchRequestHandler.handle(req: request, chat: self, completion: completion)
	}
	
	func mapRouting(_ request:NewMapRoutingRequest,completion:@escaping CompletionType<[Route]>,uniqueIdResult: UniqueIdResultType = nil){
		MapRoutingRequestHandler.handle(req: request, chat: self, completion: completion)
	}
	
	func mapStaticImage(_ request:NewMapStaticImageRequest,completion:@escaping CompletionType<Data>,uniqueIdResult: UniqueIdResultType = nil){
		MapStaticImageRequestHandler.handle(req: request, chat: self, completion: completion)
	}
	
	func getThreads(_ request:ThreadsRequest,completion:@escaping PaginationCompletionType<[Conversation]>, cacheResponse: PaginationCacheResponseType<[Conversation]>? = nil ,  uniqueIdResult: UniqueIdResultType = nil){
		GetThreadsRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    func getAllThreads(request:AllThreads , completion:@escaping CompletionType<[Conversation]> , cacheResponse:CacheResponseType<[Conversation]>? = nil ,uniqueIdResult: UniqueIdResultType = nil){
        GetAllThreadsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }
	
	func isThreadNamePublic(_ request:IsThreadNamePublicRequest,completion:@escaping CompletionType<String>,uniqueIdResult: UniqueIdResultType = nil){
		IsThreadNamePublicRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func muteThread(_ request:NewMuteUnmuteThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		MuteThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func unmuteThread(_ request:NewMuteUnmuteThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		UnMuteThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func pinThread(_ request:NewPinUnpinThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		PinThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func unpinThread(_ request:NewPinUnpinThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		UnPinThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func createThread(_ request:NewCreateThreadRequest, completion:@escaping CompletionType<Conversation> ,uniqueIdResult: UniqueIdResultType = nil){
		CreateThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    func createThreadWithFileMessage(_ request:NewCreateThreadRequest,
                                     textMessage:NewSendTextMessageRequest,
                                     uploadFile:NewUploadFileRequest,
                                     uploadProgress:UploadFileProgressType? = nil,
                                     onSent:OnSentType = nil,
                                     onSeen:OnSeenType = nil,
                                     onDeliver:OnDeliveryType = nil,
                                     createThreadCompletion:CompletionType<Conversation>? = nil,
                                     uploadUniqueIdResult: UniqueIdResultType = nil,
                                     messageUniqueIdResult: UniqueIdResultType = nil
                         
    ){
        CreateThreadWithFileMessageRequestHandler.handle(self , request, textMessage, uploadFile,uploadProgress , onSent,onSeen,onDeliver ,createThreadCompletion,uploadUniqueIdResult,messageUniqueIdResult)
    }
    
    
	func addParticipant(_ request:AddParticipantRequest, completion:@escaping CompletionType<Conversation> , uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle([request], self , completion , uniqueIdResult)
	}
	
	func addParticipants(_ request:[AddParticipantRequest],completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func removeParticipants(_ request: NewRemoveParticipantsRequest,completion:@escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType = nil){
		RemoveParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func joinThread(_ request:NewJoinPublicThreadRequest ,completion:@escaping CompletionType<Conversation>,uniqueIdResult: UniqueIdResultType = nil){
		JoinPublicThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func closeThread(_ request:NewCloseThreadRequest ,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		CloseThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
    
    func spamPrivateThread(_ request: SpamThreadRequest , completion:@escaping CompletionType<Contact> , uniqueIdResult: UniqueIdResultType = nil){
        SpamThreadRequestHandler.handle( request , self ,completion , uniqueIdResult)
    }
	
	func updateThreadInfo(_ request:NewUpdateThreadInfoRequest , uniqueIdResult: UniqueIdResultType = nil, uploadProgress:@escaping UploadProgressType,completion:@escaping CompletionType<Conversation>){
		UpdateThreadInfoRequestHandler(self , request ,uploadProgress ,completion , uniqueIdResult ,.UPDATE_THREAD_INFO).handle()
	}
	
	func createThreadWithMessage(_ request:CreateThreadWithMessage ,
					uniqueIdResult: UniqueIdResultType = nil,
					onSent:OnSentType = nil,
					onDelivery:OnDeliveryType = nil,
					onSeen: OnSentType = nil,
					completion:@escaping CompletionType<Conversation>){
		CreateThreadWithMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func leaveThread(_ request:NewLeaveThreadRequest ,completion:@escaping CompletionType<Conversation>,uniqueIdResult: UniqueIdResultType = nil){
		LeaveThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func createBot(_ request:NewCreateBotRequest ,completion:@escaping CompletionType<Bot>,uniqueIdResult: UniqueIdResultType = nil){
		CreateBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func addBotCommand(_ request:NewAddBotCommandRequest ,completion:@escaping CompletionType<BotInfo>,uniqueIdResult: UniqueIdResultType = nil){
		AddBotCommandRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func startBot(_ request:NewStartStopBotRequest ,completion:@escaping CompletionType<String> ,uniqueIdResult: UniqueIdResultType = nil){
		StartBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func stopBot(_ request:NewStartStopBotRequest , completion:@escaping CompletionType<String> , uniqueIdResult: UniqueIdResultType = nil){
		StopBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func getUserInfo(_ request:UserInfoRequest ,completion:@escaping CompletionType<User> ,cacheResponse: CacheResponseType<User>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		UserInfoRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
	
	func setProfile(_ request:NewUpdateChatProfile ,completion:@escaping CompletionType<Profile>,uniqueIdResult: UniqueIdResultType = nil){
		UpdateChatProfileRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func sendStatusPing(_ request:SendStatusPingRequest){
		SendStatusPingRequestHandler.handle(request, self)
	}
	
	func getThreadParticipants(_ request:ThreadParticipantsRequest ,completion:@escaping PaginationCompletionType<[Participant]>, cacheResponse: PaginationCacheResponseType<[Participant]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		ThreadParticipantsRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    func sendTextMessage(_ request:NewSendTextMessageRequest ,uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver)
    }
    
    func replyMessage(_ request:NewReplyMessageRequest ,uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver)
    }
    
    func newlogOut() {
        LogoutRequestHandler.handle(self)
    }
    
    func sendLocationMessage( _ request:LocationMessageRequest,
                              uploadProgress:UploadFileProgressType? = nil,
                              downloadProgress:DownloadProgressType? = nil,
                              onSent:OnSentType = nil,
                              onSeen:OnSeenType = nil,
                              onDeliver:OnDeliveryType = nil,
                              uploadUniqueIdResult: UniqueIdResultType = nil,
                              messageUniqueIdResult: UniqueIdResultType = nil
                              ){
        SendLocationMessageRequestHandler.handle(self,request, downloadProgress, uploadProgress ,onSent,onSeen , onDeliver , uploadUniqueIdResult , messageUniqueIdResult)
    }
    
    func editMessage(_ request:NewEditMessageRequest , completion: CompletionType<Message>? = nil ,uniqueIdresult:UniqueIdResultType = nil){
        EditMessageRequestHandler.handle(request, self, completion ,uniqueIdresult)
    }
    
    func forwardMessages(_ request:NewForwardMessageRequest ,  onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil ,uniqueIdsrResult:UniqueIdsResultType = nil){
        ForwardMessagesRequestHandler.handle(request, self, onSent, onSeen, onDeliver, uniqueIdsrResult)
    }
    
    func getHistory(_ request:NewGetHistoryRequest ,
                    completion:@escaping PaginationCompletionType<[Message]> ,
                    cacheResponse: CacheResponseType<[Message]>? = nil,
                    textMessageNotSentRequests: CompletionType<[NewSendTextMessageRequest]>? = nil,
                    editMessageNotSentRequests: CompletionType<[NewEditMessageRequest]>? = nil,
                    forwardMessageNotSentRequests: CompletionType<[NewForwardMessageRequest]>? = nil,
                    fileMessageNotSentRequests: CompletionType<[(NewUploadFileRequest , NewSendTextMessageRequest )]>? = nil,
                    uploadFileNotSentRequests: CompletionType<[NewUploadFileRequest]>? = nil,
                    uploadImageNotSentRequests: CompletionType<[NewUploadImageRequest]>? = nil,
                    uniqueIdResult: UniqueIdResultType = nil){
        GetHistoryRequestHandler.handle(request,
                                        self ,
                                        completion,
                                        cacheResponse ,
                                        textMessageNotSentRequests ,
                                        editMessageNotSentRequests ,
                                        forwardMessageNotSentRequests,
                                        fileMessageNotSentRequests,
                                        uploadFileNotSentRequests,
                                        uploadImageNotSentRequests,
                                        uniqueIdResult)
    }
	
	func pinMessage(_ request:NewPinUnpinMessageRequest ,completion:@escaping CompletionType<PinUnpinMessageResponse> , uniqueIdResult: UniqueIdResultType = nil){
		PinMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    func unpinMessage(_ request:NewPinUnpinMessageRequest ,completion:@escaping CompletionType<PinUnpinMessageResponse> ,uniqueIdResult: UniqueIdResultType = nil){
		UnPinMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func clearHistory(_ request:NewClearHistoryRequest ,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		ClearHistoryRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func deleteMessage(_ request:NewDeleteMessageRequest ,completion:@escaping CompletionType<DeleteMessage>,uniqueIdResult: UniqueIdResultType = nil){
		DeleteMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func deleteMultipleMessages(_ request:BatchDeleteMessageRequest ,completion:@escaping CompletionType<DeleteMessage>,uniqueIdResult: UniqueIdResultType = nil){
		BatchDeleteMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    func allUnreadMessageCount(_ request:UnreadMessageCountRequest ,completion:@escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>? = nil ,uniqueIdResult: UniqueIdResultType = nil){
		AllUnreadMessageCountRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
	
	func getMentions(_ request:MentionRequest ,completion:@escaping PaginationCompletionType<[Message]> ,cacheResponse: PaginationCacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		MentionsRequestHandler.handle(request, self , completion, cacheResponse, uniqueIdResult)
	}
	
	func messageDeliveryParticipants(_ request:MessageDeliveredUsersRequest ,completion:@escaping PaginationCacheResponseType<[Participant]> ,uniqueIdResult: UniqueIdResultType = nil){
		MessageDeliveryParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func messageSeenByUsers(_ request:MessageSeenByUsersRequest , completion:@escaping PaginationCacheResponseType<[Participant]> , uniqueIdResult: UniqueIdResultType = nil){
		MessagSeenByUsersRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
	func deliver(_ request:MessageDeliverRequest ,uniqueIdResult: UniqueIdResultType = nil){
		DeliverRequestHandler.handle(request, self)
	}
	
	func seen(_ request:MessageSeenRequest , uniqueIdResult: UniqueIdResultType = nil){
		SeenRequestHandler.handle(request, self)
	}
	
    func getCurrentUserRoles(_ request:CurrentUserRolesRequest ,completion:@escaping CompletionType<[Roles]> , cacheResponse: CacheResponseType<[Roles]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		CurrentUserRolesRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    func cancelMessage(_ request:NewCancelMessageRequest ,completion: @escaping CompletionType<Bool>){
        CancelMessageRequestHandler.handle(self ,request, completion)
    }
    
    func snedStartTyping(threadId:Int){
        SendStartTypingRequestHandler.handle(threadId , self)
    }
    
    func sendStopTyping(){
        SendStartTypingRequestHandler.stopTyping()
    }
    
    func newSendSignalMessage(req: SendSignalMessageRequest) {
        prepareToSendAsync(req: req,
                           clientSpecificUniqueId: req.uniqueId,
                           subjectId: req.threadId,
                           pushMsgType: 4,
                           messageType: .SYSTEM_MESSAGE )
    }
    
    func getFile(req              :FileRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadFileCompletionType,
                 cacheResponse    :@escaping DownloadFileCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadFileRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }
    
    func getImage(req             :ImageRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadImageCompletionType,
                 cacheResponse    :@escaping DownloadImageCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadImageRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }
    
    func uploadFile(req                  :NewUploadFileRequest,
                    uploadUniqueIdResult :UniqueIdResultType       = nil,
                    uploadProgress       :UploadFileProgressType?  = nil,
                    uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadFileRequestHandler.uploadFile(chat: self, req: req, uploadCompletion: uploadCompletion, uploadProgress: uploadProgress , uploadUniqueIdResult: uploadUniqueIdResult)
    }
    
    func uploadImage(req                 :NewUploadImageRequest,
                     uploadUniqueIdResult :UniqueIdResultType       = nil,
                     uploadProgress       :UploadFileProgressType?  = nil,
                     uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadImageRequestHandler.uploadImage(chat: self, req: req, uploadCompletion: uploadCompletion, uploadProgress: uploadProgress , uploadUniqueIdResult: uploadUniqueIdResult)
    }
    
    func replyFileMessage(replyMessage:NewReplyMessageRequest,
                           uploadFile:NewUploadFileRequest,
                           uploadProgress:UploadFileProgressType? = nil,
                           onSent:OnSentType = nil,
                           onSeen:OnSeenType = nil,
                           onDeliver:OnDeliveryType = nil,
                           uploadUniqueIdResult: UniqueIdResultType = nil,
                           messageUniqueIdResult: UniqueIdResultType = nil
    ){
        sendFileMessage(textMessage: replyMessage,
                        uploadFile: uploadFile,
                        uploadProgress: uploadProgress,
                        onSent: onSent,
                        onSeen: onSeen,
                        onDeliver: onDeliver,
                        uploadUniqueIdResult: uploadUniqueIdResult,
                        messageUniqueIdResult: messageUniqueIdResult
                        )
    }
    
    func sendFileMessage(textMessage:NewSendTextMessageRequest,
                         uploadFile:NewUploadFileRequest,
                         uploadProgress:UploadFileProgressType? = nil,
                         onSent:OnSentType = nil,
                         onSeen:OnSeenType = nil,
                         onDeliver:OnDeliveryType = nil,
                         uploadUniqueIdResult: UniqueIdResultType = nil,
                         messageUniqueIdResult: UniqueIdResultType = nil
                         ){
        if let uploadRequest = uploadFile as? NewUploadImageRequest {
            SendImageMessageRequest.handle(textMessage, uploadRequest, onSent, onSeen, onDeliver, uploadProgress, uploadUniqueIdResult, messageUniqueIdResult, self)
            return
        }
        SendFileMessageRequest.handle(textMessage, uploadFile, onSent , onSeen , onDeliver , uploadProgress , uploadUniqueIdResult , messageUniqueIdResult , self)
    }
    
    func manageUpload(uniqueId:String , action:DownloaUploadAction , isImage:Bool,completion:((String,Bool)->())? = nil){
        ManageUploadRequestHandler.handle(uniqueId, action, isImage,completion)
    }
    
    func manageDownload(uniqueId:String , action:DownloaUploadAction , isImage:Bool ,completion:((String,Bool)->())? = nil){
        ManageDownloadRequestHandler.handle(uniqueId, action, isImage,completion)
    }
    
    func registerAssistat(_ request:RegisterAssistantRequest , completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        RegisterAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    func deactiveAssistant(_ request:DeactiveAssistantRequest, completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        DeactiveAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    func getAssistats(_ request:AssistantsRequest , completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    func getAssistatsHistory(_ completion:@escaping CompletionType<[AssistantAction]> , uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsHistoryRequestHandler.handle(self, completion, uniqueIdResult)
    }
	
	// REST API Request
    func restApiRequest<T:Decodable, E:Encodable>(_ encodableRequest:E ,
											 decodeType:T.Type,
											 url:String,
											 method:NewHTTPMethod = .get,
                                             headers:[String:String]? = nil,
											 clientSpecificUniqueId:String? = nil ,
											 typeCode: String? ,
											 uniqueIdResult: ((String)->())? = nil,
											 completion:  @escaping ((ChatResponse)->())
	){
        guard let data = try? JSONEncoder().encode(encodableRequest) else {return}
        RequestManager.request(ofType: decodeType,
                               bodyData: data,
                               url: url,
                               method: method,
                               headers: headers
        ) { [weak self] response , error in
             guard let weakSelf = self else{return}
             if let error = error {
                 weakSelf.delegate?.chatError(errorCode: error.errorCode ?? 0 ,
                                              errorMessage: error.message ?? "",
                                              errorResult: error.content)
             }
            if let response = response{
                var count = 0
                if let array = response as? Array<Any>{
                   count = array.count
                }
                completion(ChatResponse(result: response, contentCount: count))
            }
        }
	}
	
	// SOCKET Request
	func prepareToSendAsync(req:Encodable? = nil ,
									clientSpecificUniqueId:String? = nil ,
									typeCode:String? = nil ,
									//this sometimes use to send threadId with subjectId Key must fix from server to get threadId
									subjectId:Int? = nil,
                                    plainText:Bool = false,
                                    pushMsgType:Int? = nil,
									messageType:NewChatMessageVOTypes ,
									uniqueIdResult:((String)->())? = nil,
									completion: ((ChatResponse)->())? = nil,
									onSent: OnSentType? = nil,
									onDelivered: OnDeliveryType? = nil,
									onSeen: OnSeenType? = nil
                                    ){
		guard let createChatModel = createChatModel else {return}
		let uniqueId = clientSpecificUniqueId ?? UUID().uuidString
		uniqueIdResult?(uniqueId)
		let typeCode = typeCode ?? createChatModel.typeCode ?? "default"
		
		let chatMessage = NewSendChatMessageVO(type:  messageType.rawValue,
											token:              createChatModel.token,
											content:            getContent(req , plainText),
											subjectId: subjectId,
											typeCode:           typeCode,
											uniqueId:           uniqueId,
											isCreateThreadAndSendMessage: true)
		
		guard let chatMessageContent = chatMessage.convertCodableToString() else{return}
		let asyncMessage = NewSendAsyncMessageVO(content:     chatMessageContent,
											  ttl: createChatModel.msgTTL,
											  peerName:     createChatModel.serverName,
											  priority:     createChatModel.msgPriority,
                                              pushMsgType: pushMsgType
		)
		
		
		callbacksManager.addCallback(uniqueId: uniqueId , callback: completion ,onSent: onSent , onDelivered: onDelivered , onSeen: onSeen)
		asyncMessage.printAsyncJson()
		sendToAsync(asyncMessageVO: asyncMessage)
	}
    
    func prepareToSendAsync(_ chatMessage:NewSendChatMessageVO,
                            uniqueId:String,
                            pushMsgType:Int? = nil,
                            completion: ((ChatResponse)->())? = nil,
                            onSent: OnSentType? = nil,
                            onDelivered: OnDeliveryType? = nil,
                            onSeen: OnSeenType? = nil){
        guard let chatMessageContent = chatMessage.convertCodableToString() , let createChatModel = createChatModel  else{return}
        let asyncMessage = NewSendAsyncMessageVO(content:     chatMessageContent,
                                              ttl: createChatModel.msgTTL,
                                              peerName:     createChatModel.serverName,
                                              priority:     createChatModel.msgPriority,
                                              pushMsgType: pushMsgType
        )
        
		asyncMessage.printAsyncJson()
        callbacksManager.addCallback(uniqueId: uniqueId , callback: completion ,onSent: onSent , onDelivered: onDelivered , onSeen: onSeen)
        sendToAsync(asyncMessageVO: asyncMessage)
    }
	
	private func getContent(_ req:Encodable? , _ plainText:Bool)->String?{
		var content:String? = nil
		if !plainText && req != nil {
			content = req?.convertCodableToString()
		}else if plainText && req != nil , let stringValue = req as? String{
			content = stringValue
		}
		return content
	}
	
	internal func sendToAsync(asyncMessageVO:NewSendAsyncMessageVO){
		guard let content = asyncMessageVO.convertCodableToString() else { return }
		asyncClient?.pushSendData(type: asyncMessageVO.pushMsgType ?? 3, content: content)
		runSendMessageTimer()
	}
    
    func setToken(newToken: String , reCreateObject:Bool = false) {
        token = newToken
        createChatModel?.token = newToken
        if reCreateObject{
            CreateAsync()
        }
    }
}

