A little command line app for finding the answer to Wordle puzzles, written in Swift.

## Installation

Currently, the easiest way to install the app is to clone the repo and use the Makefile:

> Note: You will need the Xcode Command Line Tools to install this app. You can get them by running `xcode-select –install`.

```bash
git clone https://github.com/daltonclaybrook/wordle-solver.git
cd wordle-solver
make install
```

## Running the app

After you've installed the app, you can run it by invoking `wordle-solver` in your terminal. You should see something like the following:

```
✨ Welcome to the Wordle Solver! ✨

Choose a word for your first guess.
You can enter any word, but here are a few suggestions:

terms
cants
gurls
scrag
drows

Enter your guess, or press the return key without guessing to see more suggestions
> 
```

## As a library

You can bring this package into your own Swift project and use it as a library if you like.

In Xcode, you can add this package to your project by selecting File -> Swift Packages -> Add Package Dependency… Enter the GitHub URL and follow the prompts.

If you use a Package.swift file instead, add the following line inside of your package dependencies array:

```swift
.package(url: "https://github.com/daltonclaybrook/wordle-solver", .branch("main")),
```

Now add WordleSolverKit as a dependency of any relevant targets:

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "WordleSolverKit", package: "wordle-solver"),
]),
```

## License

WordleSolver is available under the MIT license. See [LICENSE.md](https://github.com/daltonclaybrook/wordle-solver/blob/main/LICENSE.md) for more information.
