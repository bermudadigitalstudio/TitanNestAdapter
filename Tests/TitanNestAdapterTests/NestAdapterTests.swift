import TitanNestAdapter
import TitanCore
import Nest
import Inquiline
import XCTest

final class TitanNestAdapterTests: XCTestCase {
    var titanInstance: Titan!
    override func setUp() {
        titanInstance = Titan()
    }

    static var allTests: [(String, (TitanNestAdapterTests) -> () throws -> Void)] {
        return [
            ("testConvertingNestRequestToTitanRequest", testConvertingNestRequestToTitanRequest),
            ("testConvertingTitanResponseToNestResponse", testConvertingTitanResponseToNestResponse),
        ]
    }

    func testConvertingNestRequestToTitanRequest() {
        let body = "Some body goes here"
        let req = Inquiline.Request(method: "PATCH",
                                    path: "/complexPath/with/comps?query=string&value=stuff",
                                    headers: [("Accept", "application/json"), ("Content-Length", "\(body.utf8.count)")],
                                    content: body)
        var titanRequestConvertedFromNest: TitanCore.RequestType!
        titanInstance.addFunction { (request, response) -> (TitanCore.RequestType, TitanCore.ResponseType) in
            titanRequestConvertedFromNest = request
            return (request, response)
        }
        let app = toNestApplication(titanInstance.app)
        _ = app(req)
        XCTAssertNotNil(titanRequestConvertedFromNest)
        XCTAssertEqual(titanRequestConvertedFromNest.path, "/complexPath/with/comps?query=string&value=stuff")
        XCTAssertEqual(titanRequestConvertedFromNest.body, "Some body goes here")
        XCTAssertEqual(titanRequestConvertedFromNest.method, "PATCH")
        XCTAssertEqual(titanRequestConvertedFromNest.headers.first?.0, "Accept")
        XCTAssertEqual(titanRequestConvertedFromNest.headers.first?.1, "application/json")
    }

    func testConvertingTitanResponseToNestResponse() {
        let titanResponse = TitanCore.Response(code: 501, body: "Not implemented; developer is exceedingly lazy", headers: [("Cache-Control", "private")])        
        let nestResponseConvertedFromTitan: Nest.ResponseType
        titanInstance.addFunction { (request, response) -> (TitanCore.RequestType, TitanCore.ResponseType) in
            return (request, titanResponse)
        }
        let app = toNestApplication(titanInstance.app)
        let request = Inquiline.Request(method: "GET", path: "/")
        nestResponseConvertedFromTitan = app(request)
        XCTAssertNotNil(nestResponseConvertedFromTitan.body)
        XCTAssertTrue(nestResponseConvertedFromTitan.statusLine.hasPrefix("501"))
        XCTAssertEqual(nestResponseConvertedFromTitan.headers.count, 1)
        XCTAssertEqual(nestResponseConvertedFromTitan.headers.first?.0, "Cache-Control")
        XCTAssertEqual(nestResponseConvertedFromTitan.headers.first?.1, "private")
    }
}
