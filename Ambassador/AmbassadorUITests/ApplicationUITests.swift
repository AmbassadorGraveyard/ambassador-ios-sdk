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
        
        if app == nil {
            app = XCUIApplication()
            app.launchArguments = ["USE_MOCK_SERVER", "isUITesting"]
            app.launchEnvironment = ["AutoCorrection": "Disabled"]
            app.launch()
//            identifyWithLogin()
        }
        
        // Checks to see if the RAF is still up and dismisses it if so
        if XCUIApplication().navigationBars["Refer a Friend!"].exists {
            XCUIApplication().navigationBars["Refer a Friend!"].childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

// UI Tests
extension ApplicationUITests {
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

// Helper Functions
extension ApplicationUITests {
    func testIdentifyWithLogin() {
        app.tabBars.buttons["Login"].tap()
        let loginButton = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Login"]
        loginButton.tap()
        app.alerts["Cannot log in"].collectionViews.buttons["Okay"].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("jake")
        
        let moreNumbersKey = app.keys["more, numbers"]
        moreNumbersKey.tap()
        usernameTextField.typeText("@")
        
        let moreLettersKey = app.keys["more, letters"]
        moreLettersKey.tap()
        usernameTextField.typeText("getambassador")
        moreNumbersKey.tap()
        usernameTextField.typeText(".")
        moreLettersKey.tap()
        usernameTextField.typeText("com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("test")
        loginButton.tap()
        
        
        
        
//        XCTAssertEqual(app.keyboards.count, 0) // Checks to sure all textFields resigned firstResponder (that the keyboard is hidden)
        
//        let app = XCUIApplication()
//        app.tabBars.buttons["Login"].tap()
//        
//        let usernameTextField = app.textFields["Username"]
//        usernameTextField.tap()
//        usernameTextField.typeText("jake@getambassador.com")
//        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
//        
//        let passwordSecureTextField = app.secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.typeText("testpassword")
//
//        
//        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Login"].tap()
//        XCTAssertEqual(app.keyboards.count, 0) // Checks to sure all textFields resigned firstResponder (that the keyboard is hidden)
    }
}
