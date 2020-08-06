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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import "../code/yahoofinance.mjs" as YahooFinance

Item {
    property var symbols: ([])

    implicitHeight: view.contentHeight

    ListModel { id: componentsModel }

    ListView {
        id: view
        anchors.fill: parent

        interactive: false

        model: componentsModel

        delegate: PlasmaComponents.ListItem {
            width: parent.width
            ColumnLayout {
                spacing: 0
                PlasmaComponents3.Label {
                    text: symbol
                    font.bold: true
                }
                PlasmaComponents3.Label {
                    text: `${longName} (${exchange}) (${instrument})`
                    font.weight: Font.Thin
                    font.pointSize: theme.smallestFont.pointSize
                }
            }
        }
    }

    onSymbolsChanged: {
        YahooFinance.resolveMultipleQuotes(symbols).then((results) => {
            componentsModel.clear();
            results.forEach((result) => {
                componentsModel.append(result)
            });
        }).catch((e) => {
            // TODO: handle the error
        });
    }
}
