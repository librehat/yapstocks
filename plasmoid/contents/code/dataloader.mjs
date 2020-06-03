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

import { resolveQuote } from "yahoofinance.mjs"

/**
 * @param {Object} msg
 * @param {String} msg.action "modify", "refresh"
 * @param {String[]} [msg.symbols] symbols for action "modify"
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
            });
        }
    }).catch((error) => {
        console.log("Got an error", JSON.stringify(error));
    }).then(() => WorkerScript.sendMessage({}));
};
