import Testing
//@testable import GQPaymentIOSSDK
//
//class TokenBasedAuthTests {
//    
//    typealias JSONResponse = [String: Any]
//    
//    @Test("Token Based Auth")
//    func performTokenBasedAuth() async throws {
//        let token: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzZXNzaW9uX2NvZGUiOiI4ZmNhNzUwMy0xNjdhLTRlM2QtYjI1NC1jNzRkYjRlMTA2MTEiLCJleHAiOjE3NTE1MzU4NDIsImlhdCI6MTc1MTUzNDk0Mn0.N-5u2bJs0mgLCjnq1sDQWucK3hKHEFSyOjI3pJXM6p0"
//        GQPaymentIOSSDK.Environment.shared.env = "test"
//        
//        await #expect(throws: Never.self, performing: {
//            let response = try await APIService.fetchSessionCode(token: token)
//            let result = try #require(response, "Empty Response")
//            let data = try #require(result["data"] as? JSONResponse, "No Data Found")
//            let sessionCode = try #require(data["session_code"] as? String, "No Session COde Found")
//            dump(sessionCode)
//            #expect(!sessionCode.isEmpty)
//        })
//    }
//    
//    @Test("Token Based Auth with Wrong Token")
//    func performTokenBasedAuthWithWrongToken() async throws {
//        GQPaymentIOSSDK.Environment.shared.env = "test"
//        
//        await #expect(throws: GQError.self, performing: {
//            let response = try await APIService.fetchSessionCode(token: "")
//            let result = try #require(response, "Empty Response")
//            let message = try #require(result["message"] as? String, "No Message Found")
//            dump(message)
//            #expect(!message.isEmpty)
//        })
//    }
//    
//}
