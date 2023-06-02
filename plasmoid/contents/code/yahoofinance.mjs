/**
 *  This file is part of YapStocks.
 *
 *  Copyright 2020 Symeon Huang (@librehat)
 *
 *  YapStocks is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  YapStocks is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with YapStocks.  If not, see <https://www.gnu.org/licenses/>.
 */

import { httpRequestP } from "httprequest.mjs";

/**
 * A wrapper to get the 'raw' value from Yahoo Finance's response
 * @param {Object|null} val
 * @return {Number|null}
 */
function getRawVal(val) {
    return (val && val.raw !== undefined) ? val.raw : "N/A";
}

/**
 * Resolves a security symbol from Yahoo Finance and gets its price charts
 * @param {String} symbol
 * @param {String} range
 * @param {String} interval
 * @return {Promise}
 */
export function resolveChart(symbol, range, interval) {
    return httpRequestP(`https://query1.finance.yahoo.com/v8/finance/chart/${symbol}?symbol=${symbol}&range=${range}&interval=${interval}`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (resp.chart.error) {
            console.log(`Error while resolving ${symbol}:`, JSON.stringify(resp.chart.error));
            throw new Error(resp.chart.error.description);
        }
        const result = resp.chart.result[0];
        const meta = result.meta;
        const quote = result.indicators.quote[0];
        console.debug("number of timeseries", result.timestamp.length);
        return {
            symbol: meta.symbol,
            currency: meta.currency,
            instrument: meta.instrumentType,
            exchange: meta.exchangeName,
            currentPrice: meta.regularMarketPrice,
            previousClose: meta.previousClose,
            priceChange: meta.regularMarketPrice - meta.previousClose,
            priceChangePercentage: (meta.regularMarketPrice - meta.previousClose) / meta.previousClose * 100,
            priceDecimals: meta.priceHint === null ? 2 : meta.priceHint,
            updatedDateTime: new Date(meta.regularMarketTime * 1000),
            exchange: {
                timezone: meta.timezone,
                timezoneName: meta.exchangeTimezoneName,
                tradingPeriod: {
                    start: meta.currentTradingPeriod.regular.start,
                    end: meta.currentTradingPeriod.regular.end,
                },
            },
            timeseries: result.timestamp.map((timestamp, idx) => ({
                timestamp: timestamp * 1000,
                open: quote.open[idx],
                close: quote.close[idx],
                high: quote.high[idx],
                low: quote.low[idx],
                volume: quote.volume[idx],
            })),
        };
    });
}

/**
 * Resolves a security symbol from Yahoo Finance and gets its quote summary
 * @param {String} symbol
 * @return {Promise}
 */
export function resolveQuote(symbol) {
    return httpRequestP(`https://query1.finance.yahoo.com/v10/finance/quoteSummary/${symbol}?modules=price`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (resp.quoteSummary.error) {
            console.log(`Error while resolving ${symbol}:`, JSON.stringify(resp.quoteSummary.error));
            throw new Error(resp.quoteSummary.error.description);
        }
        const priceResult = resp.quoteSummary.result[0].price;
        // we do our own `toFixed()` instead of using `fmt` because the number locale can be different (',' or '.' for the thousands)
        const decimals = priceResult.priceHint ? priceResult.priceHint.raw : 2;
        return {
            symbol: priceResult.symbol,
            currency: priceResult.currency,
            shortName: priceResult.shortName,
            longName: priceResult.longName || priceResult.shortName,
            instrument: priceResult.quoteType,
            exchange: priceResult.exchange,
            exchangeName: priceResult.exchangeName,
            currentPrice: getRawVal(priceResult.regularMarketPrice),
            dayHighPrice: getRawVal(priceResult.regularMarketDayHigh),
            dayLowPrice: getRawVal(priceResult.regularMarketDayHigh),
            openPrice: getRawVal(priceResult.regularMarketOpen),
            volume: getRawVal(priceResult.regularMarketVolume),
            updatedDateTime: new Date(priceResult.regularMarketTime * 1000),
            priceChange: getRawVal(priceResult.regularMarketChange),
            priceChangePercentage: getRawVal(priceResult.regularMarketChangePercent),
            priceDecimals: decimals,
            previousClose: getRawVal(priceResult.regularMarketPreviousClose),
            marketCap: getRawVal(priceResult.marketCap),
        };
    });
}

/**
 * Gets basic information about multiple symbols
 * @param {String[]} symbols
 */
