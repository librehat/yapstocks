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

import QtQml 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtCharts 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Page {
    id: root

    property bool loading: false
    property alias symbol: root.title
    property int priceDecimals: 2
    property var chartData: ({})

    header: PlasmaComponents.ToolBar {
        RowLayout {
            width: parent.width
            PlasmaComponents.ComboBox {
                id: periodCombo
                model: ["1D", "5D", "1M", "6M", "YTD", "1Y", "5Y", "Max"]
                onActivated: {
                    loading = true;
                    worker.sendMessage({action: "chart", symbol: symbol, period: periodCombo.currentText}); // TODO: i18n
                    updateAxes();
                }
            }
            PlasmaComponents.Label {  // used as an expander
                Layout.fillWidth: true
            }
            PlasmaComponents.ToolButton {
                id: candlesticksChartBtn
                autoExclusive: true
                checkable: true
                checked: true
                icon.name: "office-chart-scatter"  // TODO: a better icon for candlesticks
                onToggled: updateChartView()
            }
            PlasmaComponents.ToolButton {
                id: lineChartBtn
                autoExclusive: true
                checkable: true
                icon.name: "office-chart-line"
                onToggled: updateChartView()
            }
        }
    }

    function updateAxes() {
        switch (periodCombo.currentIndex) {
        case 0:
            xAxis.format = "hh:mm";
            break;
        case 1:
            xAxis.format = "ddd";
            break;
        case 2:
        case 3:
            xAxis.format = "d MMM";
            break;
        case 4:
        case 5:
        case 6:
        case 7:
            xAxis.format = "MMM, yy";
            break;
        }
    }

    ChartView {
        id: chart
        anchors.fill: parent

        localizeNumbers: true
        legend.visible: false
        theme: ChartView.ChartThemeDark
        backgroundColor: PlasmaCore.ColorScope.backgroundColor
        animationOptions: ChartView.SeriesAnimations
        antialiasing: true

        axes: [
            DateTimeAxis {
                id: xAxis
                format: "hh:mm"
                min: new Date(2020, 1, 1)
                max: new Date()
                tickCount: 6
                color: theme.viewTextColor
                gridLineColor: theme.viewTextColor
                labelsColor: theme.viewTextColor
                gridVisible: false
            },
            ValueAxis {
                id: yAxis
                tickCount: 8
                color: theme.viewTextColor
                gridLineColor: theme.viewTextColor
                labelsColor: theme.viewTextColor
            }
        ]
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }

    PlasmaComponents.ToolTip {
        id: tooltip
        parent: chart
        delay: -1
    }

    WorkerScript {
        id: worker
        source: "../code/dataloader.mjs"
        onMessage: {
            loading = false;

            if (messageObject.error) {
                // TODO: handle error
                return;
            }

            chartData = messageObject.data;
            updateChartView();
        }

        Component.onCompleted: {
            chart.removeAllSeries();
            if (!symbol || symbol.length === 0) {
                return;
            }
            loading = true;
            worker.sendMessage({
                action: "chart",
                symbol: symbol,
                period: plasmoid.configuration.defaultPeriod,
            });
            periodCombo.currentIndex = periodCombo.find(plasmoid.configuration.defaultPeriod);
            updateAxes();
        }
    }

    function localisePrice(num) {
        if (typeof num === "string") {
            return "N/A";
        }
        return Number(num).toLocaleString(locale, "f", priceDecimals);
    }

    function updateChartView() {
        chart.removeAllSeries();

        // right now we only have two different kinds of charts
        const isCandleSticks = candlesticksChartBtn.checked;

        const series = chart.createSeries(
            isCandleSticks ? ChartView.SeriesTypeCandlestick : ChartView.SeriesTypeLine,
            symbol,
            xAxis,
            yAxis
        );
        if (isCandleSticks) {
            series.increasingColor = theme.positiveTextColor;
            series.decreasingColor = theme.negativeTextColor;
            series.bodyWidth = 1.0;
            series.capsVisible = false;
            series.bodyOutlineVisible = false;
            series.hovered.connect((status, set) => {
                if (status) {
                    tooltip.show(
`Open: ${localisePrice(set.open)}
Close: ${localisePrice(set.close)}
High: ${localisePrice(set.high)}
Low: ${localisePrice(set.low)}
Time: ${new Date(set.timestamp).toLocaleString()}`
                    );
                } else {
                    tooltip.hide();
                }
            });
        } else {
            series.color = theme.highlightColor;
            series.hovered.connect((point, state) => {
                if (state) {
                    tooltip.show(`Close: ${localisePrice(point.y)}
Time: ${new Date(point.x).toLocaleString()}`);
                } else {
                    tooltip.hide();
                }
            });
        }
        priceDecimals = chartData.priceDecimals;

        const appendCandlesticks = (data) => {
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
        };
        const appendLinePoint = (data) => {
            series.append(data.timestamp, data.close);
        };

        if (isCandleSticks) {
            chartData.timeseries.forEach(appendCandlesticks);
        } else {
            chartData.timeseries.forEach(appendLinePoint);
        }
        xAxis.min = new Date(chartData.axes.minTime);
        xAxis.max = new Date(chartData.axes.maxTime);
        yAxis.min = chartData.axes.minVal * 0.997;
        yAxis.max = chartData.axes.maxVal * 1.003;
    }
}
