//
//  NotificationsUITestsLaunchTests.swift
//  NotificationsUITests
//
//  Created by Om Roy on 01/03/25.
//

import XCTest

final class NotificationsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        
        // Disable animations to make tests more reliable
        app.launchArguments = ["-UIViewControllerBasedStatusBarAppearance", "NO",
                              "-UIStatusBarHidden", "YES",
                              "-UIAnimationDurationScale", "0.0"]
        
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        // Add a longer delay to ensure views are fully rendered
        sleep(2)
        
        // Tap somewhere on the screen to dismiss any keyboard that might be showing
        app.tap()
        
        // Wait for UI to stabilize
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.buttons["Schedule Notifications"]
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Failed to find the Schedule Notifications button")
        
        // Take screenshot with afterScreenUpdates set to true
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
