//
//  Cartfile.swift
//  Carthage
//
//  Created by Justin Spahr-Summers on 2014-10-10.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import Foundation
import LlamaKit

/// Represents a Cartfile, which is a specification of a project's dependencies
/// and any other settings Carthage needs to build it.
public struct Cartfile {
	/// The dependencies listed in the Cartfile.
	public var dependencies: [Dependency]

	/// Attempts to parse Cartfile information from a string.
	public static func fromString(string: String) -> Result<Cartfile> {
		var cartfile = self(dependencies: [])
		var result = success(())

		let ignoreSet = NSMutableCharacterSet(charactersInString: "#")
		ignoreSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		(string as NSString).enumerateLinesUsingBlock { (line, stop) in
			let scanner = NSScanner(string: line)
			scanner.scanCharactersFromSet(ignoreSet, intoString: nil)

			if scanner.atEnd {
				return
			}

			switch (Dependency.fromScanner(scanner)) {
			case let .Success(dep):
				cartfile.dependencies.append(dep.unbox)

			case let .Failure(error):
				result = failure(error)
				stop.memory = true
			}

			scanner.scanCharactersFromSet(ignoreSet, intoString: nil)
			if !scanner.atEnd {
				result = failure()
				stop.memory = true
			}
		}

		return result.map { _ in cartfile }
	}
}

extension Cartfile: Printable {
	public var description: String {
		return "\(dependencies)"
	}
}

/// Represents a single dependency of a project.
public struct Dependency: Equatable {
	/// The GitHub repository in which this dependency lives.
	public var repository: Repository

	/// The version(s) that are required to satisfy this dependency.
	public var version: VersionSpecifier

	/// Attempts to parse a Dependency specification.
	public static func fromScanner(scanner: NSScanner) -> Result<Dependency> {
		if !scanner.scanString("github", intoString: nil) {
			return failure()
		}

		if !scanner.scanUpToString("\"", intoString: nil) || !scanner.scanString("\"", intoString: nil) {
			return failure()
		}

		var repoNWO: NSString? = nil
		if !scanner.scanUpToString("\"", intoString: &repoNWO) || !scanner.scanString("\"", intoString: nil) {
			return failure()
		}

		if let repoNWO = repoNWO {
			return Repository.fromNWO(repoNWO).flatMap { repo in
				scanner.scanCharactersFromSet(NSCharacterSet.whitespaceCharacterSet(), intoString: nil)

				return VersionSpecifier.fromScanner(scanner).map { specifier in self(repository: repo, version: specifier) }
			}
		} else {
			return failure()
		}
	}
}

public func ==(lhs: Dependency, rhs: Dependency) -> Bool {
	return lhs.repository == rhs.repository && lhs.version == rhs.version
}

extension Dependency: Printable {
	public var description: String {
		return "\(repository) @ \(version)"
	}
}

/// A semantic version.
public struct Version: Comparable {
	/// The major version.
	///
	/// Increments to this component represent incompatible API changes.
	public let major: Int

	/// The minor version.
	///
	/// Increments to this component represent backwards-compatible
	/// enhancements.
	public let minor: Int

	/// The patch version.
	///
	/// Increments to this component represent backwards-compatible bug fixes.
	public let patch: Int

	/// A list of the version components, in order from most significant to
	/// least significant.
	public var components: [Int] {
		return [ major, minor, patch ]
	}

	public init(major: Int, minor: Int, patch: Int) {
		self.major = major
		self.minor = minor
		self.patch = patch
	}

	/// Attempts to parse a semantic version from a human-readable string of the
	/// form "a.b.c".
	static public func fromString(specifier: String) -> Result<Version> {
		let components = split(specifier, { $0 == "." }, allowEmptySlices: false)
		if components.count == 0 {
			return failure()
		}

		let major = components[0].toInt()
		if major == nil {
			return failure()
		}

		let minor = (components.count > 1 ? components[1].toInt() : 0)
		let patch = (components.count > 2 ? components[2].toInt() : 0)

		return success(self(major: major!, minor: minor ?? 0, patch: patch ?? 0))
	}
}

public func <(lhs: Version, rhs: Version) -> Bool {
    return lexicographicalCompare(lhs.components, rhs.components)
}

public func ==(lhs: Version, rhs: Version) -> Bool {
	return lhs.components == rhs.components
}

extension Version: Printable {
	public var description: String {
		return ".".join(components.map { $0.description })
	}
}

/// Describes which versions are acceptable for satisfying a dependency
/// requirement.
public enum VersionSpecifier: Equatable {
	case Any
	case Exactly(Version)
	case AtLeast(Version)
	case CompatibleWith(Version)

	/// Attempts to parse a VersionSpecifier.
	public static func fromScanner(scanner: NSScanner) -> Result<VersionSpecifier> {
		func scanVersion() -> Result<Version> {
			let characterSet = NSCharacterSet(charactersInString: "0123456789.")
			scanner.scanUpToCharactersFromSet(characterSet, intoString: nil)

			var version: NSString? = nil
			if scanner.scanCharactersFromSet(characterSet, intoString: &version) {
				if let version = version {
					return Version.fromString(version)
				}
			}

			return failure()
		}

		if scanner.scanString("==", intoString: nil) {
			return scanVersion().map { Exactly($0) }
		} else if scanner.scanString(">=", intoString: nil) {
			return scanVersion().map { AtLeast($0) }
		} else if scanner.scanString("~>", intoString: nil) {
			return scanVersion().map { CompatibleWith($0) }
		} else {
			return success(Any)
		}
	}
}

public func ==(lhs: VersionSpecifier, rhs: VersionSpecifier) -> Bool {
	switch (lhs, rhs) {
	case let (.Any, .Any):
		return true

	case let (.Exactly(left), .Exactly(right)):
		return left == right

	case let (.AtLeast(left), .AtLeast(right)):
		return left == right

	case let (.AtLeast(left), .AtLeast(right)):
		return left == right

	default:
		return false
	}
}

extension VersionSpecifier: Printable {
	public var description: String {
		switch (self) {
		case let .Any:
			return "(any)"

		case let .Exactly(version):
			return "== \(version)"

		case let .AtLeast(version):
			return ">= \(version)"

		case let .CompatibleWith(version):
			return "~> \(version)"
		}
	}
}
