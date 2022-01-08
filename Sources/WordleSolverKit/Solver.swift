import Foundation

public struct Solver {
	struct GuessResults {
		let guess: String
		let results: [LetterResult]
	}

	public init() {}

	public func start() {
		print("✨ Welcome to the Wordle Solver! ✨\n")

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
				print("\nThere are \(candidatesForNextGuess.count) valid words remaining!\n")
			}
		}

		if candidatesForNextGuess.count == 0 {
			print("There are no remaining words. Sorry! 😢")
		} else if candidatesForNextGuess.count == 1 {
			print("\nThe correct answer is: \(candidatesForNextGuess.first!)!")
		} else {
			print("The remaining valid words are:")
			print(candidatesForNextGuess.joined(separator: "\n"))
		}
	}

	// MARK: - Private helpers

	private func performGuess(guessIndex: Int, candidates: Set<String>, wordSet: inout WordSet) -> GuessResults {
		let countToDisplay = min(candidates.count, Constants.maxDisplayedGuessCandidates)

		print("Choose a word for guess #\(guessIndex + 1):\n")
		var guessWords = candidates.shuffled()[0..<countToDisplay]
		printWords(guessWords)

		var guessWord: String?
		while guessWord == nil {
			let choiceNumber = Prompt.promptAndTransform(
				"\nPick a number (Enter \(countToDisplay + 1) to reshuffle): ",
				invalidEntryText: "Invalid choice, try again...",
				transformBlock: Int.init
			)

			if choiceNumber == countToDisplay + 1 {
				// reshuffle
				guessWords = candidates.shuffled()[0..<countToDisplay]
				print("") // line break
				printWords(guessWords)
			} else if choiceNumber >= 1 && choiceNumber <= guessWords.count {
				// valid choice
				let word = guessWords[choiceNumber - 1]
				let accepted = Prompt.promptForYesNo("Enter your choice (\(word)) on Wordle. Was it accepted? (y/n): ")
				if accepted {
					guessWord = word
				} else {
					wordSet.removeWord(word)
				}
			} else {
				print("Invalid choice, try again...")
			}
		}

		print("\nEnter a sequence of characters '_' (no match), 'g' (green), and 'y' (yellow) indicating the results from your guess on Wordle. For example, if you guessed \"FLUTE\" and the letters 'L' and 'T' were green and yellow respectively, enter: \"_g_y_\".")

		let results = Prompt.promptForGuessResult(
			"\nEnter your results: ",
			invalidEntryText: "Invalid entry. The response must contain five characters, and each character should be 'g', 'y', or '_'."
		)
		return GuessResults(guess: guessWord!, results: results)
	}

	private func printWords<S: Sequence>(_ words: S) where S.Element == String {
		for (index, word) in words.enumerated() {
			print("\(index + 1)) \(word)")
		}
	}
}
