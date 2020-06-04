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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami


ColumnLayout { // TODO: Use GridLayout
    signal pricesClicked()
    signal namesClicked()

    MenuSeparator {
        Layout.fillWidth: true
        visible: index !== 0
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: -1

            PlasmaComponents.Label {
                text: symbol
                font.weight: Font.Black
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                text: shortName
                elide: Text.ElideMiddle
            }

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: symbol
                subText: `Long Name: ${longName}
Type: ${instrument}
Exchange: ${exchange}
Market Cap: ${marketCap}`
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignRight
            spacing: -1

            PlasmaComponents.Label {
                text: `${currentPrice.toFixed(2)} ${currency}`
                Layout.alignment: Qt.AlignRight
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignRight

                text: `${priceChange.toFixed(2)} (${priceChangePercentage.toFixed(2)}%)`
                color: priceChange == 0 ? PlasmaCore.ColorScope.neutralTextColor : (priceChange > 0 ? PlasmaCore.ColorScope.positiveTextColor : PlasmaCore.ColorScope.negativeTextColor)
                clip: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: pricesClicked()
            }

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: symbol
                subText: `Open: ${openPrice.toFixed(2)}
Previous Close: ${previousClose.toFixed(2)}
High: ${dayHighPrice.toFixed(2)}
Low: ${dayLowPrice.toFixed(2)}
Volume: ${volume}`
            }
        }
    }
}
