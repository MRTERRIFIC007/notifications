//
//  NotificationsUITests.swift
//  NotificationsUITests
//
//  Created by Om Roy on 01/03/25.
//

import XCTest

final class NotificationsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testNotificationScheduling() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["-UIAnimationDurationScale", "0.0"]
        app.launch()

        // Test notification scheduling
        let intervalTextField = app.textFields["Enter interval in minutes"]
        XCTAssertTrue(intervalTextField.exists, "Interval text field should exist")
        
        intervalTextField.tap()
        intervalTextField.typeText("5")
        
        let scheduleButton = app.buttons["Schedule Notifications"]
        XCTAssertTrue(scheduleButton.exists, "Schedule button should exist")
        scheduleButton.tap()
        
        // Check if status label updates
        let statusText = "Notifications scheduled every 5.0 minute(s)."
        let statusLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", statusText)).firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2), "Status label should update after scheduling")
    }
    
    @MainActor
    func testWordGame() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launchArguments = ["-UIAnimationDurationScale", "0.0"]
        app.launch()
        
        // Find and tap the Play Word Game button
        let playGameButton = app.buttons["Play Word Game"]
        XCTAssertTrue(playGameButton.exists, "Play Game button should exist")
        playGameButton.tap()
        
        // Wait for game screen to appear
        let nextWordButton = app.buttons["Next Word"]
        XCTAssertTrue(nextWordButton.waitForExistence(timeout: 2), "Next Word button should exist in game screen")
        
        // Go through all 10 words to trigger the quiz
        for _ in 1...10 {
            nextWordButton.tap()
            // Small delay to let UI update
            sleep(1)
        }
        
        // Now we should see the Take Quiz button
        let takeQuizButton = app.buttons["Take Quiz"]
        XCTAssertTrue(takeQuizButton.waitForExistence(timeout: 2), "Take Quiz button should appear after completing the game")
        takeQuizButton.tap()
        
        // Test the quiz functionality
        // Wait for quiz screen to appear
        let finishButton = app.buttons["Finish Quiz"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 2), "Finish Quiz button should exist in quiz screen")
        
        // Answer a few questions
        for _ in 1...3 {
            // Tap the first option for simplicity in testing
            if let firstOption = app.buttons.element(boundBy: 0) {
                firstOption.tap()
                // Wait for the next question to appear
                sleep(2)
            }
        }
        
        // Test finishing the quiz early
        finishButton.tap()
        
        // Verify we're back on the main screen
        XCTAssertTrue(playGameButton.waitForExistence(timeout: 2), "Should return to main screen after finishing quiz")
    }

    @MainActor
    func testRandomQuiz() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launchArguments = ["-UIAnimationDurationScale", "0.0"]
        app.launch()
        
        // Find and tap the Take Random Quiz button
        let randomQuizButton = app.buttons["Take Random Quiz"]
        XCTAssertTrue(randomQuizButton.exists, "Random Quiz button should exist")
        randomQuizButton.tap()
        
        // Wait for quiz screen to appear
        let finishButton = app.buttons["Finish Quiz"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 2), "Finish Quiz button should exist in quiz screen")
        
        // Answer a few questions
        for _ in 1...3 {
            // Tap the first option for simplicity in testing
            if let firstOption = app.buttons.element(boundBy: 0) {
                firstOption.tap()
                // Wait for the next question to appear
                sleep(2)
            }
        }
        
        // Test finishing the quiz early
        finishButton.tap()
        
        // Verify we're back on the main screen
        XCTAssertTrue(randomQuizButton.waitForExistence(timeout: 2), "Should return to main screen after finishing random quiz")
    }

    @MainActor
    func testStopNotifications() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launchArguments = ["-UIAnimationDurationScale", "0.0"]
        app.launch()
        
        // First schedule some notifications
        let intervalTextField = app.textFields["Enter interval in minutes"]
        XCTAssertTrue(intervalTextField.exists, "Interval text field should exist")
        
        intervalTextField.tap()
        intervalTextField.typeText("5")
        
        let scheduleButton = app.buttons["Schedule Notifications"]
        XCTAssertTrue(scheduleButton.exists, "Schedule button should exist")
        scheduleButton.tap()
        
        // Check if status label updates for scheduling
        let scheduledText = "Notifications scheduled every 5.0 minute(s)."
        let scheduledLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", scheduledText)).firstMatch
        XCTAssertTrue(scheduledLabel.waitForExistence(timeout: 2), "Status label should update after scheduling")
        
        // Now test stopping notifications
        let stopButton = app.buttons["Stop Notifications"]
        XCTAssertTrue(stopButton.exists, "Stop Notifications button should exist")
        stopButton.tap()
        
        // Check for alert and dismiss it
        let alert = app.alerts["Notifications Stopped"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Alert should appear after stopping notifications")
        
        let okButton = alert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist in alert")
        okButton.tap()
        
        // Check if status label updates for stopping
        let stoppedText = "All notifications have been cancelled."
        let stoppedLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", stoppedText)).firstMatch
        XCTAssertTrue(stoppedLabel.waitForExistence(timeout: 2), "Status label should update after stopping notifications")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
