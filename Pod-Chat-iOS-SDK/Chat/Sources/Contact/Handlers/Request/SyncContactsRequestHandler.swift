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
                      _ completion:@escaping CompletionType<[Contact]>,
                      _ uniqueIdsResult:UniqueIdsResultType = nil) {
		
		var contactsToSync:[AddContactRequest] = []
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
			if contactsToSync.count <= 0 {return}

            chat.addContacts(contactsToSync) { response,uniqueIds,error  in
				if let error = error {
                    completion(response, nil, error)
                }else {
                    PhoneContact.updateOrInsertPhoneBooks(contacts:contactsToSync)
                    PSM.shared.save()
                    completion(response,nil,nil)
                }
			}
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
}
