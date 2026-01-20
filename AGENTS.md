# Repository Guidelines

## Project Structure & Module Organization
The library lives in `Sources/CurrencyConverter/` (public API, XML parsing, models). Tests are in `Tests/CurrencyConverterTests/`. Generated DocC output is committed under `docs/` and is produced from the Swift package target `CurrencyConverter`. `Package.swift` defines the SPM package and dependency on `swift-docc-plugin`.

## Build, Test, and Development Commands
- `swift build` compiles the package.
- `swift test` runs the Swift Testing test suite.
- `swift package --allow-writing-to-directory ./docs generate-documentation --target CurrencyConverter --output-path ./docs --transform-for-static-hosting --hosting-base-path currency-converter` regenerates static DocC docs.
- `swift package --disable-sandbox preview-documentation --product CurrencyConverter` previews DocC locally.

## Coding Style & Naming Conventions
Use standard Swift style as seen in existing files: 4-space indentation, opening braces on the same line, and doc comments (`///`) for public API. Name types in `PascalCase` (e.g., `ReferenceRates`), properties and methods in `lowerCamelCase` (e.g., `fetch()`), and keep filenames aligned with the primary type.

## Testing Guidelines
Tests use the Swift Testing framework (`import Testing`, `@Test`, `#expect`). Test functions are named in `lowerCamelCase` inside `CurrencyConverterTests`. The `converterFetch` test hits the live XML endpoint, so network access is required; prefer `CurrencyConverter(data:)` with fixture XML for deterministic tests.

## Commit & Pull Request Guidelines
Recent commits use short, imperative subjects starting with a capital letter (e.g., "Update docs"), with no conventional-commit prefix. Keep subjects concise (<=50 chars) and avoid trailing periods. For PRs, include a brief summary, list tests run (e.g., `swift test`), and note documentation updates if public API changes.
