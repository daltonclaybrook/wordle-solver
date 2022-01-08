import Foundation

public struct Solver {
	struct GuessResults {
		let guess: String
		let results: [LetterResult]
	}

	public init() {}

	public func start() {
		Printer.print("✨ Welcome to the Wordle Solver! ✨\n")

		var wordSet = WordSet(
			allWords: Set(fiveLetterWords.components(separatedBy: "\n"))
		)

		let allFirstGuessCandidates = wordSet.allWordsMeetingCriteriaForFirstGuess()
		var candidatesForNextGuess = allFirstGuessCandidates

		// Run this loop for one less than `numberOfGuesses` because the user should see the
		// full list of remaining words for the final guess/
		for guessIndex in 0..<(Constants.numberOfGuesses - 1) {
			let guessResults = performGuess(guessIndex: guessIndex, candidates: candidatesForNextGuess, wordSet: &wordSet)
			wordSet.updateWith(guess: guessResults.guess, results: guessResults.results)

			candidatesForNextGuess = wordSet.remainingWords
			if candidatesForNextGuess.count <= 1 {
				break
			} else {
				Printer.print("\n📝 There are \(candidatesForNextGuess.count) valid words remaining!\n")
			}
		}

		if candidatesForNextGuess.count == 0 {
			Printer.print("There are no remaining words. Sorry! 😢")
		} else if candidatesForNextGuess.count == 1 {
			Printer.print("\nThe correct answer is:\n✨ \(candidatesForNextGuess.first!) ✨\n")
		} else {
			Printer.print("The remaining valid words are:\n")
			Printer.print(candidatesForNextGuess.joined(separator: "\n"))
			Printer.print("") // newline
		}
	}

	// MARK: - Private helpers

	private func performGuess(guessIndex: Int, candidates: Set<String>, wordSet: inout WordSet) -> GuessResults {
		let countToDisplay = min(candidates.count, Constants.maxDisplayedGuessCandidates)

		Printer.print(promptTextForChoiceIndex(guessIndex, candidatesCount: candidates.count))
		var guessWords = candidates.shuffled()[0..<countToDisplay]
		Printer.print(guessWords.joined(separator: "\n"))

		var guessWord: String?
		while guessWord == nil {
			let enteredWord = Prompt.prompt(
				"\nEnter your guess, or press the return key without guessing to see more suggestions\n> ",
				invalidEntryText: "Invalid guess. Your guess must be exactly five letters.",
				isValidResponse: { response in
					return response.isEmpty ||
					(response.allSatisfy(\.isLetter) && response.count == Constants.numberOfLettersInWord)
				}
			).lowercased()

			if enteredWord.isEmpty {
				// reshuffle
				guessWords = candidates.shuffled()[0..<countToDisplay]
				Printer.print("") // line break
				Printer.print(guessWords.joined(separator: "\n"))
			} else {
				// valid choice
				let accepted = Prompt.promptForYesNo("\nEnter your guess (\(enteredWord)) on Wordle. Was it accepted? (y/n)\n> ")
				if accepted {
					guessWord = enteredWord
				} else {
					wordSet.removeWord(enteredWord)
				}
			}
		}

		Printer.print("\nEnter a sequence of characters '_' (no match), 'g' (green), and 'y' (yellow) indicating the results from your guess on Wordle. For example, if you guessed \"FLUTE\" and the letters 'L' and 'T' were green and yellow respectively, enter: \"_g_y_\".")

		let results = Prompt.promptForGuessResult(
			"\nEnter your results\n> ",
			invalidEntryText: "Invalid entry. The response must contain five characters, and each character should be 'g', 'y', or '_'."
		)
		return GuessResults(guess: guessWord!, results: results)
	}

	private func promptTextForChoiceIndex(_ index: Int, candidatesCount: Int) -> String {
		let numberWords = [
			"first", "second", "third", "fourth", "fifth", "sixth"
		]

		let suffix: String
		if candidatesCount <= Constants.maxDisplayedGuessCandidates {
			suffix = "You can enter any word, but considering there are only \(candidatesCount) valid word choices left, you might want to choose one of these:\n"
		} else {
			suffix = "You can enter any word, but here are a few suggestions:\n"
		}

		switch index {
		case 0...5:
			return "Choose a word for your \(numberWords[index]) guess.\n\(suffix)"
		default:
			return "Choose a word for guess #\(index + 1):\n\(suffix)"
		}
	}
}