export function resolveMultipleQuotes(symbols) {
    if (symbols.length === 0) {
        return Promise.resolve([]);
    }
    /** FIXME: no longer working
    return httpRequestP(`https://query2.finance.yahoo.com/v6/finance/quote?symbols=${symbols.join(",")}&fields=symbol,longName,shortName,exchange,quoteType,regularMarketPrice,regularMarketTime,regularMarketChange,regularMarketVolume,regularMarketDayRange,regularMarketOpen,regularMarketChangePercent,marketCap`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (resp.quoteResponse.error) {
            console.log(`Error while resolving ${symbols.join(",")}:`, JSON.stringify(resp.quoteResponse.error));
            throw new Error(resp.quoteResponse.error.description);
        }
        return resp.quoteResponse.result.map((result) => ({
            symbol: result.symbol,
            currency: result.currency || "",
            shortName: result.shortName || "N/A",
            longName: result.longName || result.shortName,
            instrument: result.quoteType || "N/A",
            exchange: result.exchange || "N/A",
            exchangeName: result.fullExchangeName || "N/A",
            currentPrice: result.regularMarketPrice || "N/A",
            dayHighPrice: result.regularMarketDayHigh || "N/A",
            dayLowPrice: result.regularMarketDayHigh || "N/A",
            openPrice: result.regularMarketOpen || "N/A",
            volume: result.regularMarketVolume || "N/A",
            updatedDateTime: new Date(result.regularMarketTime * 1000),
            priceChange: result.regularMarketChange || "N/A",
            priceChangePercentage: result.regularMarketChangePercent || "N/A",
            priceDecimals: result.priceHint || 2,
            previousClose: result.regularMarketPreviousClose || "N/A",
            marketCap: result.marketCap || "N/A"
        }));
    });
    */
    return Promise.all(symbols.map(resolveQuote));
}

/**
 * Resolves a security symbol from Yahoo Finance and gets its profile
 * @param {String} symbol
 * @return {Promise}
 *
 * Returned object in the promise has a structure like:
 * {
 *   "summaryProfile": {Object|null},
 *   "summaryDetail": {Object|null},
 *   "components": {Object[]|null},  // results from `resolveMultipleQuotes`
 * }
 * `null` is used to indicate that such information is not available for the symbol.
 */
export function resolveProfile(symbol) {
    const isIndex = symbol.startsWith("^");
    const modules = isIndex ? "summaryDetail%2Ccomponents" : "summaryProfile%2CsummaryDetail";
    return httpRequestP(`https://query1.finance.yahoo.com/v10/finance/quoteSummary/${symbol}?modules=${modules}`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (resp.quoteSummary.error) {
            console.log(`Error while resolving ${symbol}:`, JSON.stringify(resp.quoteSummary.error));
            throw new Error(resp.quoteSummary.error.description);
        }
        const result = resp.quoteSummary.result[0];

        const detailResult = result.summaryDetail;
        const decimals = detailResult.priceHint ? detailResult.priceHint.raw : 2;
        const summaryDetail = {
            currency: detailResult.currency,
            priceHistory: {
                beta: getRawVal(detailResult.beta),
                fiftyTwoWeekLow: getRawVal(detailResult.fiftyTwoWeekLow),
                fiftyTwoWeekHigh: getRawVal(detailResult.fiftyTwoWeekHigh),
                fiftyDayAverage: getRawVal(detailResult.fiftyDayAverage),
                twoHundredDayAverage: getRawVal(detailResult.twoHundredDayAverage),
            },
            dividend: {
                rate: getRawVal(detailResult.dividendRate),
                yield: getRawVal(detailResult.dividendYield),
                exDate: detailResult.exDividendDate ? detailResult.exDividendDate.fmt : null,
                trailingAnnualRate: getRawVal(detailResult.trailingAnnualDividendRate),
                trailingAnnualYield: getRawVal(detailResult.trailingAnnualDividendYield),
            },
            priceDecimals: decimals,
        };

        let summaryProfile = null, components = null;
        if (isIndex) { // components for index only
            components = result.components.components; // this could be null (e.g. ^SPX)
        } else { // summaryProfile for non-index only
            const profileResult = result.summaryProfile;
            const addresses = [profileResult.address1, profileResult.address2, profileResult.city, profileResult.zip, profileResult.country].filter(a => !!a);
            summaryProfile = {
                address: addresses.join(", "),
                phone: profileResult.phone,
                website: profileResult.website,
                industry: profileResult.industry,
                sector: profileResult.sector,
                description: profileResult.longBusinessSummary,
                fullTimeEmployees: profileResult.fullTimeEmployees,
            };
        }

        return {
            summaryProfile,
            summaryDetail,
            components,
        };
    });
}

/**
 * Searches for financial symbols by a keyword
 * @param {String} keyword
 * @param {Number} maxCount
 *
 * The resolved result promise is an array of objects in the format shown below:
 * {
 *   "symbol": {String},
 *   "shortName": {String},
 *   "longName": {String},
 *   "instrument": {String},
 *   "exchange": {String},
 * }
 *
 * Only the quotes that have 'isYahooFinance' as 'true' will be returned.
 */
export function searchQuotes(keyword, maxCount = 6) {
    return httpRequestP(`https://query2.finance.yahoo.com/v1/finance/search?q=${keyword}&quotesCount=${maxCount}&newsCount=0`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (!resp.quotes) {
            console.log(`Unknown error while searching ${keyword}`, text);
            throw new Error("Unknown error");
        }
        return resp.quotes.filter((quote) => quote.isYahooFinance)
        .map((quote) => ({
            "symbol": quote.symbol,
            "shortName": quote.shortname,
            "longName": quote.longname || quote.shortname,
            "instrument": quote.typeDisp,
            "exchange": quote.exchange
        }));
    });
}
