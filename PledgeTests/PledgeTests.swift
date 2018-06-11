//
//  PledgeTests.swift
//  PledgeTests
//
//  Created by Gajdosik,Marc A on 6/7/18.
//  Copyright © 2018 Gajdosik,Marc A. All rights reserved.
//

import XCTest
@testable import Pledge

class PledgeTests: XCTestCase {
    func test_pledgesAwait() {
        let prom = Pledge<String> { res, rej in
            res("lol")
        }
        let val = prom.await()
        XCTAssertTrue(val=="lol")
    }
    
    func test_pledgesAsyncIsh() {
        let prom = Pledge<String> { res, rej in
            res("lol")
        }
        prom.then({x in print(x)}).err({x in print(x)}).finally({x in print(x)})
        
        sleep(1)
        XCTAssertTrue(prom.returnedValue=="lol")
    }
    func test_pledgesAsyncIsh_EXTRA() {
        let prom = Pledge<String> { res, rej in
            res("lol")
        }
        prom.then({x in print(x)}).err({x in print(x)}).finally({x in print(x)})
        
        //sleep(1)
        //if main is blocked retVal will never propagate YO
        XCTAssertFalse(prom.returnedValue=="lol")
    }
}

