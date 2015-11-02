//
//  AmbassadorUITests.swift
//  AmbassadorUITests
//
//  Created by Jake Dunahee on 10/29/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

import XCTest

var app : XCUIApplication!

class AmbassadorUITests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        if app == nil {
            app = XCUIApplication()
            app.launchArguments = ["USE_MOCK_SERVER", "isUITesting"]
            app.launch()
            app.buttons["Button"].tap()
            
            while (app.otherElements["LoadingView"].exists) {
                let smallDelay = NSDate().dateByAddingTimeInterval(1)
                NSRunLoop.mainRunLoop().runUntilDate(smallDelay)
            }
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadRAF() {
        XCTAssert(app.staticTexts.elementMatchingType(XCUIElementType.StaticText, identifier: "urlLabel").exists)
        XCTAssert(app.staticTexts["Spread the word"].exists)
        XCTAssert(app.staticTexts["Refer a friend to get rewards"].exists)
    
        XCTAssertEqual(app.collectionViews.cells.count, 5)
        app.buttons["clipboard"].tap()
        XCTAssertEqual(app.staticTexts["lblCopied"].exists, true)
    }
    
    func testCopyButton() {
        app.buttons["clipboard"].tap()
        XCTAssertEqual(app.staticTexts["lblCopied"].exists, true)
    }
    
    func testFacebook() {
        let cell = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(0)
        cell.tap()
        
        let facebookNavigationBar = app.navigationBars["Facebook"]
        facebookNavigationBar.buttons["Cancel"].tap()
        
        cell.tap()
        facebookNavigationBar.buttons["Post"].tap()
        
        app.buttons["OKAY"].tap()
        XCTAssertEqual(app.buttons["OKAY"].exists, false)
    }
    
    func testTwitter() {
        let cell = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1)
        cell.tap()
        
        let twitterNavigationBar = app.navigationBars["Twitter"]
        twitterNavigationBar.buttons["Cancel"].tap()
        cell.tap()
        
        twitterNavigationBar.buttons["Post"].tap()
        app.buttons["OKAY"].tap()
        
    }
    
    func testLinkedIn() {
//        NSNull.setNilValueForKey("AMBLINKEDINSTORAGE")
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "AMBLINKEDINSTORAGE")
//        print("Value = %@", NSUserDefaults.standardUserDefaults().objectForKey("AMBLINKEDINSTORAGE"))
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(2).tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("developers@getambassador.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("domorefaster")
        app.buttons["Sign in and allow"].tap()
        app.tables["Empty list"].childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.TextView).element.tap()
        app.navigationBars["LinkedIn"].buttons["Post"].tap()
        app.buttons["OKAY"].tap()
        
    }
}
