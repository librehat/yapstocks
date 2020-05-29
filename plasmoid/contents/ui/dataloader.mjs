/**
 * Sends an HTTP request to the url
 * @param {String} url
 * @return {Promise}
 */
const HttpRequestP = (url) => {
    const xhr = new XMLHttpRequest();
    return new Promise((resolve, reject) => {
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            if (xhr.status >= 200 && xhr.status < 300) {
                resolve(xhr.responseText);
            } else {
                reject(xhr.statusText);
            }
        };
        xhr.onerror = reject;
        xhr.open('GET', url, true);
        xhr.send();
    });
};

/**
 * Resolves a security symbol from Yahoo Finance
 * @param {String} symbol
 * @return {Promise}
 */
const resolveSymbol = (symbol) => {
    return HttpRequestP(`https://query1.finance.yahoo.com/v8/finance/chart/${symbol}?symbol=${symbol}`)
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
            exchangeName: meta.exchangeName,
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
        };
    });
};

/**
 * @param {Object} msg
 * @param {String} msg.action "modify", "refresh"
 * @param {String[]} [msg.symbols] symbols for action "modify"
 * @param {ListModel} msg.model
 */
WorkerScript.onMessage = (msg) => {
    return Promise.resolve().then(() => {
        if (msg.action === "modify") {
            msg.model.clear();
            return Promise.all(msg.symbols.map(resolveSymbol)).then((results) => {
                results.forEach((result) => msg.model.append(result));
                msg.model.sync();
            });
        }
        if (msg.action === "refresh") {
            const promises = [];
            const symbolIndexMap = new Map();
            for (let i = 0; i < msg.model.count; ++i) {
                const symbol = msg.model.get(i).symbol;
                promises.push(resolveSymbol(symbol));
                symbolIndexMap.set(symbol, i);
            }
            return Promise.all(promises).then((results) => {
                results.forEach((result) => {
                    msg.model.set(symbolIndexMap.get(result.symbol), result);
                });
                msg.model.sync();
            });
        }
    }).catch((error) => {
        console.log("Got an error", JSON.stringify(error));
    }).then(() => WorkerScript.sendMessage({}));
};
