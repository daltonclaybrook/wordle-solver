@testable import WordleSolverKit
import XCTest

final class WordSetTests: XCTestCase {
	let testWords: Set<String> = [
		"abcde",
		"bcdea", // offset by one
		"fghij",
		"ghijf", // offset by one
		"hklmn",
		"klmnh", // offset by one
		"opqrs",
		"pqrso", // offset by one
		"tuvwx",
		"uvwxt", // offset by one
		"apple"
	]

	func testCorrectWordsAreRemovedForGreenResult() {
		var subject = WordSet(allWords: testWords)
		subject.updateWith(
			guess: "azzzz",
			results: [.green, .noMatch, .noMatch, .noMatch, .noMatch]
		)
		XCTAssertEqual(subject.remainingWords, [
			"abcde", "apple"
		])
	}
}
