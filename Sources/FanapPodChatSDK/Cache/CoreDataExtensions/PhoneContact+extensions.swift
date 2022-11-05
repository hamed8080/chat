//
// PhoneContact+extensions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
// only use to fill data when query on user Device contact
struct PhoneContactModel {
    var cellphoneNumber: String?
    var email: String?
    var firstName: String?
    var lastName: String?

    func convertToAddRequest() -> AddContactRequest {
        AddContactRequest(cellphoneNumber: cellphoneNumber,
                          email: email,
                          firstName: firstName,
                          lastName: lastName)
    }
}

extension PhoneContact {
    static let crud = CoreDataCrud<PhoneContact>(entityName: "PhoneContact")

    func convertToContact() -> Contact {
        Contact(cellphoneNumber: cellphoneNumber,
                email: email,
                firstName: firstName,
                hasUser: false,
                lastName: lastName)
    }

    class func isContactChanged(_ cacheContact: Contact, phoneContactModel: PhoneContactModel) -> Bool {
        (cacheContact.email != phoneContactModel.email) ||
            (cacheContact.firstName != phoneContactModel.firstName) ||
            (cacheContact.lastName != phoneContactModel.lastName)
    }

    public class func savePhoneBookContact(contact: AddContactRequest) {
        if let contactCellphoneNumber = contact.cellphoneNumber {
            if let findedContact = PhoneContact.crud.find(keyWithFromat: "cellphoneNumber == %@", value: contactCellphoneNumber) {
                // update CoreData Model ,this is the coreData Model not need to be fetched from CoreData and after save all changes saved.
                findedContact.firstName = contact.firstName
                findedContact.lastName = contact.lastName
                findedContact.email = contact.email
            } else {
                // insert CoreData Model
                PhoneContact.crud.insert { phoneContactEntity in
                    phoneContactEntity.cellphoneNumber = contact.cellphoneNumber
                    phoneContactEntity.email = contact.email
                    phoneContactEntity.firstName = contact.firstName
                    phoneContactEntity.lastName = contact.lastName
                }
            }
        }
    }

    public class func updateOrInsertPhoneBooks(contacts: [AddContactRequest]) {
        for contact in contacts {
            savePhoneBookContact(contact: contact)
        }
    }
}
