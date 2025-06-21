import XCTest

@testable import Semaphore

class SemaphoreTests: XCTestCase {

  func testIdentity() async throws {
    let privateKey = "secret".data(using: .utf8)!
    let identity = Identity(privateKey: privateKey)
    let commitment = identity.commitment()
    XCTAssertEqual(
      commitment, "21756852044673293804725356853298692762259855200429755225624171532449447776732")
    let identityPrivateKey = identity.privateKey()
    XCTAssertEqual(identityPrivateKey, privateKey)
    let secretScalar = identity.secretScalar()
    XCTAssertEqual(
      secretScalar, "1072931509665125050858164614503996272893941281138625620671594663472720926391")
    let toElement = identity.toElement()
    let byteArray: [UInt8] = [
      220, 145, 41, 230, 37, 163, 179, 162, 235, 150, 78, 165, 42, 67, 48, 31,
      188, 116, 185, 247, 87, 191, 177, 59, 167, 248, 170, 60, 30, 241, 25, 48,
    ]

    let elementData = Data(byteArray)
    XCTAssertEqual(toElement, elementData)
  }

  func testGroup() async throws {
    let privateKey = "secret".data(using: .utf8)!
    let privateKey2 = "secret2".data(using: .utf8)!
    let identity = Identity(privateKey: privateKey)
    let identity2 = Identity(privateKey: privateKey2)
    let group = Group(members: [identity.toElement(), identity2.toElement()])
    let groupRoot = group.root()

    let byteArray: [UInt8] = [
      252, 10, 239, 67, 190, 43, 60, 182, 30, 147, 1, 30, 7, 23, 232, 198, 106, 240, 50, 0, 192,
      125,
      228, 215, 83, 223, 100, 83, 108, 15, 135, 31,
    ]
    let elementData = Data(byteArray)
    XCTAssertEqual(groupRoot, elementData)
  }

  func testProof() async throws {
    let message = "message"
    let scope = "scope"
    let privateKey = "secret".data(using: .utf8)!
    let privateKey2 = "secret2".data(using: .utf8)!
    let identity = Identity(privateKey: privateKey)
    let identity2 = Identity(privateKey: privateKey2)
    let group = Group(members: [identity.toElement(), identity2.toElement()])
    let proof = try generateSemaphoreProof(
      identity: identity,
      group: group,
      message: message,
      scope: scope,
      merkleTreeDepth: 16
    )
    let valid = try verifySemaphoreProof(proof: proof)
    XCTAssertTrue(valid)
  }
}
