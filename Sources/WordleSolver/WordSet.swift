enum LetterResult {
	/// wrong letter
	case noMatch
	/// right letter, right position
	case green
	/// right letter, wrong position
	case yellow
}

extension LetterResult {
	init?(character: Character) {
		switch character {
		case "_": self = .noMatch
		case "g": self = .green
		case "y": self = .yellow
		default: return nil
		}
	}
}

struct YellowLetter {
	/// The letter itself, e.g. "p"
	let letter: Character
	/// The minimum known count of letters matching this letter. For example, if the
	/// user guesses the word "HELLO" and both letter 'L's are yellow, this count
	/// will be 2.
	var minimumCount: Int = 1
	/// The set of possible indices this letter might occupy. In the above "HELLO"
	/// example—assuming that was the first guess and no other characters were
	/// correct—this field would contain [0, 1, 4]
	///
	/// The default value of this field is all five possible indices: [0, 1, 2, 3, 4]
	var possibleIndices: Set<Int> = [0, 1, 2, 3, 4]
}

struct WordSet {
	private let allWords: Set<String>
	private(set) var remainingWords: Set<String>

	/// A map of indices to their correct letter in the word, if it is known. This can be populated when
	/// a guess returns a green letter, or it can be populated when the set of `possibleIndices`
	/// for a yellow letter is reduced to one element, which guarantees the correct index.
	private var correctLettersForIndices: [Int: Character] = [:]
	/// Letters that were gray and do not appear anywhere in the string. It is possible for a letter to
	/// exist in both this set and the `yellowLetters` collection. For example, if the user
	/// guesses "HELLO", the first 'L' might be yellow while the second one is gray. Therefore,
	/// a character in this set should only be relied up if it is not contained in `yellowLetters`.
	private var incorrectLetters: Set<Character> = []
	/// A map of characters to their "yellow letter" representation
	private var yellowLetters: [Character: YellowLetter] = [:]

	init(allWords: Set<String>) {
		self.allWords = allWords
		self.remainingWords = allWords
	}

	/// Returns a subset of the receiver list that meet the criteria for a good
	/// first guess at Wordle. These criteria are:
	/// * Each letter is unique
	/// * Contains exactly one vowel
	func allWordsMeetingCriteriaForFirstGuess() -> Set<String> {
		let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
		let filtered = allWords.filter { string in
			let uniqueLetters = Set(string)
			guard uniqueLetters.count == string.count else {
				// This string has duplicate letters
				return false
			}

			guard uniqueLetters.intersection(vowels).count == 1 else {
				// This string contains more than one vowel
				return false
			}

			return true
		}
		return Set(filtered)
	}

	mutating func updateWith(guess: String, results: [LetterResult]) {
		precondition(results.count == 5, "Expected results to have five elements")
		precondition(guess.count == 5, "Expected guess to be five characters long")

		parseGuessAndUpdateCollections(guess: guess, results: results)
		updateYellowLettersByRemovingGreenIndices()
		updateRemainingWords()
	}

	// MARK: - Private helpers

	private mutating func parseGuessAndUpdateCollections(guess: String, results: [LetterResult]) {
		// The number of yellow letters in this guess for a particular character.
		// For example, if the guess is "HELLO" and both 'L's are yellow, this map
		// will contain `["L": 2]`
		var countOfYellowsForLetter: [Character: Int] = [:]

		for (index, result) in results.enumerated() {
			let letter = guess[guess.index(guess.startIndex, offsetBy: index)]
			switch result {

			case .green:
				correctLettersForIndices[index] = letter
				guard var yellowLetter = yellowLetters[letter] else { continue }
				if yellowLetter.minimumCount <= 1 {
					yellowLetters.removeValue(forKey: letter)
				} else {
					yellowLetter.minimumCount -= 1
					yellowLetters[letter] = yellowLetter
				}

			case .yellow:
				var count = countOfYellowsForLetter[letter] ?? 0
				count += 1
				countOfYellowsForLetter[letter] = count

				var yellowLetter = yellowLetters[letter] ?? YellowLetter(letter: letter)
				yellowLetter.minimumCount = max(count, yellowLetter.minimumCount)
				yellowLetter.possibleIndices.remove(index)
				yellowLetters[letter] = yellowLetter

			case .noMatch:
				incorrectLetters.insert(letter)
			}
		}
	}

	private mutating func updateYellowLettersByRemovingGreenIndices() {
		for (correctIndex, _) in correctLettersForIndices {
			for (yellowLetterKey, var yellowLetter) in yellowLetters {
				yellowLetter.possibleIndices.remove(correctIndex)
				yellowLetters[yellowLetterKey] = yellowLetter

				guard yellowLetter.possibleIndices.count == yellowLetter.minimumCount else {
					continue
				}

				// we have eliminated all possible indices except the number that matches
				// the minimum count. This means that all remaining "possible indices"
				// are correct for this letter. Remove the yellow entry and create new
				// ones in the correct entries collection.
				for confirmedIndex in yellowLetter.possibleIndices {
					precondition(correctLettersForIndices[confirmedIndex] == nil, "This index already has a confirmed letter. This should not happen.")
					correctLettersForIndices[confirmedIndex] = yellowLetter.letter
					yellowLetters.removeValue(forKey: yellowLetterKey)
				}

				// Recursively call this same function in order to start the process
				// over again now that we have a new "correct" letter for index.
				defer { updateYellowLettersByRemovingGreenIndices() }
				return
			}
		}
	}

	private mutating func updateRemainingWords() {
		let newRemainingWords = remainingWords.filter { word in
			guard isWordValidForCorrectLetters(word: word) else {
				// Word contains characters that conflict with the "correct" list
				return false
			}

			guard isWordValidForYellowCharacters(word: word) else {
				// Word contains characters that conflict with the yellows
				return false
			}

			guard isWordValidForIncorrectCharacters(word: word) else {
				// Word contains an incorrect character
				return false
			}

			return true
		}

		remainingWords = newRemainingWords
	}

	/// Returns true if the provided word does not conflict with the know list of correct characters
	private func isWordValidForCorrectLetters(word: String) -> Bool {
		let containsInvalidCharacter = correctLettersForIndices.contains { (index, expectedLetter) in
			let wordLetter = word[word.index(word.startIndex, offsetBy: index)]
			return wordLetter != expectedLetter
		}

		// If this string contains a character that does not match one of the
		// `correctLettersForIndices` characters, then this string is invalid
		return containsInvalidCharacter == false
	}

	/// Returns true if the provided word contains at least the minimum number of yellow characters
	/// in the valid possible indices
	private func isWordValidForYellowCharacters(word: String) -> Bool {
		for (letter, yellow) in yellowLetters {
			var countOfMatches = 0
			for index in 0..<5 {
				let character = word[word.index(word.startIndex, offsetBy: index)]
				guard character == letter else { continue }

				if yellow.possibleIndices.contains(index) {
					countOfMatches += 1
				} else {
					// This character is at an index that's not one of the "possible"
					// ones, so this word is invalid
					return false
				}
			}

			guard countOfMatches >= yellow.minimumCount else {
				// The word is missing this yellow character in the minimum required
				// number of possible indices, so it is invalid.
				return false
			}
		}
		return true
	}

	private func isWordValidForIncorrectCharacters(word: String) -> Bool {
		for letter in word {
			guard yellowLetters[letter] == nil else {
				// If this letter has a "yellow" counterpart, it is ignored
				// by this function
				continue
			}

			guard incorrectLetters.contains(letter) == false else {
				// This word contains a letter that is in the "incorrect" set
				// so it is an invalid word.
				return false
			}
		}
		return true
	}
}
