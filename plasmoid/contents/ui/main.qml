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
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property bool loading: false
    property string lastUpdated

    readonly property var symbols: plasmoid.configuration.symbols
    readonly property int updateInterval: plasmoid.configuration.updateInterval

    Plasmoid.icon: Qt.resolvedUrl("./finance.svg")

    WorkerScript {
        id: worker
        source: "dataloader.mjs"
        onMessage: {
            loading = false;
            lastUpdated = (new Date()).toLocaleString();
            timer.restart();
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

    onSymbolsChanged: {
        if (symbols && symbols.length > 0) {
            loading = true;
            worker.sendMessage({action: "modify", symbols: symbols, model: symbolsModel});
        } else {
            symbolsModel.clear();
        }
    }

    PlasmaComponents.PageStack {
        id: stack
        initialPage: mainView
        anchors.fill: parent
    }

    ScrollView {
        id: mainView
        ListView {
            id: view

            model:  ListModel {
                id: symbolsModel
            }
            delegate: StockQuoteDelegate {
                width: parent.width
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        stack.push(detailsComponent, {symbol: symbol});
                    }
                }
            }

            header: PlasmaExtras.Title {
                text: "Stocks"
            }
            headerPositioning: ListView.OverlayHeader

            footer: RowLayout {
                width: parent.width
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    font.pointSize: 8
                    font.underline: true
                    opacity: 0.7
                    linkColor: PlasmaCore.ColorScope.textColor
                    text: "<a href='https://finance.yahoo.com/'>Powered by Yahoo! Finance</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                PlasmaComponents.Label {
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
        id: detailsComponent
        PriceChart { }
    }

    PlasmaComponents.Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        iconSource: "draw-arrow-back"
        visible: stack.depth > 1
        onClicked: stack.pop()
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }
}
