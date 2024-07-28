//
//  GiphyFinderTests.swift
//  GiphyFinderTests
//
//  Created by Patrīcija Vainovska on 28/07/2024.
//

import XCTest
@testable import GiphyFinder

// At the moment we have a single file for unit tests for the whole project, but if we
//   expand the tests, we could split these into separate files, for example, this could
//   be a separate file called NetworkManagerTests
final class GiphyFinderTests: XCTestCase {
    func testGetRequestUrlSuccess() {
        // Arrange
        var networkManager = NetworkManager()
        networkManager.readGiphyKeyFromSecrets()
        let limit = 50
        let offset = 0

        // Act
        let requestUrl = networkManager.getRequestUrl(query: "Chihuahua", limit: limit, offset: offset)

        // Assert
        XCTAssertNotNil(requestUrl)
    }

    func testGetRequestUrlFailure() {
        // Arrange
        let networkManager = NetworkManager()

        // Act
        let requestUrl = networkManager.getRequestUrl(query: "Pomeranian")

        // Assert
        XCTAssertNil(requestUrl)
    }
}
