/// Prompt the user for input in a loop until their response is considered valid by the provided validation block
func prompt(_ text: String, invalidEntryText: String? = nil, isValidResponse: (String) -> Bool) -> String {
	while true {
		print(text, terminator: "")
		guard let response = readLine() else {
			if let invalidEntryText = invalidEntryText {
				print(invalidEntryText)
			}
			continue
		}
		if isValidResponse(response) {
			return response
		} else if let invalidEntryText = invalidEntryText {
			print(invalidEntryText)
		}
	}
}

/// Prompt the user for input in a loop until their response can be successfully transformed by the provided block
func promptAndTransform<T>(_ text: String, invalidEntryText: String? = nil, transformBlock: (String) -> T?) -> T {
	while true {
		print(text, terminator: "")
		guard let response = readLine() else {
			if let invalidEntryText = invalidEntryText {
				print(invalidEntryText)
			}
			continue
		}
		if let transformed = transformBlock(response) {
			return transformed
		} else if let invalidEntryText = invalidEntryText {
			print(invalidEntryText)
		}
	}
}

// Prompt the user for a yes/no response and return the the response as a `Bool`
func promptForYesNo(_ text: String, invalidEntryText: String? = nil) -> Bool {
	promptAndTransform(text, invalidEntryText: invalidEntryText) { response -> Bool? in
		let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed == "y" || trimmed == "yes" {
			return true
		} else if trimmed == "n" || trimmed == "yes" {
			return false
		} else {
			return nil
		}
	}
}

/// Prompt for the result of a word guess on Wordle. Example user input: `_g_y_`
func promptForGuessResult(_ text: String, invalidEntryText: String? = nil) -> [LetterResult] {
	promptAndTransform(text, invalidEntryText: invalidEntryText) { response -> [LetterResult]? in
		let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
		let results = trimmed.compactMap(LetterResult.init(character:))
		if results.count == 5 {
			return results
		} else {
			return nil
		}
	}
}
