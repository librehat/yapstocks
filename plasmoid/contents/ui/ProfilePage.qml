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
import QtQuick 2.12
import QtQuick.Layouts 1.12
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../code/yahoofinance.mjs" as YahooFinance

Item {
    id: root

    property bool loading: true
    property Item stack
    property string symbol

    RowLayout {
        id: controlsRow
        width: parent.width
        anchors.top: root.top

        PlasmaExtras.Title {
            Layout.fillWidth: true
            text: symbol
            elide: Text.ElideRight
        }

        PlasmaComponents.Button {
            icon.name: "draw-arrow-back"
            text: "Return"
            onClicked: stack.pop()
        }
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }

    PlasmaComponents.ScrollView {
        id: view
        anchors.top: controlsRow.bottom
        anchors.bottom: root.bottom
        width: root.width
        visible: !loading
        clip: true

        contentWidth: contentColumn.width
        contentHeight: contentColumn.height

        ColumnLayout {
            id: contentColumn
            // TODO: `parent.width` gives incorrect result :( try to fix this
            width: height > (root.height - controlsRow.height) ? root.width - units.gridUnit * 1.5 : root.width

            PlasmaExtras.Heading {
                Layout.fillWidth: true
                text: "Price History"
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Beta"
                }
                PlasmaComponents.Label {
                    id: beta
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "52-Week High"
                }
                PlasmaComponents.Label {
                    id: fiftyTwoWeekHigh
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "52-Week Low"
                }
                PlasmaComponents.Label {
                    id: fiftyTwoWeekLow
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "50-Day Moving Average"
                }
                PlasmaComponents.Label {
                    id: fiftyDayAverage
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "200-Day Moving Average"
                }
                PlasmaComponents.Label {
                    id: twoHundredDayAverage
                }
            }
            PlasmaExtras.Heading {
                Layout.fillWidth: true
                text: "Dividends"
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Forward Annual Dividend"
                }
                PlasmaComponents.Label {
                    id: dividend
                    text: "N/A"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Trailing Annual Dividend"
                }
                PlasmaComponents.Label {
                    id: trailingDividend
                    text: "N/A"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Ex-Dividend Date"
                }
                PlasmaComponents.Label {
                    id: exDividendDate
                }
            }

            ColumnLayout {
                id: profileColumn
                visible: false
                Layout.fillWidth: true

                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    text: "Address"
                }
                PlasmaExtras.Paragraph {
                    id: address
                    Layout.fillWidth: true
                }
                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    text: "Website"
                }
                PlasmaExtras.Paragraph {
                    id: website
                    Layout.fillWidth: true
                    linkColor: theme.textColor
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    text: "Classification"
                }
                RowLayout {
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: "Sector"
                    }
                    PlasmaComponents.Label {
                        id: sector
                    }
                }
                RowLayout {
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: "Industry"
                    }
                    PlasmaComponents.Label {
                        id: industry
                    }
                }
                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    text: "Description"
                }
                PlasmaExtras.Paragraph {
                    id: description
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                id: componentsColumn
                visible: false
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    text: "Components"
                }
                // TODO: v3: "main interface" (recursively nested) for components symbols
                PlasmaExtras.Paragraph {
                    id: componentsText
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component.onCompleted: {
        YahooFinance.resolveProfile(symbol).then((result) => {
            const priceHistory = result.summaryDetail.priceHistory;
            beta.text = priceHistory.beta ? priceHistory.beta : "N/A";
            fiftyTwoWeekHigh.text = priceHistory.fiftyTwoWeekHigh ? priceHistory.fiftyTwoWeekHigh : "N/A";
            fiftyTwoWeekLow.text = priceHistory.fiftyTwoWeekLow ? priceHistory.fiftyTwoWeekLow : "N/A";
            fiftyDayAverage.text = priceHistory.fiftyDayAverage ? priceHistory.fiftyDayAverage : "N/A";
            twoHundredDayAverage.text = priceHistory.twoHundredDayAverage ? priceHistory.twoHundredDayAverage : "N/A";
            const dividendData = result.summaryDetail.dividend;
            if (dividendData.rate !== null) {
                const yieldPercentage = dividendData.yield ? ` (${dividendData.yield}%)` : "";
                dividend.text = `${dividendData.rate}${yieldPercentage}`;
            }
            if (dividendData.trailingAnnualRate !== null) {
                const yieldPercentage = dividendData.trailingAnnualYield ? ` (${dividendData.trailingAnnualYield}%)` : "";
                trailingDividend.text = `${dividendData.trailingAnnualRate}${yieldPercentage}`
            }
            exDividendDate.text = dividendData.exDate ? dividendData.exDate : "N/A";

            const summaryProfile = result.summaryProfile;
            if (summaryProfile) {
                address.text = summaryProfile.address;
                if (summaryProfile.website) {
                    website.text = `<a href='${summaryProfile.website}'>${summaryProfile.website}</a>`;
                }
                sector.text = summaryProfile.sector;
                industry.text = summaryProfile.industry;
                description.text = summaryProfile.description;
                profileColumn.visible = true;
            }

            const components = result.components;
            if (components && components.length) {
                componentsText.text = components.join("\n");
                componentsColumn.visible = true;
            }
        }).catch((error) => {
            // TODO
        }).then(() => {
            loading = false;
        });
    }
}
