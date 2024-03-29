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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    Plasmoid.icon: Qt.resolvedUrl("./finance.svg")

    RowLayout {
        id: headerRow
        width: parent.width
        height: title.implicitHeight
        PlasmaExtras.Title {
            id: title
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            text: stack.currentPage.title
        }
        PlasmaComponents3.ToolButton {
            visible: stack.depth === 1
            icon.name: "view-refresh"
            onClicked: {
                mainPage.refresh();
            }

            PlasmaComponents3.ToolTip {
                text: "Refresh the data"
            }
        }
        PlasmaComponents3.ToolButton {
            visible: stack.depth > 1
            icon.name: "draw-arrow-back"
            onClicked: stack.pop()

            PlasmaComponents3.ToolTip {
                text: "Return to previous page"
            }
        }
    }
    PlasmaComponents.PageStack {
        id: stack
        anchors {
            top: headerRow.bottom
            left: parent.left
            right: parent.right
            bottom: footer.top
            topMargin: units.smallSpacing
            bottomMargin: units.smallSpacing
        }
    }

    PlasmaComponents3.Label {
        id: footer
        anchors.bottom: parent.bottom
        width: parent.width

        font.pointSize: theme.smallestFont.pointSize
        font.weight: Font.Thin
        font.underline: true
        opacity: 0.7
        linkColor: theme.textColor
        elide: Text.ElideLeft
        horizontalAlignment: Text.AlignRight
        text: "<a href='https://finance.yahoo.com/'>Powered by Yahoo! Finance</a>"
        onLinkActivated: Qt.openUrlExternally(link)
    }

    MainPage {
        id: mainPage
        stack: stack
    }

    Component.onCompleted: {
        stack.push(mainPage);
    }
}
