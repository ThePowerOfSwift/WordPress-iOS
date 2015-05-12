import Foundation
import XCTest

class PushAuthenticationServiceTests : XCTestCase {
    
    var pushAuthenticationService:PushAuthenticationService?
    var mockPushAuthenticationServiceRemote:MockPushAuthenticationServiceRemote?
    var mockRemoteApi:MockWordPressComApi?
    let token = "token"
    
    class MockPushAuthenticationServiceRemote : PushAuthenticationServiceRemote {
        
        var authorizeLoginCalled = false
        override func authorizeLogin(token: String, success: (() -> ())?, failure: (() -> ())?) {
            authorizeLoginCalled = true
            
            if (shouldCallSuccessBlock) {
               success?()
            }
            
            if (shouldCallFailureBlock) {
                failure?()
            }
        }
        
        var shouldCallSuccessBlock = false
        func callSuccessBlock() {
           shouldCallSuccessBlock = true
        }
        
        var shouldCallFailureBlock = false
        func callFailureBlock() {
           shouldCallFailureBlock = true
        }
    }
    
    override func setUp() {
        super.setUp()
        mockRemoteApi = MockWordPressComApi()
        mockPushAuthenticationServiceRemote = MockPushAuthenticationServiceRemote(remoteApi: mockRemoteApi)
        pushAuthenticationService = PushAuthenticationService(managedObjectContext: TestContextManager().mainContext)
        pushAuthenticationService?.authenticationServiceRemote = mockPushAuthenticationServiceRemote
    }
    
    func testAuthorizeLoginDoesntCallServiceRemoteIfItsNull() {
        pushAuthenticationService?.authenticationServiceRemote = nil
        pushAuthenticationService?.authorizeLogin(token, completion: { (completed:Bool) -> () in
        })
        XCTAssertFalse(mockPushAuthenticationServiceRemote!.authorizeLoginCalled, "Authorize login should not have been called")
    }
    
    func testAuthorizeLoginCallsServiceRemoteAuthorizeLoginWhenItsNotNull() {
        pushAuthenticationService?.authorizeLogin(token, completion: { (completed:Bool) -> () in
        })
        XCTAssertTrue(mockPushAuthenticationServiceRemote!.authorizeLoginCalled, "Authorize login should have been called")
    }
    
    func testAuthorizeLoginCallsCompletionCallbackWithTrueIfSuccessful() {
        var methodCalled = false
        mockPushAuthenticationServiceRemote?.callSuccessBlock()
        pushAuthenticationService?.authorizeLogin(token, completion: { (completed:Bool) -> () in
            methodCalled = true
            XCTAssertTrue(completed, "Success callback should have been called with a value of true")
        })
        XCTAssertTrue(methodCalled, "Success callback was not called")
    }
    
    func testAuthorizeLoginCallsCompletionCallbackWithFalseIfSuccessful() {
        var methodCalled = false
        mockPushAuthenticationServiceRemote?.callFailureBlock()
        pushAuthenticationService?.authorizeLogin(token, completion: { (completed:Bool) -> () in
            methodCalled = true
            XCTAssertFalse(completed, "Failure callback should have been called with a value of false")
        })
        XCTAssertTrue(methodCalled, "Failure callback was not called")
    }
    
}