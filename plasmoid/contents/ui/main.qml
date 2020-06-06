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
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    property bool loading: false
    property string lastUpdated

    readonly property var symbols: plasmoid.configuration.symbols
    readonly property int updateInterval: plasmoid.configuration.updateInterval

    Plasmoid.icon: Qt.resolvedUrl("./finance.svg")

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
            lastUpdated = (new Date()).toLocaleString();
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

    PlasmaComponents.PageStack {
        id: stack
        initialPage: mainView
        anchors.fill: parent
    }

    PlasmaComponents3.ScrollView {
        id: mainView
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

            header: PlasmaExtras.Title {
                text: "Stocks"
            }
            headerPositioning: ListView.OverlayHeader

            footer: RowLayout {
                width: parent.width
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    font.pointSize: 8
                    font.underline: true
                    opacity: 0.7
                    linkColor: theme.textColor
                    text: "<a href='https://finance.yahoo.com/'>Powered by Yahoo! Finance</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignRight
                    font.pointSize: 8
                    visible: !!lastUpdated
                    text: "Last Updated: " + lastUpdated
                }
            }
            footerPositioning: ListView.OverlayFooter
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

    PlasmaComponents3.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }
}
