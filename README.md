# currency-converter

[![CI](https://github.com/pixyzehn/currency-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/pixyzehn/currency-converter/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpixyzehn%2Fcurrency-converter%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pixyzehn/currency-converter)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpixyzehn%2Fcurrency-converter%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pixyzehn/currency-converter)

A simple currency converter library using the XML data from [expenses.cash](https://expenses.cash) (originally from [European Central Bank](https://www.ecb.europa.eu/home/html/index.en.html)). The library has been created and used for [Expenses.app](https://expenses.cash). It fetches the latest foreign exchange reference rates and returns the objects in a simple way.

Each fetch expects a single dated snapshot with one entry per currency. Duplicate currencies or multiple dated snapshots cause an `XMLParserError` instead of combining ambiguous rates.

Currency rows must be direct children of the dated snapshot. EUR is the implicit base currency, so explicit EUR rows are rejected.

Network fetches use asynchronous URLSession requests. The completion-based API requires a `@Sendable` closure and delivers network results on the session's delegate queue; dispatch UI updates to the main actor. Fetches initialized with `Data` invoke completion synchronously. HTTP errors and transport failures are reported as `XMLParserError`.

Conversions return `nil` for nonfinite amounts, nonpositive or nonfinite stored rates, and arithmetic that produces a nonfinite result. Lists omit invalid conversions and return an empty array for nonfinite amounts. These checks also apply to rates supplied through the public initializer or decoded from stored data. Finite zero and negative amounts remain supported.
