//
// Created by Oleg on 09.02.23.
//

@testable import App
import XCTVapor

final class RedirectControllerTests: XCTestCase {
    let app = Application(.testing)

    deinit {
        app.shutdown()
    }

    override func setUpWithError() throws {
        try configure(app)
    }

    func testRedirect() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com", validUntil: nil, maxVisitsCount: nil))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            try app.test(.GET, "test", afterResponse: { res in
                XCTAssertEqual(res.status, .seeOther)
                XCTAssertEqual(res.headers.first(name: .location), "https://google.com")
            })
        })
    }

    func testRedirect_notFound() throws {
        try app.test(.GET, "test", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testRedirect_notActive() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com", validUntil: nil, maxVisitsCount: nil))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.PUT, "api/v1", beforeRequest: { req in
                try req.content.encode(UpdateAliasRequest(aliasID: aliasID, validUntil: nil, isActive: false, maxVisitsCount: nil))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)

                try app.test(.GET, "test", afterResponse: { res in
                    XCTAssertEqual(res.status, .notFound)
                })
            })
        })
    }

    func testRedirect_expired() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com", validUntil: nil, maxVisitsCount: nil))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.PUT, "api/v1", beforeRequest: { req in
                try req.content.encode(UpdateAliasRequest(aliasID: aliasID, validUntil: Date().addingTimeInterval(-1), isActive: nil, maxVisitsCount: nil))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)

                try app.test(.GET, "test", afterResponse: { res in
                    XCTAssertEqual(res.status, .notFound)
                })
            })
        })
    }

    func testVisitsCountRedirect() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com", validUntil: nil, maxVisitsCount: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            try app.test(.GET, "test", afterResponse: { res in
                XCTAssertEqual(res.status, .seeOther)
                XCTAssertEqual(res.headers.first(name: .location), "https://google.com")

                try app.test(.GET, "test", afterResponse: { res in
                    XCTAssertEqual(res.status, .notFound)
                })
            })
        })
    }

    func testVisitsCountRedirect_withUpdate() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com", validUntil: nil, maxVisitsCount: nil))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.GET, "test", afterResponse: { res in
                XCTAssertEqual(res.status, .seeOther)
                XCTAssertEqual(res.headers.first(name: .location), "https://google.com")

                try app.test(.PUT, "api/v1", beforeRequest: { req in
                    try req.content.encode(UpdateAliasRequest(aliasID: aliasID, validUntil: nil, isActive: nil, maxVisitsCount: 1))
                }, afterResponse: { res in
                    XCTAssertEqual(res.status, .ok)

                    try app.test(.GET, "test", afterResponse: { res in
                        XCTAssertEqual(res.status, .notFound)
                    })
                })
            })
        })
    }
}
