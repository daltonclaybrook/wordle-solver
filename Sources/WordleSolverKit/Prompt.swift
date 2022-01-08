struct Prompt {
	private init() {}

	/// Prompt the user for input in a loop until their response is considered valid by the provided validation block
	static func prompt(
		_ text: String,
		invalidEntryText: String? = nil,
		isValidResponse: (String) -> Bool = { _ in true }
	) -> String {
		promptAndTransform(text, invalidEntryText: invalidEntryText) { response -> String? in
			isValidResponse(response) ? response : nil
		}
	}

	/// Prompt the user for input in a loop until their response can be successfully transformed by the provided block
	static func promptAndTransform<T>(_ text: String, invalidEntryText: String? = nil, transformBlock: (String) -> T?) -> T {
		while true {
			Printer.print(text, terminator: "")
			guard let response = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
				if let invalidEntryText = invalidEntryText {
					Printer.print(invalidEntryText)
				}
				continue
			}
			if let transformed = transformBlock(response) {
				return transformed
			} else if let invalidEntryText = invalidEntryText {
				Printer.print(invalidEntryText)
			}
		}
	}

	// Prompt the user for a yes/no response and return the the response as a `Bool`
	static func promptForYesNo(_ text: String, invalidEntryText: String? = nil) -> Bool {
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
	static func promptForGuessResult(_ text: String, invalidEntryText: String? = nil) -> [LetterResult] {
		promptAndTransform(text, invalidEntryText: invalidEntryText) { response -> [LetterResult]? in
			let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
			let results = trimmed.compactMap(LetterResult.init(character:))
			if results.count == Constants.numberOfLettersInWord {
				return results
			} else {
				return nil
			}
		}
	}
}
