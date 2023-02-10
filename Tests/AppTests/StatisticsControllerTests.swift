//
// Created by Oleg on 10.02.23.
//

@testable import App
import XCTVapor

final class StatisticsControllerTests: XCTestCase {
    let app = Application(.testing)

    deinit {
        app.shutdown()
    }

    override func setUpWithError() throws {
        try configure(app)
    }

    func testGetVisits() throws {
        let expected = Visit(aliasID: UUID(), ip: "127.0.0.1", userAgent: "Test User Agent")
        let expectedIP = "145.145.145.145"
        
        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let aliasID = try res.content.decode(URLAlias.self).id!

            try app.test(.GET, "test", beforeRequest: { req in
                req.headers.add(name: .userAgent, value: expected.userAgent!)
                req.headers.add(name: "CF-Connecting-IP", value: expectedIP)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .seeOther)
                XCTAssertEqual(res.headers.first(name: .location), "https://google.com")

                try app.test(.GET, "stat/\(aliasID)", afterResponse: { res in
                    XCTAssertEqual(res.status, .ok)

                    let visits = try res.content.decode([Visit].self)
                    XCTAssertEqual(visits.count, 1)
                    XCTAssertEqual(visits[0].ip, expectedIP)
                    XCTAssertEqual(visits[0].$parentAlias.id, aliasID)
                    XCTAssertEqual(visits[0].userAgent, expected.userAgent)
                })
            })
        })
    }

    func testGetVisits_notFound() throws {
        try app.test(.GET, "stat/00000000-0000-0000-0000-000000000000", beforeRequest: { req in
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testGetAllVisits() throws {
        let expected1 = Visit(aliasID: UUID(), ip: "145.145.145.145", userAgent: "Test User Agent1")
        let expected2 = Visit(aliasID: UUID(), ip: "144.144.144.144", userAgent: "Test User Agent")

        try app.test(.POST, "api/v1", beforeRequest: { req in
            try req.content.encode(CreateAliasRequest(alias: "test1", destination: "https://google.com"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let aliasID2 = try res.content.decode(URLAlias.self).id!

            try app.test(.POST, "api/v1", beforeRequest: { req in
                try req.content.encode(CreateAliasRequest(alias: "test2", destination: "https://bing.com"))
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let aliasID1 = try res.content.decode(URLAlias.self).id!
                
                try app.test(.GET, "test1", beforeRequest: { req in
                    req.headers.add(name: .userAgent, value: expected1.userAgent!)
                    req.headers.add(name: "CF-Connecting-IP", value: expected1.ip!)
                }, afterResponse: { res in
                    XCTAssertEqual(res.status, .seeOther)
                    XCTAssertEqual(res.headers.first(name: .location), "https://google.com")

                    try app.test(.GET, "test2", beforeRequest: { req in
                        req.headers.add(name: .userAgent, value: expected2.userAgent!)
                        req.headers.add(name: "CF-Connecting-IP", value: expected2.ip!)
                    }, afterResponse: { res in
                        XCTAssertEqual(res.status, .seeOther)
                        XCTAssertEqual(res.headers.first(name: .location), "https://bing.com")

                        try app.test(.GET, "stat") { res in
                            XCTAssertEqual(res.status, .ok)

                            let visits = try res.content.decode([Visit].self)
                            XCTAssertEqual(visits.count, 2)
                            XCTAssertEqual(visits[1].ip, expected1.ip)
                            XCTAssertEqual(visits[1].userAgent, expected1.userAgent)
                            XCTAssertEqual(visits[1].$parentAlias.id, aliasID2)
                            XCTAssertEqual(visits[0].ip, expected2.ip)
                            XCTAssertEqual(visits[0].userAgent, expected2.userAgent)
                            XCTAssertEqual(visits[0].$parentAlias.id, aliasID1)
                        }
                    })
                })
            })
        })
    }
}
