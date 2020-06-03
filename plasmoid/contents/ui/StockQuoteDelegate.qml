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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.4 as Kirigami

ColumnLayout {
    spacing: -1

    signal pricesClicked()
    signal namesClicked()

    MenuSeparator {
        Layout.fillWidth: true
        visible: index != 0
    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: symbol
            font.weight: Font.Black
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft

            MouseArea {
                id: symbolMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }

            ToolTip {
                text: `Long Name: ${longName}
Type: ${instrument}
Exchange: ${exchange}
Market Cap: ${marketCap}`
                visible: symbolMouseArea.containsMouse || nameMouseArea.containsMouse
            }
        }

        Label {
            text: `${currentPrice.toFixed(2)} ${currency}`
            Layout.alignment: Qt.AlignRight

            MouseArea {
                id: currentPriceMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: pricesClicked()
            }

            ToolTip {
                text: `Open: ${openPrice.toFixed(2)}
Previous Close: ${previousClose.toFixed(2)}
High: ${dayHighPrice.toFixed(2)}
Low: ${dayLowPrice.toFixed(2)}
Volume: ${volume}`
                visible: currentPriceMouseArea.containsMouse || priceChangeMouseArea.containsMouse
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft

            text: shortName
            elide: Text.ElideMiddle

            MouseArea {
                id: nameMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        Text {
            Layout.alignment: Qt.AlignRight

            text: `${priceChange.toFixed(2)} (${priceChangePercentage.toFixed(2)}%)`
            color: priceChange == 0 ? PlasmaCore.ColorScope.neutralTextColor : (priceChange > 0 ? PlasmaCore.ColorScope.positiveTextColor : PlasmaCore.ColorScope.negativeTextColor)
            clip: true

            MouseArea {
                id: priceChangeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: pricesClicked()
            }
        }
    }
}
