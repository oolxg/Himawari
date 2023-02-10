//
// Created by Oleg on 09.02.23.
//

@testable import App
import XCTVapor

final class AliasControllerTests: XCTestCase {
    let app = Application(.testing)

    deinit {
        app.shutdown()
    }

    override func setUpWithError() throws {
        try configure(app)
    }

    func testCreateExactAlias() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testCreateExactAliasThatAlreadyExists() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            try app.test(.POST, "api/v1", beforeRequest: { req in
                try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .conflict)
            })
        })
    }

    func testCreateAliasWithPastDate() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(destination: "https://google.com", validUntil: Date().advanced(by: -60 * 3)))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testCreateRandomAlias() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testUpdateAlias_notFound() throws {
        try app.test(.PUT, "api/v1", beforeRequest: { req in
            try req.content.encode(UpdateAliasRequest(aliasID: UUID(), validUntil: Date().advanced(by: 60 * 3)))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testUpdateAlias() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.PUT, "api/v1", beforeRequest: { req in
                try req.content.encode(UpdateAliasRequest(aliasID: aliasID, validUntil: Date().advanced(by: 60 * 3)))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        })
    }

    func testUpdateAliasWithNoParams() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.PUT, "api/v1", beforeRequest: { req in
                try req.content.encode(UpdateAliasRequest(aliasID: aliasID))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .badRequest)
            })
        })
    }

    func testDeleteAlias() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.DELETE, "api/v1", beforeRequest: { req in
                try req.content.encode(DeleteAliasRequest(aliasID: aliasID))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        })
    }

    func testGetAlias() throws {
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        try app.test(.GET, "api/v1", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
