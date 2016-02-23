//
//  ApplicationUITests.swift
//  Ambassador
//
//  Created by Jake Dunahee on 1/13/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

import XCTest

class ApplicationUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        
        app = XCUIApplication()
        app.launchArguments = ["USE_MOCK_SERVER", "isUITesting"]
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

// UI Tests
extension ApplicationUITests {
    func testLogin() {
        app.tabBars.buttons["Login"].tap()
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("jake@getambassador.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("TestPassword")
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Login"].tap()
    }
    
    func testSignUpInstallConversion() {
        app.tabBars.buttons["Sign Up"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("jake@getambassador.com")
        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("testuser")
        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("testpassword")
        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Sign Up"].tap()
        XCTAssertEqual(app.keyboards.count, 0) // Checks to sure all textFields resigned firstResponder (that the keyboard is hidden)
    }
    
    func testBuyConversion() {
        app.tabBars.buttons["Buy Now"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Buy Now"].tap()
        
        let doneButton = app.alerts["Purchase successful"].collectionViews.buttons["Done"]
        doneButton.tap()
        XCTAssertFalse(doneButton.exists)
    }
}
