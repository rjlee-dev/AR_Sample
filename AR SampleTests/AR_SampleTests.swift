//
//  AR_SampleTests.swift
//  AR SampleTests
//
//  Created by Richard Jason Lee on 2023-06-19.
//

import XCTest
@testable import AR_Sample

final class AR_SampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
       struct MyObject {
           let name: String
           let age: Int

           init(name: String, age: Int) {
               self.name = name
               self.age = age
           }
       }

       let namesArray = ["John", "Jane", "Adam"]
       let ageArray = [30,25,34]
       
       
       let tupleArray = [("John", 30), ("Jane", 25), ("Adam", 35)]

       
       
       
       let objectArray = zip(namesArray, ageArray).map(MyObject.init)

       let nameKeyPath = \MyObject.name
       let names = objectArray.map(\.name)
       
       print(names)
       for obj in objectArray {
           print("Name: \(obj.name), Age: \(obj.age)")
       }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
