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
	func createChatObject(config:ChatConfig){
		isCreateObjectFuncCalled = true
        self.config = config
        initAllOldProperties()
		initialize()
	}
    
    private func initAllOldProperties(){
        if let model = config{
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
            
            cacheTimeStamp                            = model.cacheTimeStampInSec
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
        logger = Logger(isDebuggingLogEnabled: config?.isDebuggingLogEnabled ?? false)
		if config?.captureLogsOnSentry == true {
			startCrashAnalytics()
		}
		
		if config?.getDeviceIdFromToken == false{
            if config?.useNewSDK == true{
                asyncManager.createAsync()
            }else{
                CreateAsync()
            }
		}else{
            DeviceIdRequestHandler.getDeviceIdAndCreateAsync(chat: self)
		}
		
		_ = DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config?.deviecLimitationSpaceMB ?? 100, turnOffTheCache: true, errorDelegate: delegate)
	}
	
	func dispose() {
		stopAllChatTimers()
		asyncClient?.disposeAsyncObject()
		asyncClient = nil
        asyncManager.disposeObject()
		Chat.instance = nil
		print("Disposed Singleton instance")
	}
	//**************************** Intitializers ****************************
	
    //Test Status: Main ✅ - Integeration: ✅
	func getContacts(_ request:ContactsRequest,completion:@escaping PaginationCompletionType<[Contact]>,cacheResponse:PaginationCacheResponseType<[Contact]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		GetContactsRequestHandler.handle(request,self,completion,cacheResponse,uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func getBlockedContacts(_ request:BlockedListRequest , completion:@escaping PaginationCompletionType<[BlockedUser]>,uniqueIdResult: UniqueIdResultType = nil){
		GetBlockedContactsRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func addContact(_ request:NewAddContactRequest,completion:@escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType = nil){
        AddContactRequestHandler.handle(request,self,completion,uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
    func addContacts(_ request:[NewAddContactRequest],completion:@escaping CompletionType<[Contact]>,uniqueIdsResult:UniqueIdsResultType = nil){
        AddContactsRequestHandler.handle(request,self,completion,uniqueIdsResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func contactNotSeen(_ request:NotSeenDurationRequest,completion:@escaping CompletionType<[UserLastSeenDuration]>,uniqueIdResult: UniqueIdResultType = nil){
		NotSeenContactRequestHandler.handle(request, self, completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func removeContact(_ request:NewRemoveContactsRequest,completion:@escaping CompletionType<Bool>,uniqueIdResult: UniqueIdResultType = nil){
		RemoveContactRequestHandler.handle(request,self,completion,uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func searchContacts(_ request:ContactsRequest, completion:@escaping PaginationCompletionType<[Contact]>, cacheResponse: PaginationCacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        getContacts(request, completion: completion, cacheResponse:cacheResponse, uniqueIdResult: uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func syncContacts(completion:@escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType = nil){
		SyncContactsRequestHandler.handle(self,completion,uniqueIdsResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
    func updateContact(_ req: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult:UniqueIdResultType = nil ){
		UpdateContactRequestHandler.handle(req,self,completion,uniqueIdsResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func blockContact(_ request:NewBlockRequest,completion:@escaping CompletionType<BlockedUser>,uniqueIdResult: UniqueIdResultType = nil){
		BlockContactRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func unBlockContact(_ request:NewUnBlockRequest,completion:@escaping CompletionType<BlockedUser>,uniqueIdResult:UniqueIdResultType = nil){
		UnBlockContactRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
    //Test Status: Neshan API ✅
    func mapReverse(_ request:NewMapReverseRequest,completion:@escaping CompletionType<NewMapReverse>,uniqueIdResult: UniqueIdResultType = nil){
		MapReverseRequestHandler.handle(request,self,completion,uniqueIdResult)
	}
	
    //Test Status: Neshan API ✅
	func mapSearch(_ request:NewMapSearchRequest,completion:@escaping CompletionType<[NewMapItem]>,uniqueIdResult: UniqueIdResultType = nil){
		MapSearchRequestHandler.handle(request,self, completion , uniqueIdResult)
	}
	
    //Test Status: Neshan API ✅
	func mapRouting(_ request:NewMapRoutingRequest,completion:@escaping CompletionType<[Route]>,uniqueIdResult: UniqueIdResultType = nil){
		MapRoutingRequestHandler.handle(request,self, completion , uniqueIdResult)
	}
	
    //Test Status: Neshan API ✅
	func mapStaticImage(_ request:NewMapStaticImageRequest,completion:@escaping CompletionType<Data>,uniqueIdResult: UniqueIdResultType = nil){
		MapStaticImageRequestHandler.handle(request,self,completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func getThreads(_ request:ThreadsRequest,completion:@escaping PaginationCompletionType<[Conversation]>, cacheResponse: PaginationCacheResponseType<[Conversation]>? = nil ,  uniqueIdResult: UniqueIdResultType = nil){
		GetThreadsRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ✅
    func getAllThreads(request:AllThreads , completion:@escaping CompletionType<[Conversation]> , cacheResponse:CacheResponseType<[Conversation]>? = nil ,uniqueIdResult: UniqueIdResultType = nil){
        GetAllThreadsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }
	
    //Test Status: Main ✅ - Integeration: ✅
	func isThreadNamePublic(_ request:IsThreadNamePublicRequest,completion:@escaping CompletionType<String>,uniqueIdResult: UniqueIdResultType = nil){
		IsThreadNamePublicRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func muteThread(_ request:NewMuteUnmuteThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		MuteThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func unmuteThread(_ request:NewMuteUnmuteThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		UnMuteThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func pinThread(_ request:NewPinUnpinThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		PinThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func unpinThread(_ request:NewPinUnpinThreadRequest,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		UnPinThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func createThread(_ request:NewCreateThreadRequest, completion:@escaping CompletionType<Conversation> ,uniqueIdResult: UniqueIdResultType = nil){
		CreateThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
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
    
    //Test Status: Main ✅ - Integeration: ✅
    //may remove in future release and provide a substitution way and move request to Object model and class AddParticipantRequest
    func addParticipant(_ contactIds:[Int], threadId:Int, uniqueId:String,typeCode:String, completion:@escaping CompletionType<Conversation> , uniqueIdResult: UniqueIdResultType = nil){
        AddParticipantsRequestHandler.handle(contactIds, threadId, uniqueId, typeCode, self, completion, uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
	func addParticipant(_ request:AddParticipantRequest, completion:@escaping CompletionType<Conversation> , uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle([request], self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func addParticipants(_ request:[AddParticipantRequest],completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func removeParticipants(_ request: NewRemoveParticipantsRequest,completion:@escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType = nil){
		RemoveParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func joinThread(_ request:NewJoinPublicThreadRequest ,completion:@escaping CompletionType<Conversation>,uniqueIdResult: UniqueIdResultType = nil){
		JoinPublicThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
	func closeThread(_ request:NewCloseThreadRequest ,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		CloseThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ❌  because of sandbox problem - Sandbox: ✅
    func spamPvThread(_ request: SpamThreadRequest , completion:@escaping CompletionType<BlockedUser> , uniqueIdResult: UniqueIdResultType = nil){
        SpamThreadRequestHandler.handle( request , self ,completion , uniqueIdResult)
    }
	
    //Test Status: Main ✅ - Integeration: ❌  because of sandbox problem - Sandbox: ✅
	func updateThreadInfo(_ request:NewUpdateThreadInfoRequest , uniqueIdResult: UniqueIdResultType = nil, uploadProgress:@escaping UploadProgressType,completion:@escaping CompletionType<Conversation>){
		UpdateThreadInfoRequestHandler(self , request ,uploadProgress ,completion , uniqueIdResult ,.UPDATE_THREAD_INFO).handle()
	}
	
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
	func createThreadWithMessage(_ request:CreateThreadWithMessage ,
					uniqueIdResult: UniqueIdResultType = nil,
					onSent:OnSentType = nil,
					onDelivery:OnDeliveryType = nil,
					onSeen: OnSentType = nil,
					completion:@escaping CompletionType<Conversation>){
		CreateThreadWithMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func leaveThread(_ request:NewLeaveThreadRequest ,completion:@escaping CompletionType<Conversation>,uniqueIdResult: UniqueIdResultType = nil){
		LeaveThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ✅
    func leaveThreadSaftly(_ request:NewSafeLeaveThreadRequest, completion:@escaping CompletionType<Conversation> , newAdminCompletion:CompletionType<[UserRole]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
        ReplaceAdminAndLeaveThreadRequestHandler.handle(request,self,completion,newAdminCompletion,uniqueIdResult)
    }
	
    //Test Status: Main ✅ - Integeration: ✅
	func createBot(_ request:NewCreateBotRequest ,completion:@escaping CompletionType<Bot>,uniqueIdResult: UniqueIdResultType = nil){
		CreateBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func addBotCommand(_ request:NewAddBotCommandRequest ,completion:@escaping CompletionType<BotInfo>,uniqueIdResult: UniqueIdResultType = nil){
		AddBotCommandRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ✅
    func removeBotCommand(_ request:RemoveBotCommandRequest ,completion:@escaping CompletionType<BotInfo>,uniqueIdResult: UniqueIdResultType = nil){
        RemoveBotCommandRequestHandler.handle(request, self , completion , uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func getUserBots(_ request:GetUserBotsRequest ,completion:@escaping CompletionType<[BotInfo]>,uniqueIdResult: UniqueIdResultType = nil){
        UserBotsBotsRequestHandler.handle(request, self , completion , uniqueIdResult)
    }
	
    //Test Status: Main ✅ - Integeration: ✅
	func startBot(_ request:NewStartStopBotRequest ,completion:@escaping CompletionType<String> ,uniqueIdResult: UniqueIdResultType = nil){
		StartBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func stopBot(_ request:NewStartStopBotRequest , completion:@escaping CompletionType<String> , uniqueIdResult: UniqueIdResultType = nil){
		StopBotRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func getUserInfo(_ request:UserInfoRequest ,completion:@escaping CompletionType<User> ,cacheResponse: CacheResponseType<User>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		UserInfoRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func setProfile(_ request:NewUpdateChatProfile ,completion:@escaping CompletionType<Profile>,uniqueIdResult: UniqueIdResultType = nil){
		UpdateChatProfileRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func sendStatusPing(_ request:SendStatusPingRequest){
		SendStatusPingRequestHandler.handle(request, self)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func getThreadParticipants(_ request:ThreadParticipantsRequest ,completion:@escaping PaginationCompletionType<[Participant]>, cacheResponse: PaginationCacheResponseType<[Participant]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
		ThreadParticipantsRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ✅
    func getThreadAdmins(_ request:ThreadParticipantsRequest ,completion:@escaping PaginationCompletionType<[Participant]>, cacheResponse: PaginationCacheResponseType<[Participant]>? = nil,uniqueIdResult: UniqueIdResultType = nil){
        request.admin = true
        ThreadParticipantsRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func changeThreadType(_ request:ChangeThreadTypeRequest ,completion:@escaping CompletionType<Conversation>,uniqueIdResult: UniqueIdResultType = nil){
        ChangeThreadTypeRequestHandler.handle(request, self , completion, uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func sendTextMessage(_ request:NewSendTextMessageRequest ,uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver , uniqueIdresult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func replyMessage(_ request:NewReplyMessageRequest ,uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver , uniqueIdresult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func newlogOut() {
        LogoutRequestHandler.handle(self)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
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
    
    //Test Status: Main ✅ - Integeration: ✅
    func editMessage(_ request:NewEditMessageRequest , completion: CompletionType<Message>? = nil ,uniqueIdResult:UniqueIdResultType = nil){
        EditMessageRequestHandler.handle(request, self, completion ,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func forwardMessages(_ request:NewForwardMessageRequest ,  onSent:OnSentType = nil , onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil ,uniqueIdsResult:UniqueIdsResultType = nil){
        ForwardMessagesRequestHandler.handle(request, self, onSent, onSeen, onDeliver, uniqueIdsResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
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
    
    //Test Status: Main ✅ - Integeration: ✅
    func getHashtagList(_ request:NewGetHistoryRequest ,
                    completion:@escaping PaginationCompletionType<[Message]> ,
                    cacheResponse: CacheResponseType<[Message]>? = nil,
                    uniqueIdResult: UniqueIdResultType = nil){
        GetHistoryRequestHandler.handle(request,self,completion,cacheResponse,nil,nil,nil,nil,nil,nil,uniqueIdResult)
    }
	
    //Test Status: Main ✅ - Integeration: ✅
	func pinMessage(_ request:NewPinUnpinMessageRequest ,completion:@escaping CompletionType<PinUnpinMessage> , uniqueIdResult: UniqueIdResultType = nil){
		PinMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
    func unpinMessage(_ request:NewPinUnpinMessageRequest ,completion:@escaping CompletionType<PinUnpinMessage> ,uniqueIdResult: UniqueIdResultType = nil){
		UnPinMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func clearHistory(_ request:NewClearHistoryRequest ,completion:@escaping CompletionType<Int>,uniqueIdResult: UniqueIdResultType = nil){
		ClearHistoryRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func deleteMessage(_ request:NewDeleteMessageRequest ,completion:@escaping CompletionType<DeleteMessage>,uniqueIdResult: UniqueIdResultType = nil){
		DeleteMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func deleteMultipleMessages(_ request:BatchDeleteMessageRequest ,completion:@escaping CompletionType<DeleteMessage>,uniqueIdResult: UniqueIdResultType = nil){
		BatchDeleteMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
    func allUnreadMessageCount(_ request:UnreadMessageCountRequest ,completion:@escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>? = nil ,uniqueIdResult: UniqueIdResultType = nil){
		AllUnreadMessageCountRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func getMentions(_ request:MentionRequest ,completion:@escaping PaginationCompletionType<[Message]> ,cacheResponse: PaginationCacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		MentionsRequestHandler.handle(request, self , completion, cacheResponse, uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func messageDeliveryParticipants(_ request:MessageDeliveredUsersRequest ,completion:@escaping PaginationCacheResponseType<[Participant]> ,uniqueIdResult: UniqueIdResultType = nil){
		MessageDeliveryParticipantsRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
	func messageSeenByUsers(_ request:MessageSeenByUsersRequest , completion:@escaping PaginationCacheResponseType<[Participant]> , uniqueIdResult: UniqueIdResultType = nil){
		MessagSeenByUsersRequestHandler.handle(request, self , completion , uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
	func deliver(_ request:MessageDeliverRequest ,uniqueIdResult: UniqueIdResultType = nil){
		DeliverRequestHandler.handle(request,self,uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
	func seen(_ request:MessageSeenRequest , uniqueIdResult: UniqueIdResultType = nil){
		SeenRequestHandler.handle(request,self,uniqueIdResult)
	}
	
    //Test Status: Main ✅ - Integeration: ✅
    func getCurrentUserRoles(_ request:CurrentUserRolesRequest ,completion:@escaping CompletionType<[Roles]> , cacheResponse: CacheResponseType<[Roles]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		CurrentUserRolesRequestHandler.handle(request, self , completion , cacheResponse , uniqueIdResult)
	}
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func cancelMessage(_ request:NewCancelMessageRequest ,completion: @escaping CompletionType<Bool>){
        CancelMessageRequestHandler.handle(self ,request, completion)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func snedStartTyping(threadId:Int){
        SendStartTypingRequestHandler.handle(threadId , self)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func sendStopTyping(){
        SendStartTypingRequestHandler.stopTyping()
    }
    
    func newSendSignalMessage(req: NewSendSignalMessageRequest) {
        prepareToSendAsync(req: req,
                           clientSpecificUniqueId: req.uniqueId,
                           subjectId: req.threadId,
                           pushMsgType: 4,
                           messageType: .SYSTEM_MESSAGE )
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func getFile(req              :FileRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadFileCompletionType,
                 cacheResponse    :@escaping DownloadFileCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadFileRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }
    
    //Test Status: Main ✅  - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func getImage(req             :ImageRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadImageCompletionType,
                 cacheResponse    :@escaping DownloadImageCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadImageRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func uploadFile(req                  :NewUploadFileRequest,
                    uploadUniqueIdResult :UniqueIdResultType       = nil,
                    uploadProgress       :UploadFileProgressType?  = nil,
                    uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadFileRequestHandler.uploadFile(self,req,uploadCompletion,uploadProgress,uploadUniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func uploadImage(req                 :NewUploadImageRequest,
                     uploadUniqueIdResult :UniqueIdResultType       = nil,
                     uploadProgress       :UploadFileProgressType?  = nil,
                     uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadImageRequestHandler.uploadImage(self,req,uploadCompletion,uploadProgress,uploadUniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
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
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
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
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func manageUpload(uniqueId:String , action:DownloaUploadAction , isImage:Bool,completion:((String,Bool)->())? = nil){
        ManageUploadRequestHandler.handle(uniqueId, action, isImage,completion)
    }
    
    //Test Status: Main ✅ - Integeration: ❌ because of sandbox problem - Sandbox: ✅
    func manageDownload(uniqueId:String , action:DownloaUploadAction , isImage:Bool ,completion:((String,Bool)->())? = nil){
        ManageDownloadRequestHandler.handle(uniqueId, action, isImage,completion)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func registerAssistat(_ request:RegisterAssistantRequest , completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        RegisterAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func deactiveAssistant(_ request:DeactiveAssistantRequest, completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        DeactiveAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func getAssistats(_ request:AssistantsRequest , completion:@escaping PaginationCompletionType<[Assistant]>,cacheResponse: PaginationCompletionType<[Assistant]>? = nil , uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsRequestHandler.handle(request,self,completion,cacheResponse,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func getAssistatsHistory(_ completion:@escaping CompletionType<[AssistantAction]> , uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsHistoryRequestHandler.handle(self, completion, uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func getBlockedAssistants(_ request:BlockedAssistantsRequest,_ completion:@escaping PaginationCompletionType<[Assistant]>, cacheResponse: PaginationCacheResponseType<[Assistant]>? = nil  , uniqueIdResult : UniqueIdResultType = nil){
        BlockedAssistantsRequestHandler.handle(request,self,completion,cacheResponse,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func blockAssistants(_ request:BlockUnblockAssistantRequest,_ completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        BlockAssistantRequestHandler.handle(request,self,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func unblockAssistants(_ request:BlockUnblockAssistantRequest,_ completion:@escaping CompletionType<[Assistant]> , uniqueIdResult : UniqueIdResultType = nil){
        UnBlockAssistatRequestHandler.handle(request,self,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func setRoles(_ request:RolesRequest, _ completion:@escaping CompletionType<[UserRole]> , uniqueIdResult:UniqueIdResultType = nil){
        SetRoleRequestHandler.handle(self,request,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func removeRoles(_ request:RolesRequest, _ completion:@escaping CompletionType<[UserRole]> , uniqueIdResult:UniqueIdResultType){
        RemoveRoleRequestHandler.handle(self,request,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func setAuditor(_ request:AuditorRequest, _ completion:@escaping CompletionType<[UserRole]> , uniqueIdResult:UniqueIdResultType){
        SetRoleRequestHandler.handle(self,request,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func removeAuditor(_ request:AuditorRequest, _ completion:@escaping CompletionType<[UserRole]> , uniqueIdResult:UniqueIdResultType){
        RemoveRoleRequestHandler.handle(self,request,completion,uniqueIdResult)
    }
    
    //Test Status: Main ✅ - Integeration: ✅
    func mutualGroups(_ request:MutualGroupsRequest, _ completion:@escaping PaginationCompletionType<[Conversation]> ,cacheResponse :PaginationCacheResponseType<[Conversation]>? = nil , uniqueIdResult:UniqueIdResultType){
        MutualGroupsRequestHandler.handle(request,self,completion , cacheResponse ,uniqueIdResult)
    }
	
    //Call
    
    //Test Status: Main ❌ - Integeration: ✅
    func requestCall(_ request:StartCallRequest, _ completion:@escaping CompletionType<CreateCall>, uniqueIdResult:UniqueIdResultType = nil){
        StartCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func requestGroupCall(_ request:StartCallRequest, _ completion:@escaping CompletionType<CreateCall>, uniqueIdResult:UniqueIdResultType = nil){
        StartCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    // MARK:- only SDK can call this method
    internal func callReceived(_ request:CallReceivedRequest){
        CallReceivedRequestHandler.handle(request,self)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func endCall(_ request:EndCallRequest, _ completion:@escaping CompletionType<Int>, uniqueIdResult:UniqueIdResultType = nil){
        EndCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func addCallPartcipant(_ request:AddCallParticipantsRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        AddCallParticipantRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func removeCallPartcipant(_ request:RemoveCallParticipantsRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        RemoveCallParticipantRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func acceptCall(_ request:AcceptCallRequest, uniqueIdResult:UniqueIdResultType = nil){
        AcceptCallRequestHandler.handle(request,self,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
	/// You can use this function to reject or cancel a call when not accepted by anyone or any other reason!
    func cancelCall(_ request:CancelCallRequest, uniqueIdResult:UniqueIdResultType = nil){
        CancelCallRequestHandler.handle(request,self,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func turnOnVideoCall(_ request:TurnOnVideoCallRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        TurnONVideoCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func turnOffVideoCall(_ request:TurnOffVideoCallRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        TurnOffVideoCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func muteCall(_ request:MuteCallRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        MuteCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func unmuteCall(_ request:UNMuteCallRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        UNMuteCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func terminateCall(_ request:TerminateCallRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        TerminateCallRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ✅
    func activeCallParticipants(_ request:ActiveCallParticipantsRequest, _ completion:@escaping CompletionType<[CallParticipant]>, uniqueIdResult:UniqueIdResultType = nil){
        ActiveCallParticipantsRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func startRecording(_ request:StartCallRecordingRequest, _ completion:@escaping CompletionType<Participant>, uniqueIdResult:UniqueIdResultType = nil){
        StartCallRecordingRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
    func stopRecording(_ request:StopCallRecordingRequest, _ completion:@escaping CompletionType<Participant>, uniqueIdResult:UniqueIdResultType = nil){
        StopCallRecordingRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }

    //Test Status: Main ❌ - Integeration: ✅
    func callsHistory(_ request:CallsHistoryRequest, _ completion:@escaping PaginationCompletionType<[Call]>, uniqueIdResult:UniqueIdResultType = nil){
        CallsHistoryRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }

    func sendCallClientError(_ request:CallClientErrorRequest,_ completion:@escaping CompletionType<CallError>, uniqueIdResult:UniqueIdResultType = nil){
        SendCallClientErrorRequestHandler.handle(request,self,completion ,uniqueIdResult)
    }
    //Call
    
    
    
	// REST API Request
    func restApiRequest<T:Decodable>(_ encodableRequest:BaseRequest ,
											 decodeType:T.Type,
											 url:String,
                                             bodyParameter:Bool = false,
											 method:NewHTTPMethod = .get,
                                             headers:[String:String]? = nil,
											 clientSpecificUniqueId:String? = nil ,
											 uniqueIdResult: UniqueIdResultType = nil,
											 completion:  @escaping ((ChatResponse)->())
	){
        uniqueIdResult?(encodableRequest.uniqueId)
        var data = bodyParameter ? encodableRequest.getParameterData() : (try? JSONEncoder().encode(encodableRequest))
        let url = method == .get ? encodableRequest.convertToGETMethodQueeyString(url: url) ?? url : url
        if method == .get {
            data = nil // pass data with queryString not inside body
        }
        RequestManager.request(ofType: decodeType,
                               bodyData: data,
                               url: url,
                               method: method,
                               headers: headers
        ) { [weak self] response , error in
             guard let weakSelf = self else{return}
             if let error = error {
                weakSelf.delegate?.chatError(error: error)
                completion(.init(error: error))
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
                                    peerName:String? = nil,
									messageType:NewChatMessageVOTypes ,
									uniqueIdResult:((String)->())? = nil,
									completion: ((ChatResponse)->())? = nil,
									onSent: OnSentType? = nil,
									onDelivered: OnDeliveryType? = nil,
									onSeen: OnSeenType? = nil
                                    ){
		guard let config = config else {return}
		let uniqueId = clientSpecificUniqueId ?? UUID().uuidString
		uniqueIdResult?(uniqueId)
		let typeCode = typeCode ?? config.typeCode ?? "default"
		
		let chatMessage = NewSendChatMessageVO(type:  messageType.rawValue,
											token:              config.token,
											content:            getContent(req , plainText),
											subjectId: subjectId,
											typeCode:           typeCode,
											uniqueId:           uniqueId)
		
		guard let chatMessageContent = chatMessage.convertCodableToString() else{return}
		let asyncMessage = NewSendAsyncMessageVO(content:     chatMessageContent,
											  ttl: config.msgTTL,
											  peerName:    peerName ?? config.serverName,
											  priority:     config.msgPriority,
                                              pushMsgType: pushMsgType
		)
		
		
		callbacksManager.addCallback(uniqueId: uniqueId, requesType: messageType, callback: completion ,onSent: onSent , onDelivered: onDelivered , onSeen: onSeen)
        sendToAsync(asyncMessageVO: asyncMessage)
	}
    
    func prepareToSendAsync(_ chatMessage:NewSendChatMessageVO,
                            uniqueId:String,
                            pushMsgType:Int? = nil,
                            peerName:String? = nil,
                            uniqueIdResult:UniqueIdResultType = nil,
                            completion: ((ChatResponse)->())? = nil,
                            onSent: OnSentType? = nil,
                            onDelivered: OnDeliveryType? = nil,
                            onSeen: OnSeenType? = nil
                            ){
        uniqueIdResult?(uniqueId)
        guard let chatMessageContent = chatMessage.convertCodableToString() , let config = config  else{return}
        let asyncMessage = NewSendAsyncMessageVO(content:     chatMessageContent,
                                              ttl: config.msgTTL,
                                              peerName:    peerName ?? config.serverName,
                                              priority:     config.msgPriority,
                                              pushMsgType: pushMsgType
        )
        guard let rawType =  chatMessage.messageType, let messageType = NewChatMessageVOTypes(rawValue: rawType) else {return}
        callbacksManager.addCallback(uniqueId: uniqueId, requesType: messageType, callback: completion ,onSent: onSent , onDelivered: onDelivered , onSeen: onSeen)
        sendToAsync(asyncMessageVO: asyncMessage)
    }
    
    //Use only for webrtc call
    internal func prepareToSendAsync(_ content: String,peerName:String? = nil){
        guard let config = config  else{return}
        let asyncMessage = NewSendAsyncMessageVO(content:     content,
                                              ttl: config.msgTTL,
                                              peerName:  peerName ?? config.serverName,
                                              priority:  config.msgPriority
        )        
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
        guard let content = try? JSONEncoder().encode(asyncMessageVO) else { return }
        logger?.log(title: "send Message", jsonString: asyncMessageVO.string ?? "")
        asyncManager.sendData(type: AsyncMessageTypes(rawValue: asyncMessageVO.pushMsgType ?? 3)! , data: content)        
	}
    
    func setToken(newToken: String , reCreateObject:Bool = false) {
        token = newToken
        config?.token = newToken
        if reCreateObject{
            asyncManager.createAsync()
        }
    }
    
    internal func setUser(user:User){
        self.userInfo = user
    }
    
    func sotpAllSignalingServerCall(peerName:String){
        let close = StopAllSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {return}
        if let content = String(data: data, encoding: .utf8){
            prepareToSendAsync(content,peerName: peerName)
        }
    }
    
    func closeSignalingServerCall(peerName:String){
        let close = CloseSessionReq(token: Chat.sharedInstance.token)
        guard let data = try? JSONEncoder().encode(close) else {return}
        if let content = String(data: data, encoding: .utf8){
            prepareToSendAsync(content,peerName: peerName)
        }
    }
}
