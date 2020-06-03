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

import { resolveChart, resolveQuote } from "yahoofinance.mjs"

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
 * @param {ListModel} msg.model
 */
WorkerScript.onMessage = (msg) => {
    console.debug("worker received a message", JSON.stringify(msg));
    return Promise.resolve().then(() => {
        if (msg.action === "modify") {
            msg.model.clear();
            return Promise.all(msg.symbols.map(resolveQuote)).then((results) => {
                results.forEach((result) => msg.model.append(result));
                msg.model.sync();
                WorkerScript.sendMessage({ action: msg.action });
            });
        }
        if (msg.action === "refresh") {
            const promises = [];
            const symbolIndexMap = new Map();
            for (let i = 0; i < msg.model.count; ++i) {
                const symbol = msg.model.get(i).symbol;
                promises.push(resolveQuote(symbol));
                symbolIndexMap.set(symbol, i);
            }
            return Promise.all(promises).then((results) => {
                results.forEach((result) => {
                    msg.model.set(symbolIndexMap.get(result.symbol), result);
                });
                msg.model.sync();
                WorkerScript.sendMessage({ action: msg.action });
            });
        }
        if (msg.action === "chart") {
            return resolveChart(msg.symbol).then((result) => {
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
