import FanapPodAsyncSDK
import Sentry
import Foundation

public class Chat {
    
    // MARK: - Chat Private initializer
    private init() {}
    
    private static var instance: Chat?

    /// Singleton instance of chat SDK.
    open class var sharedInstance: Chat {
        if instance == nil {
            instance = Chat()
        }
        return instance!
    }
    
    private var isCreateObjectFuncCalled                 = false
    var config                : ChatConfig?
    let callbacksManager                         = CallbacksManager()
    internal let asyncManager : AsyncManager     = AsyncManager()
    internal var logger       : Logger?

    /// Current user info of the application it'll be filled after chat is in the ``ChatState/CHAT_READY``  state.
    public private (set) var userInfo              : User?
    var token                 : String?  = nil

    /// Delegate to send events.
    public weak var delegate: ChatDelegate?{
        didSet{
            if(!isCreateObjectFuncCalled){
                print("Please call createChatObject func before set delegate")
            }
        }
    }
    
    /// Create chat object and connecting to async server.
    /// - Parameter config: Configuration of chat object.
    public func createChatObject(config:ChatConfig){
		isCreateObjectFuncCalled = true
        self.config = config
        self.token  = config.token
		initialize()
	}

    /// Create logger and then connect to async server.
	private func initialize(){
        logger = Logger(isDebuggingLogEnabled: config?.isDebuggingLogEnabled ?? false)
		if config?.captureLogsOnSentry == true {
			startCrashAnalytics()
		}
		
		if config?.getDeviceIdFromToken == false{
            asyncManager.createAsync()
		}else{
            DeviceIdRequestHandler.getDeviceIdAndCreateAsync(chat: self)
		}
		
		_ = DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config?.deviecLimitationSpaceMB ?? 100, turnOffTheCache: true, errorDelegate: delegate)
	}

    /// Closing the async socket if it is open and setting the chat shared instance to nil.
    /// You should take into consideration that if you need to work with this instance you should call the ``createChatObject(config:)`` method again.
    public func dispose() {
        asyncManager.disposeObject()
		Chat.instance = nil
		print("Disposed Singleton instance")
	}
	//**************************** Intitializers ****************************

    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getContacts(_ request:ContactsRequest, completion:@escaping PaginationCompletionType<[Contact]>, cacheResponse:PaginationCacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		GetContactsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}
	
    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer is the list of blocked contacts.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getBlockedContacts(_ request:BlockedListRequest, completion:@escaping PaginationCompletionType<[BlockedContact]>, uniqueIdResult: UniqueIdResultType = nil){
		GetBlockedContactsRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contact is added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addContact(_ request:AddContactRequest, completion:@escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType = nil){
        AddContactRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contacts are added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addContacts(_ request:[AddContactRequest], completion:@escaping CompletionType<[Contact]>, uniqueIdsResult:UniqueIdsResultType = nil){
        AddContactsRequestHandler.handle(request, self, completion, uniqueIdsResult)
	}
	
    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: List of last seen users with time attached to each item.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func contactNotSeen(_ request:NotSeenDurationRequest, completion:@escaping CompletionType<[UserLastSeenDuration]>, uniqueIdResult: UniqueIdResultType = nil){
		NotSeenContactRequestHandler.handle(request, self, completion , uniqueIdResult)
	}

    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeContact(_ request:RemoveContactsRequest, completion:@escaping CompletionType<Bool>, uniqueIdResult: UniqueIdResultType = nil){
		RemoveContactRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func searchContacts(_ request:ContactsRequest, completion:@escaping PaginationCompletionType<[Contact]>, cacheResponse: PaginationCacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        getContacts(request, completion: completion, cacheResponse:cacheResponse, uniqueIdResult: uniqueIdResult)
	}

    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    ///   - completion: The answer of synced contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func syncContacts(completion:@escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType = nil){
		SyncContactsRequestHandler.handle(self, completion, uniqueIdsResult)
	}

    /// Update a particular contact.
    ///
    /// Update name or other details of a contact.
    /// - Parameters:
    ///   - req: The request of what you need to be updated.
    ///   - completion: The list of updated contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func updateContact(_ req: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult:UniqueIdResultType = nil ){
		UpdateContactRequestHandler.handle(req, self, completion, uniqueIdsResult)
	}

    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func blockContact(_ request:BlockRequest, completion:@escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType = nil){
		BlockContactRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    ///   - completion: Reponse of before blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unBlockContact(_ request:UnBlockRequest, completion:@escaping CompletionType<BlockedContact>, uniqueIdResult:UniqueIdResultType = nil){
		UnBlockContactRequestHandler.handle(request,self,completion , uniqueIdResult)
	}

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    ///   - completion: Response of reverse address.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapReverse(_ request:MapReverseRequest, completion:@escaping CompletionType<MapReverse>, uniqueIdResult: UniqueIdResultType = nil){
		MapReverseRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    ///   - completion: Reponse of founded items.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapSearch(_ request:MapSearchRequest, completion:@escaping CompletionType<[MapItem]>, uniqueIdResult: UniqueIdResultType = nil){
		MapSearchRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapRouting(_ request:MapRoutingRequest, completion:@escaping CompletionType<[Route]>, uniqueIdResult: UniqueIdResultType = nil){
		MapRoutingRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    ///   - completion: Data of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapStaticImage(_ request:MapStaticImageRequest,completion:@escaping CompletionType<Data>,uniqueIdResult: UniqueIdResultType = nil){
		MapStaticImageRequestHandler.handle(request,self, completion, uniqueIdResult)
	}

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreads(_ request:ThreadsRequest, completion:@escaping PaginationCompletionType<[Conversation]>, cacheResponse: PaginationCacheResponseType<[Conversation]>? = nil,  uniqueIdResult: UniqueIdResultType = nil){
		GetThreadsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}

    /// Getting the all threads.
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: <#uniqueIdResult description#>
    public func getAllThreads(request:AllThreads, completion:@escaping CompletionType<[Conversation]>, cacheResponse:CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        GetAllThreadsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func isThreadNamePublic(_ request:IsThreadNamePublicRequest, completion:@escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType = nil){
		IsThreadNamePublicRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of mute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func muteThread(_ request:MuteUnmuteThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		MuteThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unmute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unmuteThread(_ request:MuteUnmuteThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		UnMuteThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of pin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func pinThread(_ request:PinUnpinThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		PinThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unpin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unpinThread(_ request:PinUnpinThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		UnPinThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    ///   - completion: Response to create thread which contains a ``Conversation`` that includes threadId and other properties.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createThread(_ request:CreateThreadRequest, completion:@escaping CompletionType<Conversation> ,uniqueIdResult: UniqueIdResultType = nil){
		CreateThreadRequestHandler.handle(request, self , completion , uniqueIdResult)
	}

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Call when message is snet.
    ///   - onDelivery:  Call when message deliverd but not seen yet.
    ///   - onSeen: Call when message is seen.
    ///   - completion: Response of request and created thread.
    public func createThreadWithMessage(_ request:CreateThreadWithMessage ,
                                        uniqueIdResult: UniqueIdResultType = nil,
                                        onSent:OnSentType = nil,
                                        onDelivery:OnDeliveryType = nil,
                                        onSeen: OnSentType = nil,
                                        completion:@escaping CompletionType<Conversation>){
        CreateThreadWithMessageRequestHandler.handle(request, self , completion , uniqueIdResult)
    }

    /// Create thread and send a file message.
    /// - Parameters:
    ///   - request: Request of craete thread.
    ///   - textMessage: Text message.
    ///   - uploadFile: File request.
    ///   - uploadProgress: Track the progress of uploading.
    ///   - onSent: Call when message is snet.
    ///   - onSeen: Call when message is seen.
    ///   - onDeliver: Call when message deliverd but not seen yet.
    ///   - createThreadCompletion: Call when the thread is created, and it's called before uploading gets completed
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createThreadWithFileMessage(_ request:CreateThreadRequest,
                                     textMessage:SendTextMessageRequest,
                                     uploadFile:UploadFileRequest,
                                     uploadProgress:UploadFileProgressType? = nil,
                                     onSent:OnSentType = nil,
                                     onSeen:OnSeenType = nil,
                                     onDeliver:OnDeliveryType = nil,
                                     createThreadCompletion:CompletionType<Conversation>? = nil,
                                     uploadUniqueIdResult: UniqueIdResultType = nil,
                                     messageUniqueIdResult: UniqueIdResultType = nil
                         
    ){
        CreateThreadWithFileMessageRequestHandler.handle(self, request, textMessage, uploadFile, uploadProgress, onSent, onSeen,onDeliver, createThreadCompletion, uploadUniqueIdResult, messageUniqueIdResult)
    }

    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addParticipant(_ request:AddParticipantRequest, completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle([request], self, completion, uniqueIdResult)
	}
	
    /// Add participants to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addParticipants(_ request:[AddParticipantRequest], completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
		AddParticipantsRequestHandler.handle(request, self, completion, uniqueIdResult)

	}

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    ///   - completion: Result of deleted participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeParticipants(_ request: RemoveParticipantsRequest, completion:@escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType = nil){
		RemoveParticipantsRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    ///   - completion: Detail of public thread as a ``Conversation`` object.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func joinThread(_ request:JoinPublicThreadRequest, completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
		JoinPublicThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    ///   - completion: The id of the thread which closed.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func closeThread(_ request:CloseThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		CloseThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func spamPvThread(_ request: SpamThreadRequest, completion:@escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType = nil){
        SpamThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: Upload progrees if you update image of the thread.
    ///   - completion: Response of update.
    public func updateThreadInfo(_ request:UpdateThreadInfoRequest, uniqueIdResult: UniqueIdResultType = nil, uploadProgress:@escaping UploadFileProgressType, completion:@escaping CompletionType<Conversation>){
        UpdateThreadInfoRequestHandler.handle(self, request, uploadProgress, completion, uniqueIdResult)
	}

    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    ///   - completion: The response of the left thread..
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func leaveThread(_ request:LeaveThreadRequest, completion:@escaping CompletionType<User>, uniqueIdResult: UniqueIdResultType = nil){
		LeaveThreadRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    ///   - completion: Result of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteThread(_ request:DeleteThreadRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
        DeleteThreadRequestHandler.handle(request, self, completion)
    }

    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    ///   - completion: Result of request.
    ///   - newAdminCompletion: Result of new admin.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func leaveThreadSaftly(_ request:SafeLeaveThreadRequest, completion:@escaping CompletionType<User>, newAdminCompletion:CompletionType<[UserRole]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        ReplaceAdminAndLeaveThreadRequestHandler.handle(request, self, completion, newAdminCompletion, uniqueIdResult)
    }

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreadParticipants(_ request:ThreadParticipantsRequest, completion:@escaping PaginationCompletionType<[Participant]>, cacheResponse: PaginationCacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        ThreadParticipantsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// Get thread participants.
    ///
    /// It's the same ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreadAdmins(_ request:ThreadParticipantsRequest, completion:@escaping PaginationCompletionType<[Participant]>, cacheResponse: PaginationCacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
        request.admin = true
        ThreadParticipantsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    ///   - completion: Response of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func changeThreadType(_ request:ChangeThreadTypeRequest, completion:@escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType = nil){
        ChangeThreadTypeRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createBot(_ request:CreateBotRequest, completion:@escaping CompletionType<Bot>, uniqueIdResult: UniqueIdResultType = nil){
		CreateBotRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addBotCommand(_ request:AddBotCommandRequest, completion:@escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType = nil){
		AddBotCommandRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Remove commands from a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeBotCommand(_ request:RemoveBotCommandRequest, completion:@escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType = nil){
        RemoveBotCommandRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getUserBots(_ request:GetUserBotsRequest, completion:@escaping CompletionType<[BotInfo]>, uniqueIdResult: UniqueIdResultType = nil){
        UserBotsBotsRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Start a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it starts successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func startBot(_ request:StartStopBotRequest, completion:@escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType = nil){
		StartBotRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it stopped successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func stopBot(_ request:StartStopBotRequest, completion:@escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType = nil){
		StopBotRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    ///   - completion: Response of the request.
    ///   - cacheResponse: cache response for the current user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getUserInfo(_ request:UserInfoRequest, completion:@escaping CompletionType<User>, cacheResponse: CacheResponseType<User>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		UserInfoRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}

    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    ///   - completion: New profile response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setProfile(_ request:UpdateChatProfile, completion:@escaping CompletionType<Profile>, uniqueIdResult: UniqueIdResultType = nil){
		UpdateChatProfileRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameter request: <#request description#>
    public func sendStatusPing(_ request:SendStatusPingRequest){
		SendStatusPingRequestHandler.handle(request, self)
	}

    /// List of Tags.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of request if you want to set a specific one.
    ///   - completion: List of tags.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func tagList(_ uniqueId:String? = nil, completion:@escaping CompletionType<[Tag]>, uniqueIdResult: UniqueIdResultType = nil){
        TagListRequestHandler.handle(uniqueId, self, completion, uniqueIdResult)
    }

    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    ///   - completion: Response of the request if tag added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createTag(_ request:CreateTagRequest, completion:@escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType = nil){
        CreateTagRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    ///   - completion: Response of the request if tag edited successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func editTag(_ request:EditTagRequest, completion:@escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType = nil){
        EditTagRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    ///   - completion: Response of the request if tag deleted successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteTag(_ request:DeleteTagRequest, completion:@escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType = nil){
        DeleteTagRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    ///   - completion: The response of the request which contains list of tagParticipants added.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addTagParticipants(_ request:AddTagParticipantsRequest, completion:@escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType = nil){
        AddTagParticipantsRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// Remove tag prticipants from a tag.
    /// - Parameters:
    ///   - request: The tag id and the list of tag participants id.
    ///   - completion: List of removed tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeTagParticipants(_ request:RemoveTagParticipantsRequest, completion:@escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType = nil){
        RemoveTagParticipantsRequestHandler.handle(request, self, completion, uniqueIdResult)
    }
    
    //Test Status: Main ❌ - Integeration: ❌
//    func getTagParticipants(_ request:GetTagParticipantsRequest ,completion:@escaping CompletionType<[Conversation]>,uniqueIdResult: UniqueIdResultType = nil){
//        GetTagParticipantsRequestHandler.handle(request, self , completion, uniqueIdResult)
//    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    public func sendTextMessage(_ request:SendTextMessageRequest, uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil, onSeen:OnSeenType = nil,  onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver, uniqueIdresult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    public func replyMessage(_ request:ReplyMessageRequest, uniqueIdresult:UniqueIdResultType = nil, onSent:OnSentType = nil, onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil){
        SendTextMessageRequestHandler.handle(request, self, onSent, onSeen, onDeliver, uniqueIdresult)
    }

    /// <#Description#>
    public func logOut() {
        LogoutRequestHandler.handle(self)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - downloadProgress: <#downloadProgress description#>
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    ///   - uploadUniqueIdResult: <#uploadUniqueIdResult description#>
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendLocationMessage( _ request:LocationMessageRequest,
                              uploadProgress:UploadFileProgressType? = nil,
                              downloadProgress:DownloadProgressType? = nil,
                              onSent:OnSentType = nil,
                              onSeen:OnSeenType = nil,
                              onDeliver:OnDeliveryType = nil,
                              uploadUniqueIdResult: UniqueIdResultType = nil,
                              messageUniqueIdResult: UniqueIdResultType = nil
                              ){
        SendLocationMessageRequestHandler.handle(self, request, downloadProgress, uploadProgress, onSent,onSeen, onDeliver, uploadUniqueIdResult, messageUniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func editMessage(_ request:EditMessageRequest, completion: CompletionType<Message>? = nil, uniqueIdResult:UniqueIdResultType = nil){
        EditMessageRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func forwardMessages(_ request:ForwardMessageRequest, onSent:OnSentType = nil, onSeen:OnSeenType = nil, onDeliver:OnDeliveryType = nil, uniqueIdsResult:UniqueIdsResultType = nil){
        ForwardMessagesRequestHandler.handle(request, self, onSent, onSeen, onDeliver, uniqueIdsResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - textMessageNotSentRequests: <#textMessageNotSentRequests description#>
    ///   - editMessageNotSentRequests: <#editMessageNotSentRequests description#>
    ///   - forwardMessageNotSentRequests: <#forwardMessageNotSentRequests description#>
    ///   - fileMessageNotSentRequests: <#fileMessageNotSentRequests description#>
    ///   - uploadFileNotSentRequests: <#uploadFileNotSentRequests description#>
    ///   - uploadImageNotSentRequests: <#uploadImageNotSentRequests description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getHistory(_ request:GetHistoryRequest ,
                    completion:@escaping PaginationCompletionType<[Message]> ,
                    cacheResponse: CacheResponseType<[Message]>? = nil,
                    textMessageNotSentRequests: CompletionType<[SendTextMessageRequest]>? = nil,
                    editMessageNotSentRequests: CompletionType<[EditMessageRequest]>? = nil,
                    forwardMessageNotSentRequests: CompletionType<[ForwardMessageRequest]>? = nil,
                    fileMessageNotSentRequests: CompletionType<[(UploadFileRequest , SendTextMessageRequest )]>? = nil,
                    uploadFileNotSentRequests: CompletionType<[UploadFileRequest]>? = nil,
                    uploadImageNotSentRequests: CompletionType<[UploadImageRequest]>? = nil,
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

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getHashtagList(_ request:GetHistoryRequest ,
                    completion:@escaping PaginationCompletionType<[Message]> ,
                    cacheResponse: CacheResponseType<[Message]>? = nil,
                    uniqueIdResult: UniqueIdResultType = nil){
        GetHistoryRequestHandler.handle(request,self,completion,cacheResponse,nil,nil,nil,nil,nil,nil,uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func pinMessage(_ request:PinUnpinMessageRequest, completion:@escaping CompletionType<PinUnpinMessage>, uniqueIdResult: UniqueIdResultType = nil){
		PinMessageRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unpinMessage(_ request:PinUnpinMessageRequest, completion:@escaping CompletionType<PinUnpinMessage>, uniqueIdResult: UniqueIdResultType = nil){
		UnPinMessageRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func clearHistory(_ request:ClearHistoryRequest, completion:@escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType = nil){
		ClearHistoryRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteMessage(_ request:DeleteMessageRequest, completion:@escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType = nil){
		DeleteMessageRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteMultipleMessages(_ request:BatchDeleteMessageRequest, completion:@escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType = nil){
		BatchDeleteMessageRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func allUnreadMessageCount(_ request:UnreadMessageCountRequest, completion:@escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		AllUnreadMessageCountRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getMentions(_ request:MentionRequest, completion:@escaping PaginationCompletionType<[Message]>, cacheResponse: PaginationCacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		MentionsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func messageDeliveryParticipants(_ request:MessageDeliveredUsersRequest, completion:@escaping PaginationCacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType = nil){
		MessageDeliveryParticipantsRequestHandler.handle(request, self, completion, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func messageSeenByUsers(_ request:MessageSeenByUsersRequest, completion:@escaping PaginationCacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType = nil){
		MessagSeenByUsersRequestHandler.handle(request, self, completion, uniqueIdResult)
	}
	
    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deliver(_ request:MessageDeliverRequest, uniqueIdResult: UniqueIdResultType = nil){
		DeliverRequestHandler.handle(request, self, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - uniqueIdResult: <#uniqueIdResult description#>
    public func seen(_ request:MessageSeenRequest, uniqueIdResult: UniqueIdResultType = nil){
		SeenRequestHandler.handle(request, self, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getCurrentUserRoles(_ request:CurrentUserRolesRequest, completion:@escaping CompletionType<[Roles]>, cacheResponse: CacheResponseType<[Roles]>? = nil, uniqueIdResult: UniqueIdResultType = nil){
		CurrentUserRolesRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
	}

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    public func cancelMessage(_ request:CancelMessageRequest, completion: @escaping CompletionType<Bool>){
        CancelMessageRequestHandler.handle(self, request, completion)
    }

    /// <#Description#>
    /// - Parameter threadId: <#threadId description#>
    public func snedStartTyping(threadId:Int){
        SendStartTypingRequestHandler.handle(threadId, self)
    }

    /// <#Description#>
    public func sendStopTyping(){
        SendStartTypingRequestHandler.stopTyping()
    }

    /// <#Description#>
    /// - Parameter req: <#req description#>
    public func sendSignalMessage(req: SendSignalMessageRequest) {
        prepareToSendAsync(req: req,
                           clientSpecificUniqueId: req.uniqueId,
                           subjectId: req.threadId,
                           pushMsgType: .MESSAGE,
                           messageType: .SYSTEM_MESSAGE )
    }

    /// <#Description#>
    /// - Parameters:
    ///   - req: <#req description#>
    ///   - downloadProgress: <#downloadProgress description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getFile(req              :FileRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadFileCompletionType,
                 cacheResponse    :@escaping DownloadFileCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadFileRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - req: <#req description#>
    ///   - downloadProgress: <#downloadProgress description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getImage(req             :ImageRequest,
                 downloadProgress :@escaping DownloadProgressType,
                 completion       :@escaping DownloadImageCompletionType,
                 cacheResponse    :@escaping DownloadImageCompletionType,
                 uniqueIdResult   :UniqueIdResultType       = nil
                 
    ){
        DownloadImageRequestHandler.download(req,uniqueIdResult,downloadProgress,completion,cacheResponse)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - req: <#req description#>
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - uploadCompletion: <#uploadCompletion description#>
    public func uploadFile(req                  :UploadFileRequest,
                    uploadUniqueIdResult :UniqueIdResultType       = nil,
                    uploadProgress       :UploadFileProgressType?  = nil,
                    uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadFileRequestHandler.uploadFile(self,req,uploadCompletion,uploadProgress,uploadUniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - req: <#req description#>
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - uploadCompletion: <#uploadCompletion description#>
    public func uploadImage(req                 :UploadImageRequest,
                     uploadUniqueIdResult :UniqueIdResultType       = nil,
                     uploadProgress       :UploadFileProgressType?  = nil,
                     uploadCompletion     :UploadCompletionType? = nil
    ){
        UploadImageRequestHandler.uploadImage(self,req,uploadCompletion,uploadProgress,uploadUniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - replyMessage: <#replyMessage description#>
    ///   - uploadFile: <#uploadFile description#>
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func replyFileMessage(replyMessage:ReplyMessageRequest,
                           uploadFile:UploadFileRequest,
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

    /// <#Description#>
    /// - Parameters:
    ///   - textMessage: <#textMessage description#>
    ///   - uploadFile: <#uploadFile description#>
    ///   - uploadProgress: <#uploadProgress description#>
    ///   - onSent: <#onSent description#>
    ///   - onSeen: <#onSeen description#>
    ///   - onDeliver: <#onDeliver description#>
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendFileMessage(textMessage:SendTextMessageRequest,
                         uploadFile:UploadFileRequest,
                         uploadProgress:UploadFileProgressType? = nil,
                         onSent:OnSentType = nil,
                         onSeen:OnSeenType = nil,
                         onDeliver:OnDeliveryType = nil,
                         uploadUniqueIdResult: UniqueIdResultType = nil,
                         messageUniqueIdResult: UniqueIdResultType = nil
                         ){
        if let uploadRequest = uploadFile as? UploadImageRequest {
            SendImageMessageRequest.handle(textMessage, uploadRequest, onSent, onSeen, onDeliver, uploadProgress, uploadUniqueIdResult, messageUniqueIdResult, self)
            return
        }
        SendFileMessageRequest.handle(textMessage, uploadFile, onSent , onSeen , onDeliver , uploadProgress , uploadUniqueIdResult , messageUniqueIdResult , self)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: <#action description#>
    ///   - isImage: <#isImage description#>
    ///   - completion: <#completion description#>
    public func manageUpload(uniqueId:String, action:DownloaUploadAction, isImage:Bool, completion:((String,Bool)->())? = nil){
        ManageUploadRequestHandler.handle(uniqueId, action, isImage, completion)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: <#action description#>
    ///   - isImage: <#isImage description#>
    ///   - completion: <#completion description#>
    public func manageDownload(uniqueId:String, action:DownloaUploadAction, isImage:Bool, completion:((String,Bool)->())? = nil){
        ManageDownloadRequestHandler.handle(uniqueId, action, isImage, completion)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: <#uniqueIdResult description#>
    public func registerAssistat(_ request:RegisterAssistantRequest, completion:@escaping CompletionType<[Assistant]>, uniqueIdResult : UniqueIdResultType = nil){
        RegisterAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: <#uniqueIdResult description#>
    public func deactiveAssistant(_ request:DeactiveAssistantRequest, completion:@escaping CompletionType<[Assistant]>, uniqueIdResult : UniqueIdResultType = nil){
        DeactiveAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getAssistats(_ request:AssistantsRequest, completion:@escaping PaginationCompletionType<[Assistant]>, cacheResponse: PaginationCompletionType<[Assistant]>? = nil, uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getAssistatsHistory(_ completion:@escaping CompletionType<[AssistantAction]>, uniqueIdResult : UniqueIdResultType = nil){
        GetAssistantsHistoryRequestHandler.handle(self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getBlockedAssistants(_ request:BlockedAssistantsRequest, _ completion:@escaping PaginationCompletionType<[Assistant]>, cacheResponse: PaginationCacheResponseType<[Assistant]>? = nil,  uniqueIdResult : UniqueIdResultType = nil){
        BlockedAssistantsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func blockAssistants(_ request:BlockUnblockAssistantRequest, _ completion:@escaping CompletionType<[Assistant]>, uniqueIdResult : UniqueIdResultType = nil){
        BlockAssistantRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unblockAssistants(_ request:BlockUnblockAssistantRequest, _ completion:@escaping CompletionType<[Assistant]>, uniqueIdResult : UniqueIdResultType = nil){
        UnBlockAssistatRequestHandler.handle(request, self, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setRoles(_ request:RolesRequest, _ completion:@escaping CompletionType<[UserRole]> , uniqueIdResult:UniqueIdResultType = nil){
        SetRoleRequestHandler.handle(self,request,completion,uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeRoles(_ request:RolesRequest, _ completion:@escaping CompletionType<[UserRole]>, uniqueIdResult:UniqueIdResultType){
        RemoveRoleRequestHandler.handle(self, request, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setAuditor(_ request:AuditorRequest, _ completion:@escaping CompletionType<[UserRole]>, uniqueIdResult:UniqueIdResultType){
        SetRoleRequestHandler.handle(self, request, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeAuditor(_ request:AuditorRequest, _ completion:@escaping CompletionType<[UserRole]>, uniqueIdResult:UniqueIdResultType){
        RemoveRoleRequestHandler.handle(self, request, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    ///   - cacheResponse: <#cacheResponse description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mutualGroups(_ request:MutualGroupsRequest, _ completion:@escaping PaginationCompletionType<[Conversation]>, cacheResponse :PaginationCacheResponseType<[Conversation]>? = nil, uniqueIdResult:UniqueIdResultType){
        MutualGroupsRequestHandler.handle(request, self, completion, cacheResponse, uniqueIdResult)
    }

    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - localIdentifire: <#localIdentifire description#>
    ///   - completion: <#completion description#>
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func exportChat(_ request:GetHistoryRequest, localIdentifire:String = "en_US", _ completion:@escaping CompletionType<URL>, uniqueIdResult:UniqueIdResultType = nil){
        ExportRequestHandler.handle(request, localIdentifire, self, completion, uniqueIdResult)
    }
	
	// REST API Request
    func restApiRequest<T:Decodable>(_ encodableRequest:BaseRequest ,
											 decodeType:T.Type,
											 url:String,
                                             bodyParameter:Bool = false,
											 method:HTTPMethod = .get,
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
    func prepareToSendAsync(        req                                    : Encodable?              = nil,
                                    clientSpecificUniqueId                 : String?                 = nil,
									//this sometimes use to send threadId with subjectId Key must fix from server to get threadId
                                    subjectId                              : Int?                    = nil,
                                    plainText                              : Bool                    = false,
                                    pushMsgType                            : AsyncMessageTypes?      = nil,
                                    messageType                            : ChatMessageVOTypes,
                                    messageMessageType                     : MessageType?            = nil,
                                    metadata                               : String?                 = nil,
                                    systemMetadata                         : String?                 = nil,
                                    repliedTo                              : Int?                    = nil,                                    
                                    uniqueIdResult                         : ((String)->())?         = nil,
                                    completion                             : ((ChatResponse)->())?   = nil,
                                    onSent                                 : OnSentType?             = nil,
                                    onDelivered                            : OnDeliveryType?         = nil,
                                    onSeen                                 : OnSeenType?             = nil
                                    ){
		guard let config = config else {return}
		let uniqueId = clientSpecificUniqueId ?? UUID().uuidString
		uniqueIdResult?(uniqueId)
		
        let chatMessage = SendChatMessageVO(type                               : messageType.rawValue,
                                            token                              : config.token,
                                            content                            : getContent(req , plainText),
                                            messageType                        : messageMessageType?.rawValue,
                                            metadata                           : metadata,
                                            repliedTo                          : repliedTo,
                                            systemMetadata                     : systemMetadata,
                                            subjectId                          : subjectId,
                                            typeCode                           : config.typeCode,
                                            uniqueId                           : uniqueId)
		
		guard let chatMessageContent = chatMessage.convertCodableToString() else{return}
		let asyncMessage = SendAsyncMessageVO(content:     chatMessageContent,
											  ttl: config.msgTTL,
                                              peerName:     config.asyncConfig.serverName,
											  priority:     config.msgPriority,
                                              pushMsgType: pushMsgType
		)
		
		
		callbacksManager.addCallback(uniqueId: uniqueId, requesType: messageType, callback: completion ,onSent: onSent , onDelivered: onDelivered , onSeen: onSeen)
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
	
	internal func sendToAsync(asyncMessageVO:SendAsyncMessageVO){
        guard let content = try? JSONEncoder().encode(asyncMessageVO) else { return }
        logger?.log(title: "send Message", jsonString: asyncMessageVO.string ?? "", receive: false)
        asyncManager.sendData(type: asyncMessageVO.pushMsgType ?? .MESSAGE, data: content)
	}
    
    public func setToken(newToken: String , reCreateObject:Bool = false) {
        token = newToken
        config?.token = newToken
        if reCreateObject{
            asyncManager.createAsync()
        }
    }
    
    internal func setUser(user:User){
        self.userInfo = user
    }
    
    func startCrashAnalytics() {
        // Config for Sentry 4.3.1
        do {
            Client.shared = try Client(dsn: "https://5e236d8a40be4fe99c4e8e9497682333:5a6c7f732d5746e8b28625fcbfcbe58d@chatsentryweb.sakku.cloud/4")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
    }
}
