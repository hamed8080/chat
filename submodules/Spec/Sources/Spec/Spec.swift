//
//  Spe.swift
//  Spec
//
//  Created by Hamed Hosseini on 3/1/25.
//

import Foundation

public struct Spec: Codable, Sendable {
    public static let version = 1.0
    public let servers: [Server]
    public let server: Server
    public let paths: Paths
    public let subDomains: SubDomains
    
    public init(servers: [Server], server: Server, paths: Paths, subDomains: SubDomains) {
        self.servers = servers
        self.paths = paths
        self.server = server
        self.subDomains = subDomains
    }
    
    private enum CodingKeys: String, CodingKey {
        case servers = "servers"
        case server = "server"
        case paths = "paths"
        case subDomains = "subDomains"
    }
}

public struct Server: Codable, Sendable {
    public let server: String
    public let socket: String
    public let sso: String
    public let social: String
    public let file: String
    public let serverName: String
    public let talk: String
    public let talkback: String
    public let log: String
    public let neshan: String
    public let neshanAPI: String
    public let panel: String
    
    public init(server: String, socket: String, sso: String, social: String, file: String, serverName: String, talk: String, talkback: String, log: String, neshan: String, neshanAPI: String, panel: String) {
        self.server = server
        self.socket = socket
        self.sso = sso
        self.social = social
        self.file = file
        self.serverName = serverName
        self.talk = talk
        self.talkback = talkback
        self.log = log
        self.neshan = neshan
        self.neshanAPI = neshanAPI
        self.panel = panel
    }
    
    private enum CodingKeys: String, CodingKey {
        case server = "server"
        case socket = "socket"
        case sso = "sso"
        case social = "social"
        case file = "file"
        case serverName = "serverName"
        case talk = "talk"
        case talkback = "talkback"
        case log = "log"
        case neshan = "neshan"
        case neshanAPI = "neshanAPI"
        case panel = "panel"
    }
}

public struct SocialPaths: Codable, Sendable {
    public let listContacts: String
    public let addContacts: String
    public let updateContacts: String
    public let removeContacts: String
    
    public init(listContacts: String, addContacts: String, updateContacts: String, removeContacts: String) {
        self.listContacts = listContacts
        self.addContacts = addContacts
        self.updateContacts = updateContacts
        self.removeContacts = removeContacts
    }
    
    private enum CodingKeys: String, CodingKey {
        case listContacts = "listContacts"
        case addContacts = "addContacts"
        case updateContacts = "updateContacts"
        case removeContacts = "removeContacts"
    }
}

public struct PodspaceDownloadPaths: Codable, Sendable {
    public let thumbnail: String
    public let images: String
    public let files: String
    
    public init(thumbnail: String, images: String, files: String) {
        self.thumbnail = thumbnail
        self.images = images
        self.files = files
    }
    
    private enum CodingKeys: String, CodingKey {
        case thumbnail = "thumbnail"
        case images = "images"
        case files = "files"
    }
}

public struct PodspaceUploadPaths: Codable, Sendable {
    public let images: String
    public let files: String
    public let usergroupsFiles: String
    public let usergroupsImages: String
    
    public init(images: String, files: String, usergroupsFiles: String, usergroupsImages: String) {
        self.images = images
        self.files = files
        self.usergroupsFiles = usergroupsFiles
        self.usergroupsImages = usergroupsImages
    }
    
    private enum CodingKeys: String, CodingKey {
        case images = "images"
        case files = "files"
        case usergroupsFiles = "usergroupsFiles"
        case usergroupsImages = "usergroupsImages"
    }
}

public struct PodspacePaths: Codable, Sendable {
    public let download: PodspaceDownloadPaths
    public let upload: PodspaceUploadPaths
    
    public init(download: PodspaceDownloadPaths, upload: PodspaceUploadPaths) {
        self.download = download
        self.upload = upload
    }
    
    private enum CodingKeys: String, CodingKey {
        case download = "download"
        case upload = "upload"
    }
}

