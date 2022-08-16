/**
 *  This file is part of YapStocks.
 *
 *  Copyright 2022 Simeon Huang (@librehat)
 *
 *  YapStocks is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
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
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmaComponents.Page {
    id: root

    property bool loading: false
    property Item stack

    readonly property string title: "Stocks"
    readonly property var locale: Qt.locale()

    readonly property var symbols: plasmoid.configuration.symbols
    readonly property int updateInterval: plasmoid.configuration.updateInterval

    PlasmaComponents3.ScrollView {
        anchors.fill: parent
        ListView {
            id: view

            model:  ListModel {
                id: symbolsModel
            }
            delegate: StockQuoteDelegate {
                width: parent.width
                onPricesClicked: {
                    stack.push(chartComponent, {symbol, stack});
                }
                onNamesClicked: {
                    stack.push(profileComponent, {symbol, stack});
                }
            }
        }
    }

    PlasmaComponents3.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }

    function refresh() {
        if (symbols && symbols.length > 0) {
            loading = true;
            worker.sendMessage({action: "modify", symbols: symbols, model: symbolsModel});
        } else {
            symbolsModel.clear();
        }
    }

    WorkerScript {
        id: worker
        source: "../code/dataloader.mjs"
        onMessage: {
            loading = false;
            timer.restart();
        }

        Component.onCompleted: {
            // refresh on start up for the initial load
            root.refresh();
            // connecting signals here to avoid sending messages to the worker before it's ready
            root.symbolsChanged.connect(root.refresh);
        }
    }

    Timer {
        id: timer
        interval: updateInterval
        running: true
        repeat: true
        onTriggered: {
            if (symbolsModel.count > 0) {
                loading = true;
                worker.sendMessage({action: "refresh", model: symbolsModel});
            }
        }
    }

    Component {
        id: profileComponent
        ProfilePage {}
    }

    Component {
        id: chartComponent
        PriceChart {}
    }
}
