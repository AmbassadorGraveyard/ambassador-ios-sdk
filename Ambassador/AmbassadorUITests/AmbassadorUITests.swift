//
//  AmbassadorUITests.swift
//  AmbassadorUITests
//
//  Created by Jake Dunahee on 10/29/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

import XCTest

var app : XCUIApplication!
var rafLoaded = false

class AmbassadorUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        if app == nil {
            app = XCUIApplication()
            app.launchArguments = ["USE_MOCK_SERVER", "isUITesting"]
            app.launch()
            identifyWithLogin()
            presentRAF()
            
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func identifyWithLogin() {
        let app = XCUIApplication()
        app.tabBars.buttons["Login"].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("jake@getambassador.com")
        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("testpassword")
        XCTAssertEqual(app.keyboards.count, 1) // Checks to make sure keyboard is present
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Login"].tap()
        XCTAssertEqual(app.keyboards.count, 0) // Checks to sure all textFields resigned firstResponder (that the keyboard is hidden)
    }
    
    func presentRAF() {
        let app = XCUIApplication()
        app.tabBars.buttons["Refer a Friend"].tap()
        app.tables.staticTexts["Shopping Cart RAF"].tap()
        while (app.otherElements["LoadingView"].exists) {
            let smallDelay = NSDate().dateByAddingTimeInterval(1)
            NSRunLoop.mainRunLoop().runUntilDate(smallDelay)
        }
    }
    
    func testLoadRAF() {
        
        
        // When the RAF page is hit, we check to make sure that all of the correct labels are shown
        XCTAssert(app.staticTexts.elementMatchingType(XCUIElementType.StaticText, identifier: "urlLabel").exists)
        
        // Check to make sure there are the correct number of cells in the collectionView
        XCTAssertEqual(app.collectionViews.cells.count, 5)
        rafLoaded = true
    }
    
    func testCopyButton() {
        if !rafLoaded { self.testLoadRAF() }
        
        // Tap the copy button and make sure that the copied label is shown on the screen
        app.buttons["clipboard"].tap()
        XCTAssertEqual(app.staticTexts["lblCopied"].exists, true)
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
        if !rafLoaded { self.testLoadRAF() }
        
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
    
    func testLinkedIn() {        
        // Tap the linkedIn cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(2).tap()
        
        // Since defaults get cleared, we will be brought to the login page -- here we login using meldium credentials
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("developers@getambassador.com")
        
        // Type password for linkedin
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("domorefaster")
        
        // Tap the sign in and allow button
        app.buttons["Sign in and allow"].tap()
        
        // After we get popped back to the ServiceSelector page, we tap cancel in the linkedin share vc
        app.navigationBars["LinkedIn"].buttons["Cancel"].tap()
        
        // Now we tap the linkedinCell again and confirm that our credentials were saved to defaults
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(2).tap()

        // We post and check for success and that it went away after tapping ok
        app.navigationBars["LinkedIn"].buttons["Post"].tap()
        app.buttons["OKAY"].tap()
        XCTAssertEqual(app.buttons["OKAY"].exists, false)
    }
    
    func testSMS() {
        if !rafLoaded { self.testLoadRAF() }
        
        // Tap the SMS cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(3).tap()
        
        // Select 3 contacts and then unselect one
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Home - (555) 522-8243"].tap()
        
        let danielHigginsStaticText = tablesQuery.cells.containingType(.StaticText, identifier:"Home - (555) 478-7672").staticTexts["Daniel Higgins"]
        danielHigginsStaticText.tap()
        
        tablesQuery.staticTexts["Mobile - (408) 555-5270"].tap()
        danielHigginsStaticText.tap()
        
        tablesQuery.cells.containingType(.StaticText, identifier:"HomeFAX - (408) 555-3514").staticTexts["Daniel Higgins"].doubleTap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Make sure the call goes through by checking for success message
        XCTAssertTrue(app.staticTexts["Message successfully shared!"].exists)
        app.buttons["OKAY"].tap()
    }
    
    func testEmail() {
        if !rafLoaded { self.testLoadRAF() }
        
        // Tap email cell
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(4).tap()
        
        // Select some contacts
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Home - anna-haro@mac.com"].tap()
        tablesQuery.staticTexts["Home - d-higgins@mac.com"].tap()
        
        let homeFakeFakeComStaticText = tablesQuery.staticTexts["Work - hank-zakroff@mac.com"]
        homeFakeFakeComStaticText.tap()
        homeFakeFakeComStaticText.tap()
        
        // Tap the send button
        app.buttons["sendButton"].tap()
        
        // Check for message success
        XCTAssertTrue(app.staticTexts["Message successfully shared!"].exists)
        app.buttons["OKAY"].tap()
    }
    
    func testSearch() {
        if !rafLoaded { self.testLoadRAF() }
        
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

        // Search for dani
        searchContactsTextField.tap()
        searchContactsTextField.typeText("dani")
        
        // Confirm that 3 contacts were returned
        XCTAssertEqual(app.tables.cells.count, 3)
        doneButton.tap()
        
        // Pop back to ServiceSelector
        app.navigationBars.buttons["Back"].tap()
    }
}
