//
//  RegexFilterTests.swift
//  SecureYourClipboardTests
//
//  Created by lixindong on 2024/3/28.
//

import Foundation
import XCTest
import SwiftUI

class RegexFilterTests: XCTestCase {

    func testPhoneRegex() {
        let filter = TextFilter.phone
        let validPhones = ["13812345678", "+8613812345678", "18612345678", "123456789"]
        let invalidPhones = ["abcdefghijk", "123.456.7890"]
        
        for phone in validPhones {
            XCTAssertTrue(phone.range(of: filter.regex, options: .regularExpression) != nil, "Valid phone number \(phone) should match regex")
        }
        
        for phone in invalidPhones {
            XCTAssertNil(phone.range(of: filter.regex, options: .regularExpression), "Invalid phone number \(phone) should not match regex")
        }
    }
    
    func testEmailRegex() {
        let filter = TextFilter.email
        let validEmails = ["example@example.com", "test@test.co.uk", "user@subdomain.example.org"]
        let invalidEmails = ["example@example", "test@test.", "@example.com"]
        
        for email in validEmails {
            XCTAssertTrue(email.range(of: filter.regex, options: .regularExpression) != nil, "Valid email \(email) should match regex")
        }
        
        for email in invalidEmails {
            XCTAssertNil(email.range(of: filter.regex, options: .regularExpression), "Invalid email \(email) should not match regex")
        }
    }
    
    func testURLRegex() {
        let filter = TextFilter.url
        let validURLs = ["https://www.example.com", "ftp://example.org", "file://path/to/file.txt"]
        let invalidURLs = ["example.com", "www.example.com", "http:/example.com"]
        
        for url in validURLs {
            XCTAssertTrue(url.range(of: filter.regex, options: .regularExpression) != nil, "Valid URL \(url) should match regex")
        }
        
        for url in invalidURLs {
            XCTAssertNil(url.range(of: filter.regex, options: .regularExpression), "Invalid URL \(url) should not match regex")
        }
    }
    
    func testCreditCardRegex() {
        let filter = TextFilter.creditCard
        let validCreditCards = ["1234-5678-9012-3456", "1234567890123456", "1234 5678 9012 3456"]
        let invalidCreditCards = ["1234-5678-90123", "abcd-efgh-ijkl-mnop", "12345678901234567"]
        
        for creditCard in validCreditCards {
            XCTAssertTrue(creditCard.range(of: filter.regex, options: .regularExpression) != nil, "Valid credit card number \(creditCard) should match regex")
        }
        
        for creditCard in invalidCreditCards {
            XCTAssertNil(creditCard.range(of: filter.regex, options: .regularExpression), "Invalid credit card number \(creditCard) should not match regex")
        }
    }
    
    func testBankAccountRegex() {
        let filter = TextFilter.bankAccount
        let validBankAccounts = ["1234-5678-9012-3456", "1234567890123456", "1234 5678 9012 3456"]
        let invalidBankAccounts = ["1234-5678-90123", "abcd-efgh-ijkl-mnop", "12345678901234567"]
        
        for bankAccount in validBankAccounts {
            XCTAssertTrue(bankAccount.range(of: filter.regex, options: .regularExpression) != nil, "Valid bank account number \(bankAccount) should match regex")
        }
        
        for bankAccount in invalidBankAccounts {
            XCTAssertNil(bankAccount.range(of: filter.regex, options: .regularExpression), "Invalid bank account number \(bankAccount) should not match regex")
        }
    }
    
    func testCryptoAddressRegex() {
        let filter = TextFilter.crypto
        let validCryptoAddresses = ["0x1234567890abcdef1234567890abcdef12345678", "0xABCDEF0123456789ABCDEF0123456789ABCDEF01"]
        let invalidCryptoAddresses = ["1234567890abcdef1234567890abcdef12345678", "0x1234567890abcdef1234567890abcdef", "0xABCDEF0123456789ABCDEF0123456789ABCDEF0112"]
        
        for cryptoAddress in validCryptoAddresses {
            XCTAssertTrue(cryptoAddress.range(of: filter.regex, options: .regularExpression) != nil, "Valid crypto address \(cryptoAddress) should match regex")
        }
        
        for cryptoAddress in invalidCryptoAddresses {
            XCTAssertNil(cryptoAddress.range(of: filter.regex, options: .regularExpression), "Invalid crypto address \(cryptoAddress) should not match regex")
        }
    }
    
    func testComplexString() {
        let complexString = "My email is john@example.com and my phone number is +86 13812345678. You can visit our website at https://www.example.org to learn more about our products. Our bank account number is 1234567890123456 and our crypto wallet address is 0x1234567890abcdef1234567890abcdef12345678."
        
        let filters: [TextFilter] = [.email, .phone, .url, .bankAccount, .crypto]
        var filteredString = complexString
        
        for filter in filters {
            filteredString = filter.filter(filteredString)
        }
        
        let expectedString = "My email is REPLACED and my phone number is +REPLACED. You can visit our website at REPLACED to learn more about our products. Our bank account number is REPLACED and our crypto wallet address is REPLACED."
        XCTAssertEqual(filteredString, expectedString, "Complex string filtering failed")
    }
    
    func testMixedPatterns() {
        let mixedString = "Visit http://example.com or REPLACED. Email me at REPLACED or call REPLACED. Our bank account is REPLACED."
        
        let filters: [TextFilter] = [.url, .email, .phone, .bankAccount]
        var filteredString = filters.reduce(mixedString) { $1.filter($0) }
        
        let expectedString = "Visit REPLACED or REPLACED. Email me at REPLACED or call REPLACED. Our bank account is REPLACED."
        XCTAssertEqual(filteredString, expectedString, "Mixed pattern filtering failed")
    }
    
    func testMixedPatterns2() {
        let mixedString = "Visit http://example.com or https://www.example.net. Email me at john@example.org or call 13812345678. Our bank account is 1234567890123456."
        
        let filters: [TextFilter] = [
            .url,
            .email,
            .phone,
            .bankAccount
        ]
        
        let filteredString = filters.reduce(mixedString) { $1.filter($0) }
        
        let expectedString = "Visit REPLACED or REPLACED. Email me at REPLACED or call REPLACED. Our bank account is REPLACED."
        XCTAssertEqual(filteredString, expectedString, "Mixed pattern filtering failed")
    }
}
