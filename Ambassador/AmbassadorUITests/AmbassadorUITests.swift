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
        XCTAssert(app.staticTexts.elementMatchingType(XCUIElementType.StaticText, identifier: "urlLabel").exists)
        
        // Check to make sure there are the correct number of cells in the collectionView
        XCTAssertEqual(app.collectionViews.cells.count, 5)
    }

    func testCopyButton() {
        // Tap the copy button and make sure that the copied label is shown on the screen
        XCUIApplication().buttons["btnEdit"].tap()
        XCTAssertTrue(app.staticTexts["Copied!"].exists)
    }

    func testFacebook() {
        // Tap the facebook cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))
        
        if app.alerts["No Facebook Account"].exists {
            let cancelButton = app.alerts["No Facebook Account"].collectionViews.buttons["Cancel"]
            cancelButton.tap()
        } else {
            // First make sure that the cancel button functions correctly
            let facebookNavigationBar = app.navigationBars["Facebook"]
            facebookNavigationBar.buttons["Cancel"].tap()
            
            // Tap the facebook cell again, but this time post the message
            app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
            facebookNavigationBar.buttons["Post"].tap()
            
            // Tap the OKAY button and assure that the success screen is hidden
            app.buttons["OKAY"].tap()
            XCTAssertEqual(app.buttons["OKAY"].exists, false)
        }
    }

    func testTwitter() {
        // Tap the twitter cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
        
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))
        
        if app.alerts["No Twitter Accounts"].exists {
            app.alerts["No Twitter Accounts"].collectionViews.buttons["Cancel"].tap()
        } else {
            // Make sure that the cancel button works correctly with the twitter alertView
            let twitterNavigationBar = app.navigationBars["Twitter"]
            twitterNavigationBar.buttons["Cancel"].tap()
            
            // Now we tap the twitter cell again and Post
            app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(1).tap()
            twitterNavigationBar.buttons["Post"].tap()
            
            // If we get an alert about duplicate tweets, we will press the OK button in the alertview
            if app.alerts.elementBoundByIndex(0).exists { app.buttons["OK"].tap() }
            
            // Tap OKAY on the success message and check that the message went away
            app.buttons["OKAY"].tap()
            XCTAssertEqual(app.buttons["OKAY"].exists, false)
        }
    }
    
    func testSMS() {
        // Tap the SMS cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(3).tap()
        
        // Select 3 contacts and then unselect one
        let tablesQuery = app.tables
        tablesQuery.staticTexts.elementBoundByIndex(0).tap()
        tablesQuery.staticTexts.elementBoundByIndex(1).tap()
        tablesQuery.staticTexts.elementBoundByIndex(2).tap()
        tablesQuery.staticTexts.elementBoundByIndex(1).doubleTap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Make sure the call goes through by checking for success message
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectationForPredicate(existsPredicate, evaluatedWithObject: app.staticTexts["Message successfully shared!"], handler: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
        app.buttons["OKAY"].tap()
    }
    
    func testEmail() {
        // Tap email cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(4).tap()
        
        // Select some contacts
        let tablesQuery = app.tables
        tablesQuery.staticTexts.elementBoundByIndex(0).tap()
        tablesQuery.staticTexts.elementBoundByIndex(1).tap()
        
        tablesQuery.staticTexts.elementBoundByIndex(3).tap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Check for message success
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectationForPredicate(existsPredicate, evaluatedWithObject: app.staticTexts["Message successfully shared!"], handler: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
        app.buttons["OKAY"].tap()
    }
    
    func testSearch() {
        // Tap sms cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(3).tap()
        
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
        
        // Pop back to ServiceSelector
        app.navigationBars.buttons["Back"].tap()
    }
    
    
    
}

// Helper Functions
extension AmbassadorUITests {
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

    func handleEmailPrompt() {
        if app.textFields["Email"].exists == true {
            let emailTextField = app.textFields["Email"]
            emailTextField.tap()
            emailTextField.typeText("jake@getambassador.com")
            app.buttons["Continue"].tap()
        }

    }
    
    func presentRAF() {
        ambassadorLogin()
        
        app.tabBars.buttons["Refer a Friend"].tap()
        app.tables.staticTexts["Ambassador Default RAF"].tap()
        
        handleEmailPrompt()
        
        let existsPredicate = NSPredicate(format: "exists == 0")
        expectationForPredicate(existsPredicate, evaluatedWithObject: app.otherElements["LoadingView"], handler: nil)
        waitForExpectationsWithTimeout(20, handler: nil)
    }
}
