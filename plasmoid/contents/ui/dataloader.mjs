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
