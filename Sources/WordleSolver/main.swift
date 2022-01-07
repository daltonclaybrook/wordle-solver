import Foundation

var wordSet = WordSet(
	allWords: Set(fiveLetterWords.components(separatedBy: "\n"))
)

print("✨ Welcome to the Wordle Solver! ✨\n")

let maxDisplayedCandidates = 5
let allFirstGuessCandidates = wordSet.allWordsMeetingCriteriaForFirstGuess()

func printWords<S: Sequence>(_ words: S) where S.Element == String {
	for (index, word) in words.enumerated() {
		print("\(index + 1)) \(word)")
	}
}

var candidatesForNextGuess = allFirstGuessCandidates
for guessIndex in 0..<5 {
	let countToDisplay = min(candidatesForNextGuess.count, maxDisplayedCandidates)

	print("Choose a word for guess #\(guessIndex + 1):\n")
	var guessWords = candidatesForNextGuess.shuffled()[0..<countToDisplay]
	printWords(guessWords)

	var guessWord: String?
	while guessWord == nil {
		let choiceNumber = promptAndTransform(
			"\nPick a number (Enter \(countToDisplay + 1) to reshuffle): ",
			invalidEntryText: "Invalid choice, try again...",
			transformBlock: Int.init
		)

		if choiceNumber == countToDisplay + 1 {
			// reshuffle
			guessWords = candidatesForNextGuess.shuffled()[0..<countToDisplay]
			print("") // line break
			printWords(guessWords)
		} else if choiceNumber >= 1 && choiceNumber <= guessWords.count {
			// valid choice
			let word = guessWords[choiceNumber - 1]
			let accepted = promptForYesNo("Enter your choice (\(word)) on Wordle. Was it accepted? (y/n): ")
			if accepted {
				guessWord = word
			}
		} else {
			print("Invalid choice, try again...")
		}
	}

	print("\nEnter a sequence of characters '_' (no match), 'g' (green), and 'y' (yellow) indicating the results from your guess on Worlde. For example, if you guessed \"FLUTE\" and the letters 'L' and 'T' were green and yellow respectively, enter: \"_g_y_\".")
	let results = promptForGuessResult("\nEnter your results: ", invalidEntryText: "Invalid entry. The response must contain five characters, and each character should be 'g', 'y', or '_'.")
	let guess = guessWord!
	wordSet.updateWith(guess: guess, results: results)

	candidatesForNextGuess = wordSet.remainingWords
	if candidatesForNextGuess.count <= 1 {
		break
	} else {
		print("\nThere are \(candidatesForNextGuess.count) valid words remaining!\n")
	}
}

if candidatesForNextGuess.count == 1 {
	print("\nThe correct answer is: \(candidatesForNextGuess.first!)!")
} else {
	print("The remaining valid words are:")
	print(candidatesForNextGuess.joined(separator: "\n"))
}
