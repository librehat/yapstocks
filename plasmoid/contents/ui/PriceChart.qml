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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtCharts 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import "yahoofinance.mjs" as YahooFinance

ColumnLayout {
    id: rootLayout

    property string symbol

    ButtonGroup { buttons: controlsRow.children }

    RowLayout {
        id: controlsRow
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Label {
            text: "Period"
        }

        RadioButton {
            checked: true
            text: "1D"
        }
        /* TODO
        RadioButton {
            text: "5D"
        }
        RadioButton {
            text: "1M"
        }
        RadioButton {
            text: "3M"
        }
        RadioButton {
            text: "6M"
        }
        RadioButton {
            text: "1Y"
        }
        RadioButton {
            text: "2Y"
        }
        RadioButton {
            text: "5Y"
        }
        RadioButton {
            text: "YTD"
        }
        RadioButton {
            text: "Max"
        }
        */
    }

    ChartView {
        id: chart
        Layout.fillWidth: true
        Layout.fillHeight: true

        localizeNumbers: true
        legend.visible: false
        theme: ChartView.ChartThemeQt
        backgroundColor: PlasmaCore.ColorScope.backgroundColor

        axes: [
            DateTimeAxis {
                id: xAxis
                format: "hh:mm" // TODO: this should be changed depends on the period
                // min and max are needed here somehow otherwise the ticks don't show up
                // even though they get overwritten by the code below
                min: new Date(2020, 1, 1)
                max: new Date()
                tickCount: 6
                color: PlasmaCore.ColorScope.textColor
                gridLineColor: PlasmaCore.ColorScope.textColor
                labelsColor: PlasmaCore.ColorScope.textColor
                gridVisible: false
            },
            ValueAxis {
                id: yAxis
                tickCount: 8
                color: PlasmaCore.ColorScope.textColor
                gridLineColor: PlasmaCore.ColorScope.textColor
                labelsColor: PlasmaCore.ColorScope.textColor
            }
        ]
    }

    onSymbolChanged: {
        console.debug("PriceChart symbol changed", symbol);
        chart.removeAllSeries();
        if (!symbol || symbol.length === 0) {
            return;
        }
        const series = chart.createSeries(ChartView.SeriesTypeCandlestick, symbol, xAxis, yAxis);
        series.increasingColor = PlasmaCore.ColorScope.positiveTextColor;
        series.decreasingColor = PlasmaCore.ColorScope.negativeTextColor;
        YahooFinance.resolveChart(symbol).then((result) => {
            let minVal = result.currentPrice, maxVal = result.currentPrice;
            let minTime = result.updatedDateTime, maxTime = result.updatedDateTime;
            result.timeseries.forEach((data) => {
                if (data.open === null || data.close === null || data.high === null || data.low === null) {
                    // Skip null data points
                    return;
                }
                series.append(Qt.createQmlObject(`
                import QtQuick 2.12
                import QtCharts 2.2
                CandlestickSet {
                    timestamp: ${data.timestamp}
                    open: ${data.open}
                    close: ${data.close}
                    high: ${data.high}
                    low: ${data.low}
                }`, series, "dynamicCandleSet"));
                minVal = Math.min(minVal, data.low);
                maxVal = Math.max(maxVal, data.high);
                minTime = Math.min(minTime, data.timestamp);
                maxTime = Math.max(maxTime, data.timestamp);
            });
            xAxis.min = new Date(minTime);
            xAxis.max = new Date(maxTime);
            yAxis.min = minVal * 0.999; // "margins"
            yAxis.max = maxVal * 1.001;
        }).catch((error) => {
            // TODO: show the error message
        });
    }
}
