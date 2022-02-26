//
//  SyncContactsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts
class SyncContactsRequestHandler {
	
	private init(){}
	
    class func handle(_ chat:Chat,
                      _ syncedPart: CompletionType<[Contact]>? = nil,
                      _ completion: CompletionType<Bool>? = nil,
                      _ uniqueIdsResult:UniqueIdsResultType = nil) {
		
		var contactsToSync:[NewAddContactRequest] = []
		authorizeContactAccess(grant: { store in
			let phoneContacts = SyncContactsRequestHandler.getContactsFromAuthorizedStore(store)
			let cachePhoneContacts = PhoneContact.crud.getAll().map {$0.convertToContact()}
			phoneContacts.forEach { phoneContact in
				if let findedContactCache = cachePhoneContacts.first(where: {$0.cellphoneNumber == phoneContact.cellphoneNumber}){
					if (PhoneContact.isContactChanged(findedContactCache, phoneContactModel: phoneContact)) {
						contactsToSync.append(phoneContact.convertToAddRequest())
					}
				}else{
					contactsToSync.append(phoneContact.convertToAddRequest())
				}
			}
			var uniqueIds:[String] = []
			contactsToSync.forEach { contact in
                uniqueIds.append(contact.uniqueId)
			}
            
            //No new contact or changes found
			if contactsToSync.count <= 0 {
                completion?(true, nil, nil)
                return
            }

            contactsPsrts = splitContactsToSync(contactsToSync)
            startMultipartAddContactRequest(index: 0, completedPart: syncedPart, completed: completion)
			uniqueIdsResult?(uniqueIds)

		},errorResult:{error in
            Chat.sharedInstance.logger?.log(title: "authorize error", message: "\(error)")
		})
	}
	
	
	private class func getContactsFromAuthorizedStore(_ store:CNContactStore) -> [PhoneContactModel] {
		var phoneContacts:[PhoneContactModel] = []
		let keys = [CNContactGivenNameKey,
					CNContactFamilyNameKey,
					CNContactPhoneNumbersKey,
					CNContactEmailAddressesKey]
		let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
		
		try? store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
			var phoneContactModel = PhoneContactModel()
			phoneContactModel.cellphoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
			phoneContactModel.firstName       = contact.givenName
			phoneContactModel.lastName        = contact.familyName
			phoneContactModel.email           = contact.emailAddresses.first?.value as String?
			phoneContacts.append(phoneContactModel)
		})
		return phoneContacts
	}
	
	private class func authorizeContactAccess(grant: @escaping (CNContactStore)->() , errorResult:((Error)->())? = nil){
		let store = CNContactStore()
		store.requestAccess(for: .contacts) { (granted, error) in
			if let error = error {
				errorResult?(error)
				return
			}
			if granted {
				grant(store)
			}
		}
	}
    
    
    static let chunkCount = 50
    class func splitContactsToSync(_ contacts:[NewAddContactRequest]) -> [[NewAddContactRequest]]{
        return contacts.chunked(into: Chat.chunkCount)
    }
    
    static var contactsPsrts:[[NewAddContactRequest]] = []
    static var contactSyncIndex = 0
    class func startMultipartAddContactRequest(index:Int = 0, completedPart: CompletionType<[Contact]>?, completed: CompletionType<Bool>?){
        if index <= contactsPsrts.count - 1{
            let chunk = contactsPsrts[index]
            
            Chat.sharedInstance.addContacts(chunk) { response,uniqueIds,error  in
                
                if let error = error {
                    completedPart?(response, nil, error)
                }else {
                    PhoneContact.updateOrInsertPhoneBooks(contacts:chunk)
                    PSM.shared.save()
                    completedPart?(response,nil,nil)
                }
                contactSyncIndex += 1
                startMultipartAddContactRequest(index: contactSyncIndex,completedPart: completedPart, completed: completed)
            }
        }else {
            //completed
            completed?(true, nil, nil)
            contactsPsrts = []
            contactSyncIndex = 0            
        }
    }
    
}
