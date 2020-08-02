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
import org.kde.kirigami 2.4 as Kirigami

Page {
    id: root

    property var symbols: ([])

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Label {
                Layout.fillWidth: true
            }

            ToolButton {
                icon.name: "view-sort-ascending-name"
                onClicked: { sortSymbols(true) }
            }

            ToolButton {
                icon.name: "view-sort-descending-name"
                onClicked: { sortSymbols(false) }
            }
        }
    }

    function sortSymbols(ascending) {
        const items = symbolsVisualModel.items;
        const visuals = [];
        for (let i = 0; i < items.count; ++i) {
            visuals.push(items.get(i));
        }
        visuals.sort((a, b) => {
            if (ascending) {
                return a.model.symbol < b.model.symbol ? -1 : 1;
            } else {
                return a.model.symbol > b.model.symbol ? -1 : 1;
            }
        });
        for (let i = 0; i < visuals.length; ++i) {
            const item = visuals[i];
            item.inVisual = true;
            if (item.visualIndex !== i) {
                visualItems.move(item.visualIndex, i);
            }
        }
        handleSymbolsUpdate();
    }

    function handleSymbolsUpdate() {
        const newSymbols = [];
        const items = symbolsVisualModel.items;
        for (let i = 0; i < items.count; ++i) {
            newSymbols.push(items.get(i).model.symbol);
        }
        symbols = newSymbols;
        console.debug("symbols have been updated to", JSON.stringify(newSymbols));
    }

    DelegateModel {
        id: symbolsVisualModel

        model: ListModel { id: symbolsModel }
        delegate: dragDelegate
        groups: DelegateModelGroup {
            id: visualItems
            name: "visual"
            includeByDefault: true  // there is no filtering here, otherwise this should be false
        }
    }

    Component {
        id: dragDelegate
        MouseArea {
            id: dragArea
            width: parent.width
            height: contentRow.height

            property bool held: false

            hoverEnabled: true

            drag.target: held ? contentRow : undefined
            drag.axis: Drag.YAxis

            onPressAndHold: held = true
            onReleased: held = false

            RowLayout {
                id: contentRow
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Kirigami.Units.smallSpacing
                    rightMargin: Kirigami.Units.smallSpacing
                }

                Drag.active: dragArea.held
                Drag.source: dragArea
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2

                Label {
                    Layout.fillWidth: true
                    text: symbol
                }
                Button {
                    icon.name: "edit-delete"
                    onClicked: {
                        symbolsModel.remove(index);
                        handleSymbolsUpdate();
                    }
                }
            }
            DropArea {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                onEntered: {
                    symbolsVisualModel.items.move(drag.source.DelegateModel.itemsIndex,
                                                  dragArea.DelegateModel.itemsIndex);
                    handleSymbolsUpdate();
                }
            }
            PlasmaComponents.Highlight {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: contentRow.top
                    bottom: contentRow.bottom
                }
                visible: held
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        ListView {
            id: symbolsField
            spacing: Kirigami.Units.smallSpacing
            model: symbolsVisualModel
        }
    }

    onSymbolsChanged: {
        symbolsModel.clear();
        symbols.forEach((symbol) => symbolsModel.append({symbol}));
    }
}
