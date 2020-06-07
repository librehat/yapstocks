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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.4 as Kirigami


PlasmaComponents.ListItem {
    signal pricesClicked()
    signal namesClicked()

    height: contentRow.implicitHeight + separator.implicitHeight + 2 * units.smallSpacing

    Rectangle {
        id: separator
        visible: index !== 0
        width: parent.width
        height: 2
        anchors.top: parent.top
        border.width: 0
        color: theme.viewBackgroundColor
    }

    RowLayout {
        id: contentRow
        anchors {
            top: separator.bottom
            topMargin: units.smallSpacing
            bottom: parent.bottom
            bottomMargin: units.smallSpacing
            left: parent.left
            right: parent.right
        }

        ColumnLayout {
            id: infoColumn
            Layout.fillWidth: true
            spacing: -1

            PlasmaComponents3.Label {
                text: symbol
                font.weight: Font.Black
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                text: longName
                elide: Text.ElideMiddle
            }
        }

        ColumnLayout {
            id: priceColumn
            Layout.alignment: Qt.AlignRight
            spacing: -1

            PlasmaComponents3.Label {
                text: `${currentPrice} ${currency}`
                Layout.alignment: Qt.AlignRight
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight

                text: `${priceChange > 0 ? "+" + priceChange : priceChange} (${priceChangePercentage > 0 ? "+" + priceChangePercentage : priceChangePercentage}%)`
                color: priceChange == 0 ? theme.neutralTextColor : (priceChange > 0 ? theme.positiveTextColor : theme.negativeTextColor)
                clip: true
            }
        }

        PlasmaComponents3.ToolButton {
            icon.name: "documentinfo"
            visible: tooltip.containsMouse
            flat: false
            onClicked: namesClicked()
        }

        PlasmaComponents3.ToolButton {
            icon.name: "office-chart-line"
            visible: tooltip.containsMouse
            flat: false
            onClicked: pricesClicked()
        }
    }

    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        mainText: `${shortName} (${symbol})`
        // TODO: move this logic into `code`
        subText: `Long Name: ${longName}
Type: ${instrument}
Exchange: ${exchange}
Market Cap: ${marketCap}
Open: ${openPrice}
Previous Close: ${previousClose}
High: ${dayHighPrice}
Low: ${dayLowPrice}
Volume: ${volume}`
    }
}
