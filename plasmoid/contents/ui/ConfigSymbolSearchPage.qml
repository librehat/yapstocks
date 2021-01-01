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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.12 as Kirigami
import "../code/yahoofinance.mjs" as YahooFinance

Page {
    id: root

    property string keyword: ""
    property bool busy: true
    property var stack: ({})
    property var symbols: ([])

    signal symbolSelected(string symbol)

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Label {
                Layout.fillWidth: true
            }

            ToolButton {
                icon.name: "draw-arrow-back"
                onClicked: { stack.pop(); }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Kirigami.InlineMessage {
            id: errorMessage
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            type: Kirigami.MessageType.Error
            showCloseButton: true
        }

        ScrollView {
            id: searchQuotesView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !busy

            ListView {
                spacing: Kirigami.Units.smallSpacing
                model: ListModel { id: searchQuotesModel }
                delegate: Kirigami.BasicListItem {
                    label: symbol
                    subtitle: `${longName} (${exchange}) (${instrument})`

                    onClicked: {
                        if (symbols.indexOf(symbol) !== -1) {
                            errorMessage.text = `${symbol} has been added already`;
                            errorMessage.visible = true;
                            return;
                        }
                        console.debug(`${symbol} was clicked`);
                        root.symbolSelected(symbol);
                        stack.pop();
                    }
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: busy
        running: busy
    }

    onKeywordChanged: {
        YahooFinance.searchQuotes(keyword).then((quotes) => {
            searchQuotesModel.clear();
            quotes.forEach((quote) => {
                searchQuotesModel.append(quote);
            });
        }).catch((error) => {
            errorMessage.text = error;
            errorMessage.visible = true;
        }).then(() => {
            root.busy = false;
        });
    }
}
