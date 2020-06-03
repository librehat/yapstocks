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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami

ColumnLayout {
    id: rootLayout

    property bool loading: false
    property Item stack
    property string symbol

    RowLayout {
        id: controlsRow
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

        PlasmaComponents.Label {
            Layout.fillWidth: true
            font.weight: Font.Black
            text: symbol
        }

        PlasmaComponents.Button {
            iconSource: "draw-arrow-back"
            text: "Return"
            onClicked: stack.pop()
        }

        ComboBox {
            id: periodCombo
            model: ["1D", "5D", "1M", "6M", "YTD", "1Y", "5Y", "Max"]
            onActivated: {
                loading = true;
                worker.sendMessage({action: "chart", symbol: symbol, period: periodCombo.currentText}); // TODO: i18n
                switch (currentIndex) {
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
        }
    }

    ChartView {
        id: chart
        Layout.fillWidth: true
        Layout.fillHeight: true

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

    ToolTip {
        id: tooltip
        parent: chart
        delay: -1
    }

    PlasmaComponents.BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        visible: loading
        running: loading
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

            const series = chart.createSeries(ChartView.SeriesTypeCandlestick, symbol, xAxis, yAxis);
            series.increasingColor = PlasmaCore.ColorScope.positiveTextColor;
            series.decreasingColor = PlasmaCore.ColorScope.negativeTextColor;
            series.bodyWidth = 1.0;
            series.capsVisible = false;
            series.bodyOutlineVisible = false;
            series.hovered.connect((status, set) => {
                if (status) {
                    tooltip.show( // TODO: number format
`Open: ${set.open.toFixed(2)}
Close: ${set.close.toFixed(2)}
High: ${set.high.toFixed(2)}
Low: ${set.low.toFixed(2)}
Time: ${new Date(set.timestamp).toLocaleString()}`,
                        Kirigami.Units.longDuration,
                    );
                }
            });
            const result = messageObject.data;
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
            });
            xAxis.min = new Date(result.axes.minTime);
            xAxis.max = new Date(result.axes.maxTime);
            yAxis.min = result.axes.minVal * 0.997;
            yAxis.max = result.axes.maxVal * 1.003;
        }

        Component.onCompleted: {
            chart.removeAllSeries();
            if (!symbol || symbol.length === 0) {
                return;
            }
            loading = true;
            worker.sendMessage({action: "chart", symbol: symbol, period: "1D"});
        }
    }
}