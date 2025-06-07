//
//  EmptySpec.swift
//  Spec
//
//  Created by Hamed Hosseini on 6/7/25.
//

public extension Spec {
    static let empty: Spec = {
        return Spec(
            servers: [],
            server: .init(
                server: "",
                socket: "",
                sso: "",
                social: "",
                file: "",
                serverName: "",
                talk: "",
                talkback: "",
                log: "",
                neshan: "",
                neshanAPI: "",
                panel: ""
            ),
            paths: .init(
                social: .init(
                    listContacts: "",
                    addContacts: "",
                    updateContacts: "",
                    removeContacts: ""),
                podspace: .init(
                    download: .init(
                        thumbnail: "",
                        images: "", files: ""),
                    upload: .init(
                        images: "", files: "",
                        usergroupsFiles: "",
                        usergroupsImages: "")),
                neshan: .init(
                    reverse: "",
                    search: "",
                    routing: "",
                    staticImage: ""),
                sso: .init(
                    oauth: "",
                    token: "",
                    devices: "",
                    authorize: "",
                    clientId: ""),
                talkBack: .init(
                    updateImageProfile: "",
                    opt: "",
                    refreshToken: "",
                    verify: "",
                    authorize: "",
                    handshake: ""),
                talk: .init(
                    join: "",
                    redirect: ""),
                log: .init(talk: ""),
                panel: .init(info: "")),
            subDomains: .init(core: "", podspace: ""))
    }()
}
