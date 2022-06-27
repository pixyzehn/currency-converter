# currency-converter

[![CI](https://github.com/pixyzehn/currency-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/pixyzehn/currency-converter/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpixyzehn%2Fcurrency-converter%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pixyzehn/currency-converter)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpixyzehn%2Fcurrency-converter%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pixyzehn/currency-converter)

A simple currency converter library using the XML data from [European Central Bank (ECB)](https://www.ecb.europa.eu/home/html/index.en.html). The library has been created and used for [Expenses.app](https://getexpenses.app). It fetches the latest foreign exchange reference rates and returns the objects in a simple way.

Note that the reference rates are usually updated around 16:00 CET on every working day, except on [TARGET closing days](https://www.ecb.europa.eu/services/contacts/working-hours/html/index.en.html). They are based on a regular daily concertation procedure between central banks across Europe, which normally takes place at 14:15 CET. For more info, see [the source](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html).

## Converting Documentation

```shell
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target CurrencyConverter --output-path ./docs \
    --transform-for-static-hosting --hosting-base-path currency-converter
```

## Previewing Documentation

```shell
swift package --disable-sandbox preview-documentation --product CurrencyConverter
```

See also [apple/swift-docc-plugin](https://github.com/apple/swift-docc-plugin) for more information.
