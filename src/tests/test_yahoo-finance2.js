/*
 * Welcome!  After any changes, press Ctrl-S and see the results
 * in the "start" console.
 */
// import syntax (recommended)
import yahooFinance from 'yahoo-finance2';

// require syntax (if your code base does not support imports)
//const yahooFinance = require('yahoo-finance2').default; // NOTE the .default

const results = await yahooFinance.search('AAPL');
console.log(results);

//const results2 = await yahooFinance.search('AAPL', { someOption: true });
//console.log(results2);

const result = await yahooFinance.quoteSummary("AIR.PA", {
    // 1. Try adding, removing or changing modules
    // You'll get suggestions after typing first quote mark (")
    modules: ["price"]
});
console.log(result);

// 3. Try change "quoteSummary" above to something else
