/**
 * Sends an HTTP request to the url
 * @param {String} url
 * @return {Promise}
 */
export function httpRequestP(url) {
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
}
