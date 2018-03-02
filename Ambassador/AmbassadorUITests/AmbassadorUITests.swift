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
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["isUITesting"]
        app.launch()
        presentRAF()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// UI Tests
extension AmbassadorUITests {
    func testLoadRAF() {
        // When the RAF page is hit, we check to make sure that all of the correct labels are shown
        XCTAssert(app.staticTexts.element(matching: XCUIElementType.staticText, identifier: "urlLabel").exists)
        
        // Check to make sure there are the correct number of cells in the collectionView
        XCTAssertEqual(app.collectionViews.cells.count, 5)
    }

    func testCopyButton() {
        // Tap the copy button and make sure that the copied label is shown on the screen
        XCUIApplication().buttons["btnEdit"].tap()
        
        // Added half second wait to check for copied label
        RunLoop.main.run(until: NSDate().addingTimeInterval(0.5) as Date)
        XCTAssertTrue(app.staticTexts["Copied!"].exists)
    }

    func testFacebook() {
        // Tap the facebook cell
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()

        // Check the alert text
        XCTAssertTrue(app.staticTexts["Make sure you have Facebook installed and are logged in to continue."].exists)

        // Close the alert
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()

//        RunLoop.main.run(until: NSDate().addingTimeInterval(3) as Date)
//
//        if app.alerts["Make sure you have Facebook installed and are logged in to continue."].exists {
//            let cancelButton = app.alerts["No Facebook Account"].collectionViews.buttons["Cancel"]
//            cancelButton.tap()
//        } else {
//            // First make sure that the cancel button functions correctly
//            let facebookNavigationBar = app.navigationBars["Facebook"]
//            facebookNavigationBar.buttons["Cancel"].tap()
//
//            // Tap the facebook cell again, but this time post the message
//            app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
//            facebookNavigationBar.buttons["Post"].tap()
//
//            // Tap the OKAY button and assure that the success screen is hidden
//            app.buttons["OKAY"].tap()
//            XCTAssertEqual(app.buttons["OKAY"].exists, false)
//        }
    }

    func testTwitter() {
        // Tap the twitter cell
        app.collectionViews.children(matching: .cell).element(boundBy: 1).tap()

        // Check the alert text
        XCTAssertTrue(app.staticTexts["Make sure you have Twitter installed and are logged in to continue."].exists)

        // Close the alert
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()

//        RunLoop.main.run(until: NSDate().addingTimeInterval(3) as Date)
//
//        if app.alerts["No Twitter Accounts"].exists {
//            app.alerts["No Twitter Accounts"].collectionViews.buttons["Cancel"].tap()
//        } else {
//            // Make sure that the cancel button works correctly with the twitter alertcontroller
//            let twitterNavigationBar = app.navigationBars["Twitter"]
//            twitterNavigationBar.buttons["Cancel"].tap()
//
//            // Now we tap the twitter cell again and Post
//            app.collectionViews.children(matching: .cell).element(boundBy: 1).tap()
//            twitterNavigationBar.buttons["Post"].tap()
//
//            // If we get an alert about duplicate tweets, we will press the OK button in the alertcontroller
//            if app.alerts.element(boundBy: 0).exists { app.buttons["OK"].tap() }
//
//            // Tap OKAY on the success message and check that the message went away
//            app.buttons["OKAY"].tap()
//            XCTAssertEqual(app.buttons["OKAY"].exists, false)
//        }
    }
    
    func testSMS() {
        // If the "Contacts Access" alert is displayed click Ok
        addUIInterruptionMonitor(withDescription: "Contacts") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }

        // Tap the SMS cell
        app.collectionViews.children(matching: .cell).element(boundBy: 3).tap()
        
        // Select 3 contacts and then unselect one
        let tablesQuery = app.tables
        tablesQuery.staticTexts.element(boundBy: 0).tap()
        tablesQuery.staticTexts.element(boundBy: 1).tap()
        tablesQuery.staticTexts.element(boundBy: 2).tap()
        tablesQuery.staticTexts.element(boundBy: 1).doubleTap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Make sure the call goes through by checking for success message
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["Message successfully shared!"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        app.buttons["OKAY"].tap()
    }
    
    func testEmail() {
        // If the "Contacts Access" alert is displayed click Ok
        addUIInterruptionMonitor(withDescription: "Contacts") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }

        // Tap email cell
        app.collectionViews.children(matching: .cell).element(boundBy: 4).tap()
        
        // Select some contacts
        let tablesQuery = app.tables
        tablesQuery.staticTexts.element(boundBy: 0).tap()
        tablesQuery.staticTexts.element(boundBy: 1).tap()
        
        tablesQuery.staticTexts.element(boundBy: 3).tap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Check for message success
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["Message successfully shared!"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        app.buttons["OKAY"].tap()
    }
    
    func testSearch() {
        // If the "Contacts Access" alert is displayed click Ok
        addUIInterruptionMonitor(withDescription: "Contacts") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }

        // Tap sms cell
        app.collectionViews.children(matching: .cell).element(boundBy: 3).tap()
        
        // Search for anna
        let searchContactsTextField = app.textFields["Search Contacts"]
        searchContactsTextField.tap()
        searchContactsTextField.typeText("anna")
        
        // Make sure that only one contact is returned
        XCTAssertEqual(app.tables.cells.count, 1)
  
        // Tap done to restart the search
        let doneButton = app.buttons["DONE"]
        doneButton.tap()
        
        // Confirm that all contacts were returned
        XCTAssertTrue(app.tables.cells.count > 1)
    }
}

// Helper Functions
extension AmbassadorUITests {
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

    func handleEmailPrompt() {
        if app.textFields["Email"].exists == true {
            let emailTextField = app.textFields["Email"]
            emailTextField.tap()
            emailTextField.typeText("jake@getambassador.com")
            app.buttons["Continue"].tap()
        }
    }
    
    func createNewRAF() {
        app.navigationBars["Refer a Friend"].buttons["Add"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["RAF Name"].tap()
        
        app.typeText("Test")
        app.buttons["Done"].tap()
        elementsQuery.textFields["Campaign"].tap()
        app.tables.staticTexts["Jake+Test"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        app.navigationBars["Edit Refer-a-friend View"].buttons["Save"].tap()
    }
    
    func presentRAF() {
        ambassadorLogin()
        
        // Checks if there is already a RAF created
        if app.tables.staticTexts["Test"].exists == false {
            createNewRAF()
        }
        
        app.tabBars.buttons["Refer a Friend"].tap()
        app.tables.staticTexts["Test"].tap()
        
        handleEmailPrompt()
        
        let existsPredicate = NSPredicate(format: "exists == 0")
        expectation(for: existsPredicate, evaluatedWith: app.otherElements["LoadingView"], handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
    }
}
