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
 * Resolves a security symbol from Yahoo Finance and gets its price charts
 * @param {String} symbol
 * @return {Promise}
 */
export function resolveChart(symbol) {
    return httpRequestP(`https://query1.finance.yahoo.com/v8/finance/chart/${symbol}?symbol=${symbol}`)
    .then((text) => {
        const resp = JSON.parse(text);
        if (resp.chart.error) {
            console.log(`Error while resolving ${symbol}:`, JSON.stringify(resp.chart.error));
            throw new Error(resp.chart.error.description);
        }
        const result = resp.chart.result[0];
        const meta = result.meta;
        const quote = result.indicators.quote[0];
        return {
            symbol: meta.symbol,
            currency: meta.currency,
            instrument: meta.instrumentType,
            exchange: meta.exchangeName,
            currentPrice: meta.regularMarketPrice,
            previousClose: meta.previousClose,
            priceChange: meta.regularMarketPrice - meta.previousClose,
            priceChangePercentage: (meta.regularMarketPrice - meta.previousClose) / meta.previousClose * 100,
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
        return {
            symbol: priceResult.symbol,
            currency: priceResult.currency,
            longName: priceResult.longName || priceResult.shortName,
            instrument: priceResult.quoteType,
            exchange: priceResult.exchange,
            exchangeName: priceResult.exchangeName ? priceResult.exchangeName.raw : null,
            currentPrice: priceResult.regularMarketPrice ? priceResult.regularMarketPrice.raw : null,
            dayHighPrice: priceResult.regularMarketDayHigh ? priceResult.regularMarketDayHigh.raw : null,
            dayLowPrice: priceResult.regularMarketDayHigh ? priceResult.regularMarketDayLow.raw : null,
            openPrice: priceResult.regularMarketOpen ? priceResult.regularMarketOpen.raw : null,
            volume: priceResult.regularMarketVolume ? priceResult.regularMarketVolume.raw : null,
            updatedDateTime: new Date(priceResult.regularMarketTime * 1000),
            priceChange: priceResult.regularMarketChange ? priceResult.regularMarketChange.raw : null,
            priceChangePercentage: priceResult.regularMarketChangePercent ? priceResult.regularMarketChangePercent.raw * 100 : null,
            previousClose: priceResult.regularMarketPreviousClose ? priceResult.regularMarketPreviousClose.raw : null,
            marketCap: priceResult.marketCap ? priceResult.marketCap.raw : null,
        };
    });
}
