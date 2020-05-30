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
            throw new Error(resp.quoteSummary.error.description);
        }
        const priceResult = resp.quoteSummary.result[0].price;
        return {
            symbol: priceResult.symbol,
            currency: priceResult.currency,
            longName: priceResult.longName || priceResult.shortName,
            instrument: priceResult.quoteType,
            exchange: priceResult.exchange,
            exchangeName: priceResult.exchangeName.raw,
            currentPrice: priceResult.regularMarketPrice.raw,
            dayHighPrice: priceResult.regularMarketDayHigh.raw,
            dayLowPrice: priceResult.regularMarketDayLow.raw,
            openPrice: priceResult.regularMarketOpen.raw,
            volume: priceResult.regularMarketVolume.raw,
            updatedDateTime: new Date(priceResult.regularMarketTime * 1000),
            priceChange: priceResult.regularMarketChange.raw,
            priceChangePercentage: priceResult.regularMarketChangePercent.raw * 100,
            previousClose: priceResult.regularMarketPreviousClose.raw,
            marketCap: priceResult.marketCap.raw,
        };
    });
}
