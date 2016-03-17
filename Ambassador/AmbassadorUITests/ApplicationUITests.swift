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
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["isUITesting"]
        app.launch()
        ambassadorLogin()
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
        
        app.otherElements.containingType(.NavigationBar, identifier:"MyTabBar").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Sign Up"].tap()
        XCTAssertEqual(app.keyboards.count, 0) // Checks to sure all textFields resigned firstResponder (that the keyboard is hidden)
    }
    
    func testBuyConversion() {
        app.tabBars.buttons["Buy Now"].tap()
        app.otherElements.containingType(.NavigationBar, identifier:"MyTabBar").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Buy Now"].tap()
        
        let doneButton = app.alerts["Purchase successful"].collectionViews.buttons["Done"]
        doneButton.tap()
        XCTAssertFalse(doneButton.exists)
    }
    
    func testSettingsPage() {
        app.tabBars.buttons["Settings"].tap()
        
        let element = app.otherElements.containingType(.NavigationBar, identifier:"Settings").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        element.childrenMatchingType(.Other).elementBoundByIndex(2).buttons["copyIcon"].tap()
        element.childrenMatchingType(.Other).elementBoundByIndex(4).buttons["copyIcon"].tap()
        
        app.buttons["Logout"].tap()
    }
}

// Helper Functions
extension ApplicationUITests {
    func ambassadorLogin() {
        if app.buttons["Sign In"].exists {
            let usernameTextField = app.textFields["Username"]
            usernameTextField.tap()
            usernameTextField.typeText("jake+test@getambassador.com")
            
            let passwordSecureTextField = app.secureTextFields["Password"]
            passwordSecureTextField.tap()
            passwordSecureTextField.typeText("p3opl3first409")
            app.buttons["Sign In"].tap()
        }
    }
}


