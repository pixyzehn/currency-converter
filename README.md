# currency-converter

A simple currency converter library using the XML data from [European Central Bank (ECB)](https://www.ecb.europa.eu/home/html/index.en.html). The library has been created and used for [Expenses.app](https://getexpenses.app). It fetches the latest foreign exchange reference rates and returns the objects in a simple way.

Note that the reference rates are usually updated around 16:00 CET on every working day, except on [TARGET closing days](https://www.ecb.europa.eu/services/contacts/working-hours/html/index.en.html). They are based on a regular daily concertation procedure between central banks across Europe, which normally takes place at 14:15 CET. For more info, see [the source](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html).
