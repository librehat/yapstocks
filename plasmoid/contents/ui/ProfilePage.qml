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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property bool loading: false
    property Item stack
    property string symbol

    RowLayout {
        id: controlsRow
        width: parent.width
        anchors.top: parent.top

        PlasmaExtras.Title {
            Layout.fillWidth: true
            text: symbol
            elide: Text.ElideRight
        }

        PlasmaComponents.Button {
            icon.name: "draw-arrow-back"
            text: "Return"
            onClicked: stack.pop()
        }
    }

    PlasmaComponents.BusyIndicator {
        anchors.right: chart.right
        anchors.top: chart.top
        visible: loading
        running: loading
    }
}
