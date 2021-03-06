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

import { resolveChart, resolveMultipleQuotes } from "yahoofinance.mjs"

/**
 * Provides a map to map from our UI "period" to Yahoo's range and interval
 */
const PeriodMap = Object.freeze({
    "1D": {
        range: "1d",
        interval: "2m",
    },
    "5D": {
        range: "5d",
        interval: "15m",
    },
    "1M": {
        range: "1mo",
        interval: "1h",
    },
    "6M": {
        range: "6mo",
        interval: "1d",
    },
    "YTD": {
        range: "ytd",
        interval: "1d",
    },
    "1Y": {
        range: "1y",
        interval: "1d",
    },
    "5Y": {
        range: "5y",
        interval: "1wk",
    },
    "Max": {
        range: "max",
        interval: "1mo",
    },
});

/**
 * The entry point of the worker thread
 *
 * The message schema is slightly different depending on the `action`.
 * Once the action is finished, the worker script sends a message back.
 * If an error occurred, that message would contain field `error`.
 *
 * @param {Object} msg
 * @param {String} msg.action "modify", "refresh", "chart"
 * @param {String[]} [msg.symbols] symbols for action "modify"
 * @param {String} [msg.symbol] single symbol for action "chart"
 * @param {String} [msg.period] the period for action "chart"
 * @param {ListModel} msg.model
 */
WorkerScript.onMessage = (msg) => {
    console.debug("worker received a message", JSON.stringify(msg));
    return Promise.resolve().then(() => {
        if (msg.action === "modify") {
            msg.model.clear();
            return resolveMultipleQuotes(msg.symbols).then((results) => {
                results.forEach((result) => msg.model.append(result));
                msg.model.sync();
                WorkerScript.sendMessage({ action: msg.action });
            });
        }
        if (msg.action === "refresh") {
            const symbolIndexMap = new Map();
            const symbols = [];
            for (let i = 0; i < msg.model.count; ++i) {
                const symbol = msg.model.get(i).symbol;
                symbols.push(symbol);
                symbolIndexMap.set(symbol, i);
            }
            return resolveMultipleQuotes(symbols).then((results) => {
                results.forEach((result) => {
                    msg.model.set(symbolIndexMap.get(result.symbol), result);
                });
                msg.model.sync();
                WorkerScript.sendMessage({ action: msg.action });
            });
        }
        if (msg.action === "chart") {
            return resolveChart(msg.symbol, PeriodMap[msg.period].range, PeriodMap[msg.period].interval)
            .then((result) => {
                let minVal = result.currentPrice, maxVal = result.currentPrice;
                let minTime = result.updatedDateTime, maxTime = result.updatedDateTime;
                result.timeseries.forEach((data) => {
                    if (data.low !== null) {
                        minVal = Math.min(minVal, data.low);
                    }
                    if (data.high !== null) {
                        maxVal = Math.max(maxVal, data.high);
                    }
                    if (data.timestamp) {
                        minTime = Math.min(minTime, data.timestamp);
                        maxTime = Math.max(maxTime, data.timestamp);
                    }
                });
                result.axes = {
                    minTime,
                    maxTime,
                    minVal,
                    maxVal,
                };
                WorkerScript.sendMessage({
                    action: msg.action,
                    data: result,
                });
            });
        }
    }).catch((error) => {
        console.log("Got an error", JSON.stringify(error));
        WorkerScript.sendMessage({
            action: msg.action,
            error: error,
        });
    });
};
