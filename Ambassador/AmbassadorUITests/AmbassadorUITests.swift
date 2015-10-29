//
//  AmbassadorUITests.swift
//  AmbassadorUITests
//
//  Created by Jake Dunahee on 10/29/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

import XCTest

class AmbassadorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadRAF() {
        
        let app = XCUIApplication()
        let button = app.buttons["Button"]
        button.tap()
        
        let referYourFriendsNavigationBar = app.navigationBars["Refer your friends"]
        let closeButton = referYourFriendsNavigationBar.buttons["close"]
        closeButton.tap()
        button.tap()
        app.buttons["clipboard"].tap()
        referYourFriendsNavigationBar.tap()
        button.tap()
        referYourFriendsNavigationBar.tap()
        button.tap()
        closeButton.tap()
        button.tap()
        closeButton.tap()
        button.tap()
        referYourFriendsNavigationBar.tap()
        button.tap()
        referYourFriendsNavigationBar.tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).tap()
        button.tap()
        closeButton.tap()
        button.tap()
        closeButton.tap()
        button.tap()
        closeButton.tap()
        button.tap()
        
        
    }
    
}
