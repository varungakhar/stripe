//
//  ErrorTests.swift
//  StripeTests
//
//  Created by Andrew Edwards on 2/27/18.
//

import XCTest
@testable import Stripe
@testable import Vapor

class ErrorTests: XCTestCase {
    let errorString = """
{
    "error": {
        "type": "card_error",
        "charge": "ch_12345",
        "message": "Sorry kiddo",
        "code": "invalid_swipe_data",
        "decline_code": "stolen_card",
        "param": "card_number"
    }
}
"""
    
    func testErrorParsedProperly() throws {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let body = HTTPBody(string: errorString)
            let futureError = try decoder.decode(StripeAPIError.self, from: body, on: EmbeddedEventLoop())
            
            futureError.do { (stripeError) in
                XCTAssertEqual(stripeError.error.type, .cardError)
                XCTAssertEqual(stripeError.error.charge, "ch_12345")
                XCTAssertEqual(stripeError.error.message, "Sorry kiddo")
                XCTAssertEqual(stripeError.error.code, .invalidSwipeData)
                XCTAssertEqual(stripeError.error.declineCode, .stolenCard)
                XCTAssertEqual(stripeError.error.param, "card_number")
                
                }.catch { (error) in
                    XCTFail("\(error.localizedDescription)")
            }
        }
        catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
}
