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
        const meta = resp.chart.result[0].meta;
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
            // TODO: add historical data points to the response
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
