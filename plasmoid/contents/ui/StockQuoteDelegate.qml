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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.4 as Kirigami


PlasmaComponents.ListItem {
    signal pricesClicked()
    signal namesClicked()

    height: contentRow.implicitHeight + 2 * units.smallSpacing

    readonly property var locale: Qt.locale()

    function localiseNumber(num, isPrice, isChange) {
        if (typeof num === "string") {
            return num;
        }
        let result = Number(num).toLocaleString(locale, "f", isPrice ? priceDecimals : 0);
        if (!isChange || num === 0) {
            return result;
        }
        return (num > 0 ? locale.positiveSign + result : result);
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent

        ColumnLayout {
            id: infoColumn
            Layout.fillWidth: true
            spacing: -1

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                text: symbol
                font.weight: Font.Black
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                text: longName
                // Sometimes it has HTML encoded characters
                // StyledText will render them nicely (and more performant than RichText)
                textFormat: Text.StyledText
                elide: Text.ElideMiddle
            }
        }

        ColumnLayout {
            id: priceColumn
            Layout.alignment: Qt.AlignRight
            spacing: -1

            PlasmaComponents3.Label {
                text: `${localiseNumber(currentPrice, true)} ${currency}`
                Layout.alignment: Qt.AlignRight
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight

                text: `${localiseNumber(priceChange, true, true)} (${priceChangePercentage > 0 ? locale.positiveSign : ""}${Number(priceChangePercentage * 100).toLocaleString(locale, 'f', 2)}${locale.percent})`
                color: priceChange === 0 ? theme.neutralTextColor : (priceChange > 0 ? theme.positiveTextColor : theme.negativeTextColor)
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
        subText: `Long Name: ${longName}
Type: ${instrument}
Exchange: ${exchange}
Market Cap: ${localiseNumber(marketCap, false)}
Open: ${localiseNumber(openPrice, true)}
Previous Close: ${localiseNumber(previousClose, true)}
High: ${localiseNumber(dayHighPrice, true)}
Low: ${localiseNumber(dayLowPrice, true)}
Volume: ${localiseNumber(volume, false)}`
    }
}