public struct NeshanPaths: Codable, Sendable {
    public let reverse: String
    public let search: String
    public let routing: String
    public let staticImage: String
    
    public init(reverse: String, search: String, routing: String, staticImage: String) {
        self.reverse = reverse
        self.search = search
        self.routing = routing
        self.staticImage = staticImage
    }
    
    private enum CodingKeys: String, CodingKey {
        case reverse = "reverse"
        case search = "search"
        case routing = "routing"
        case staticImage = "staticImage"
    }
}

public struct SSOPaths: Codable, Sendable {
    public let oauth: String
    public let token: String
    public let devices: String
    public let authorize: String
    public let clientId: String
    
    public init(oauth: String, token: String, devices: String, authorize: String, clientId: String) {
        self.oauth = oauth
        self.token = token
        self.devices = devices
        self.authorize = authorize
        self.clientId = clientId
    }
    
    private enum CodingKeys: String, CodingKey {
        case oauth = "oauth"
        case token = "token"
        case devices = "devices"
        case authorize = "authorize"
        case clientId = "clientId"
    }
}

public struct TalkBackPaths: Codable, Sendable {
    public let updateImageProfile: String
    public let opt: String
    public let refreshToken: String
    public let verify: String
    public let authorize: String
    public let handshake: String
    
    public init(updateImageProfile: String, opt: String, refreshToken: String, verify: String, authorize: String, handshake: String) {
        self.updateImageProfile = updateImageProfile
        self.opt = opt
        self.refreshToken = refreshToken
        self.verify = verify
        self.authorize = authorize
        self.handshake = handshake
    }
    
    private enum CodingKeys: String, CodingKey {
        case updateImageProfile = "updateImageProfile"
        case opt = "opt"
        case refreshToken = "refreshToken"
        case verify = "verify"
        case authorize = "authorize"
        case handshake = "handshake"
    }
}

public struct TalkPaths: Codable, Sendable {
    public let join: String
    public let redirect: String
    
    public init(join: String, redirect: String) {
        self.join = join
        self.redirect = redirect
    }
    
    private enum CodingKeys: String, CodingKey {
        case join = "join"
        case redirect = "redirect"
    }
}

public struct LogPaths: Codable, Sendable {
    public let talk: String
    
    public init(talk: String) {
        self.talk = talk
    }
    
    private enum CodingKeys: String, CodingKey {
        case talk = "talk"
    }
}

public struct PanelPaths: Codable, Sendable {
    public let info: String
    
    public init(info: String) {
        self.info = info
    }
    
    private enum CodingKeys: String, CodingKey {
        case info = "info"
    }
}

public struct Paths: Codable, Sendable {
    public let social: SocialPaths
    public let podspace: PodspacePaths
    public let neshan: NeshanPaths
    public let sso: SSOPaths
    public let talkBack: TalkBackPaths
    public let talk: TalkPaths
    public let log: LogPaths
    public let panel: PanelPaths
    
    public init(social: SocialPaths, podspace: PodspacePaths, neshan: NeshanPaths, sso: SSOPaths, talkBack: TalkBackPaths, talk: TalkPaths, log: LogPaths, panel: PanelPaths) {
        self.social = social
        self.podspace = podspace
        self.neshan = neshan
        self.sso = sso
        self.talkBack = talkBack
        self.talk = talk
        self.log = log
        self.panel = panel
    }
    
    private enum CodingKeys: String, CodingKey {
        case social = "social"
        case podspace = "podspace"
        case neshan = "neshan"
        case sso = "sso"
        case talkBack = "talkBack"
        case talk = "talk"
        case log = "log"
        case panel = "panel"
    }
}

public struct SubDomains: Codable, Sendable {
    public let core: String
    public let podspace: String
    
    public init(core: String, podspace: String) {
        self.core = core
        self.podspace = podspace
    }
    private enum CodingKeys: String, CodingKey {
        case core = "core"
        case podspace = "podspace"
    }
}
