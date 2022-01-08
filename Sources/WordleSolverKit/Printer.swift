// This functionality is borrowed with ❤️ from swift-argument-parser.
// Attribution:

//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

struct Printer {
	static var systemScreenWidth: Int {
		_terminalSize().width
	}

	private init() {}

	/// Print text that wraps based on the size of the terminal window
	static func print(_ text: String, indentWidth: Int = 0, terminator: String = "\n") {
		Swift.print(text.wrapped(to: systemScreenWidth, wrappingIndent: indentWidth), terminator: terminator)
	}
}

private extension String {
	func wrapped(to columns: Int, wrappingIndent: Int = 0) -> String {
		let columns = columns - wrappingIndent
		var result: [Substring] = []

		var currentIndex = startIndex

		while true {
			let nextChunk = self[currentIndex...].prefix(columns)
			if let lastLineBreak = nextChunk.lastIndex(of: "\n") {
				result.append(contentsOf: self[currentIndex..<lastLineBreak].split(separator: "\n", omittingEmptySubsequences: false))
				currentIndex = index(after: lastLineBreak)
			} else if nextChunk.endIndex == self.endIndex {
				result.append(self[currentIndex...])
				break
			} else if let lastSpace = nextChunk.lastIndex(of: " ") {
				result.append(self[currentIndex..<lastSpace])
				currentIndex = index(after: lastSpace)
			} else if let nextSpace = self[currentIndex...].firstIndex(of: " ") {
				result.append(self[currentIndex..<nextSpace])
				currentIndex = index(after: nextSpace)
			} else {
				result.append(self[currentIndex...])
				break
			}
		}

		return result
			.map { $0.isEmpty ? $0 : String(repeating: " ", count: wrappingIndent) + $0 }
			.joined(separator: "\n")
	}
}

#if canImport(Glibc)
import Glibc
func ioctl(_ a: Int32, _ b: Int32, _ p: UnsafeMutableRawPointer) -> Int32 {
	ioctl(CInt(a), UInt(b), p)
}
#elseif canImport(Darwin)
import Darwin
#elseif canImport(CRT)
import CRT
import WinSDK
#endif

private func _terminalSize() -> (width: Int, height: Int) {
#if os(WASI)
	// WASI doesn't yet support terminal size
	return (80, 25)
#elseif os(Windows)
	var csbi: CONSOLE_SCREEN_BUFFER_INFO = CONSOLE_SCREEN_BUFFER_INFO()

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi)
	return (width: Int(csbi.srWindow.Right - csbi.srWindow.Left) + 1,
			height: Int(csbi.srWindow.Bottom - csbi.srWindow.Top) + 1)
#else
	var w = winsize()
#if os(OpenBSD)
	// TIOCGWINSZ is a complex macro, so we need the flattened value.
	let tiocgwinsz = Int32(0x40087468)
	let err = ioctl(STDOUT_FILENO, tiocgwinsz, &w)
#else
	let err = ioctl(STDOUT_FILENO, TIOCGWINSZ, &w)
#endif
	let width = Int(w.ws_col)
	let height = Int(w.ws_row)
	guard err == 0 else { return (80, 25) }
	return (width: width > 0 ? width : 80,
			height: height > 0 ? height : 25)
#endif
}
