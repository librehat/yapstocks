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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import "../code/yahoofinance.mjs" as YahooFinance

ColumnLayout {
    id: root

    property var cfg_symbols: plasmoid.configuration.symbols

    spacing: Kirigami.Units.smallSpacing

    Kirigami.InlineMessage {
        id: errorMessage
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        type: Kirigami.MessageType.Error
        showCloseButton: true
    }

    Label {
        Layout.fillWidth: true

        text: "The data is currently sourced from Yahoo Finance. Symbols must be valid Yahoo Finance symbols which you can find on the <a href='https://finance.yahoo.com/'>Yahoo Finance</a> website"
        wrapMode: Text.WordWrap
        onLinkActivated: Qt.openUrlExternally(link)
    }

    RowLayout {
        id: inputRow
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        TextField {
            id: symbolTextField
            Layout.fillWidth: true

            placeholderText: "Type Yahoo Finance symbol here"
        }
        Button {
            icon.name: "list-add"
            enabled: symbolTextField.text.trim().length > 0
            onClicked: {
                inputRow.enabled = false;
                const symbol = symbolTextField.text.trim();
                validateSymbol(symbol).then((valid) => {
                    if (valid) {
                        symbolsModel.append({symbol});
                        handleSymbolsUpdate();
                        symbolTextField.text = "";
                    }
                    inputRow.enabled = true;
                });
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
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

    function validateSymbol(symbol) {
        return YahooFinance.resolveQuote(symbol).then(() => {
            for (let i = 0; i < symbolsModel.count; ++i) {
                if (symbol === symbolsModel.get(i).symbol) {
                    // This is a work around for Qt 5.12.x as the promise chain is buggy
                    // Do a proper `throw new Error()` in next OpenSUSE Leap version
                    return Promise.reject(`Duplicate: ${symbol} already exists`);
                }
            }
            return true;
        }).catch((error) => {
            errorMessage.text = error;
            errorMessage.visible = true;
            return false;
        });
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
        const symbols = [];
        const items = symbolsVisualModel.items;
        for (let i = 0; i < items.count; ++i) {
            symbols.push(items.get(i).model.symbol);
        }
        cfg_symbols = symbols;
        console.debug("symbols have been updated to", JSON.stringify(symbols));
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
        Layout.fillWidth: true
        Layout.fillHeight: true
        ListView {
            id: symbolsField
            spacing: Kirigami.Units.smallSpacing
            model: symbolsVisualModel

            Component.onCompleted: {
                cfg_symbols.forEach((symbol) => symbolsModel.append({symbol}));
            }
        }
    }
}
