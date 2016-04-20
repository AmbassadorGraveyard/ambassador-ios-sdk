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
    func testIdentify() {
        app.tabBars.buttons["Identify"].tap()

        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        // Check to make sure we get an invalid email alert
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        let okayButton = app.alerts["Hold on!"].collectionViews.buttons["Okay"]
        okayButton.tap()
        
        // Type an invalid email
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("test")
        submitButton.tap()
        
        // Check to make sure we get an invalid email alert
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        okayButton.tap()
    
        // Type a valid email
        emailTextField.tap()
        emailTextField.typeText("@example.com")
        submitButton.tap()
        
        // Check to make sure we get a succes message
        XCTAssertTrue(app.alerts["Great!"].exists)
        let okayButton2 = app.alerts["Great!"].collectionViews.buttons["Okay"]
        okayButton2.tap()
    }
    
    func testConversion() {
        app.tabBars.buttons["Conversion"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let submitButton = elementsQuery.buttons["Submit"]
        submitButton.tap()
        
        // Checks to make sure we get blank fields error
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        let okayButton = app.alerts["Hold on!"].collectionViews.buttons["Okay"]
        okayButton.tap()
        
        // Type referrer email text
        let referrerTF = elementsQuery.textFields["Email *"]
        referrerTF.tap()
        referrerTF.typeText("jake@getambassador.com")
        
        // Type referred email text
        let referredEmailTextField = elementsQuery.textFields["Referred Email *"]
        referredEmailTextField.tap()
        referredEmailTextField.typeText("test")
        app.buttons["Return"].tap()
        
        
        // Type campaign ID text
        app.swipeUp()
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.textFields["Campaign *"].tap()
        
        app.tables.staticTexts["Jake+Test"].tap()
        
        // Type revenue amount
        let revenueAmtTextField = elementsQuery.textFields["Revenue Amount *"]
        revenueAmtTextField.tap()
        revenueAmtTextField.typeText("1.50")
        app.toolbars.buttons["Done"].tap()

        elementsQuery.buttons["Submit"].tap()
        
        // Checks to make sure we get invalid email error
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        app.alerts["Hold on!"].collectionViews.buttons["Okay"]
        okayButton.tap()
        
        referredEmailTextField.tap()
        referredEmailTextField.typeText("@example.com")
        app.buttons["Return"].tap()

        // Scroll down to submit button
        app.swipeUp()
        elementsQuery.buttons["Submit"].tap()
        
        // Checks to make sure that we got a success message
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectationForPredicate(existsPredicate, evaluatedWithObject: app.alerts["Great!"], handler: nil)
        waitForExpectationsWithTimeout(3, handler: nil)
        
        XCTAssertTrue(app.alerts["Great!"].exists)
        app.alerts["Great!"].collectionViews.buttons["Okay"].tap()
    }
    
    func testSettingsPage() {
        app.tabBars.buttons["Settings"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let jakeTestElementsQuery = scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Jake Test")
        jakeTestElementsQuery.childrenMatchingType(.Other).elementBoundByIndex(1).buttons["copyIcon"].tap()
        jakeTestElementsQuery.childrenMatchingType(.Other).elementBoundByIndex(3).buttons["copyIcon"].tap()
        scrollViewsQuery.otherElements.buttons["Logout"].tap()
    }
    
    func testColorPicker() {
        // Open color picker
        app.navigationBars["Refer a Friend"].buttons["Edit"].tap()
        app.tables.staticTexts["Test"].tap()
        app.scrollViews.otherElements.containingType(.Button, identifier:"Clear Image").childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        
        // Tap the color picker
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
        
        // Check to see if hex color code matches the color tapped
        let textField = app.textFields["hexTextField"]
        XCTAssertEqual(textField.value as? String, "#7783FF")
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


