//
//  BatchAddContactsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed on 1/18/22.
//

import Foundation

public class BatchAddContactsRequest: BaseRequest{
   
    
    
    public var firstNameList       :[String?]
    public var lastNameList        :[String?]
    public var cellphoneNumberList :[String?]
    public var emailList           :[String?]
    public var userNameList        :[String?]
    public var uniqueIdList        :[String?]
    
    public init(firstNameList         : [String?],
                  lastNameList        : [String?],
                  cellphoneNumberList : [String?],
                  emailList           : [String?],
                  userNameList        : [String?],
                  uniqueIdList        : [String?]
    ) {
        self.firstNameList       = firstNameList
        self.lastNameList        = lastNameList
        self.cellphoneNumberList = cellphoneNumberList
        self.emailList           = emailList
        self.userNameList        = userNameList
        self.uniqueIdList        = uniqueIdList
    }
    
    private enum CodingKeys : String ,CodingKey{
        case firstNameList       = "firstNameList"
        case lastNameList        = "lastNameList"
        case cellphoneNumberList = "cellphoneNumberList"
        case emailList           = "emailList"
        case userNameList        = "userNameList"
        case uniqueIdList        = "uniqueIdList"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(firstNameList, forKey: .firstNameList)
        try? container.encode(lastNameList, forKey: .lastNameList)
        try? container.encode(cellphoneNumberList, forKey: .cellphoneNumberList)
        try? container.encode(emailList, forKey: .emailList)
        try? container.encode(userNameList, forKey: .userNameList)
        try? container.encode(uniqueIdList, forKey: .uniqueIdList)
    }
}
