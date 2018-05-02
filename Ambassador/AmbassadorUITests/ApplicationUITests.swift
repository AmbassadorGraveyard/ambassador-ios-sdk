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
        // Tap identify in tabBar
        app.tabBars.buttons["Identify"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        
        // Type invalid email
        let emailTextField = elementsQuery.textFields["Email *"]
        emailTextField.tap()
        emailTextField.typeText("test")
        
        app.buttons["Done"].tap()
        
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"Identify").element.swipeUp()
        
        addUIInterruptionMonitor(withDescription: "Hold on!") { (alert) -> Bool in
            alert.buttons["Okay"].tap()
            return true
        }
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        // Check to make sure we get an invalid email alert
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        
        app.tap()
        
        // Fill out fields
        let firstNameField = elementsQuery.textFields["First Name"]
        firstNameField.tap()
        firstNameField.typeText("Test")
        
        let lastNameTextField = elementsQuery.textFields["Last Name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("McTest")
        
        let phoneTextField = elementsQuery.textFields["Phone"]
        phoneTextField.tap()
        phoneTextField.typeText("5555555555")
        
        let companyTextField = elementsQuery.textFields["Company"]
        companyTextField.tap()
        companyTextField.typeText("Ambassador")
        
        let streetTextField = elementsQuery.textFields["Street"]
        streetTextField.tap()
        streetTextField.typeText("Dream Street")
        
        let cityTextField = elementsQuery.textFields["City"]
        cityTextField.tap()
        cityTextField.typeText("Royal Oak")
        
        let stateTextField = elementsQuery.textFields["State"]
        stateTextField.tap()
        stateTextField.typeText("Michigan")
        
        app.buttons["Done"].tap()
        
        let postalTextField = elementsQuery.textFields["Postal Code"]
        postalTextField.tap()
        postalTextField.typeText("48076")
        
        app.toolbars.buttons["Done"].tap()
        
        let countryTextField = elementsQuery.textFields["Country"]
        countryTextField.tap()
        countryTextField.typeText("USA")
        
        // Type valid email
        emailTextField.tap()
        emailTextField.typeText("@example.com")
        
        app.buttons["Done"].tap()
        
        addUIInterruptionMonitor(withDescription: "Great!") { (alert) -> Bool in
            alert.buttons["Okay"].tap()
            return true
        }

        submitButton.tap()

        // TODO: mock identify
        // Check to make sure we get a succes message
        //XCTAssertTrue(app.alerts["Great!"].exists)
        app.tap()
    }
    
    func testConversion() {

        app.tabBars.buttons["Conversion"].tap()
        
        addUIInterruptionMonitor(withDescription: "Hold on!") { (alert) -> Bool in
            alert.buttons["Okay"].tap()
            return true
        }

        addUIInterruptionMonitor(withDescription: "Great!") { (alert) -> Bool in
            alert.buttons["Okay"].tap()
            return true
        }
        
        let elementsQuery = app.scrollViews.otherElements
        let submitButton = elementsQuery.buttons["Submit"]
        submitButton.tap()
        
        // Checks to make sure we get blank fields error
        XCTAssertTrue(app.alerts["Hold on!"].exists)
        app.tap()
        
        // Type referrer email text
        let referrerTF = app.scrollViews.otherElements.searchFields["referrerEmail"]
        referrerTF.tap()
        referrerTF.typeText("jake@getambassador.com")
        
        // Type referred email text
        let referredEmailTextField = app.scrollViews.otherElements.searchFields["referredEmail"]
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
        app.tap()
        
        referredEmailTextField.tap()
        referredEmailTextField.typeText("@example.com")
        app.buttons["Return"].tap()

        // Scroll down to submit button
        app.swipeUp()
        elementsQuery.buttons["Submit"].tap()
        
        // TODO: Mock identify call
        // Checks to make sure that we got a success message
        //let existsPredicate = NSPredicate(format: "exists == 1")
        //expectation(for: existsPredicate, evaluatedWith: app.alerts["Great!"], handler: nil)
        //waitForExpectations(timeout: 30, handler: nil)
        //XCTAssertTrue(app.alerts["Great!"].exists)
        app.tap()
    }
    
    func testSettingsPage() {
        app.tabBars.buttons["Settings"].tap()

        let scrollViewsQuery = app.scrollViews
        let jakeTestElementsQuery = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Jake Test")
        jakeTestElementsQuery.children(matching: .other).element(boundBy: 1).buttons["copyIcon"].tap()
        jakeTestElementsQuery.children(matching: .other).element(boundBy: 3).buttons["copyIcon"].tap()
        scrollViewsQuery.otherElements.buttons["Logout"].tap()
    }
    
    func testColorPicker() {
        // Open color picker
        app.navigationBars["Refer a Friend"].buttons["Edit"].tap()
        app.tables.staticTexts["Test"].tap()
        app.scrollViews.otherElements.containing(.button, identifier:"Clear Image").children(matching: .button).element(boundBy: 1).tap()
        
        // Tap the color picker
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element
        
        if (element.isHittable) {
            element.tap()
        }
        else {
            let coordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
        
        // Check to see if hex color code matches the color tapped
        let textField = app.textFields["hexTextField"]
        XCTAssertEqual(textField.value as? String, "#7783FF")
    }
}

// Helper Functions
extension ApplicationUITests {
    func ambassadorLogin() {
        if app.buttons["Sign In"].exists {
            // If the "Allow Notifications" alert is displayed click Allow
            addUIInterruptionMonitor(withDescription: "Notifications") { (alert) -> Bool in
                alert.buttons["Allow"].tap()
                return true
            }

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


