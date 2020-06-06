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

    function handleSymbolsUpdate() {
        const symbols = [];
        for (let i = 0; i < symbolsModel.count; ++i) {
            symbols.push(symbolsModel.get(i).symbol);
        }
        cfg_symbols = symbols;
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        ListView {
            // TODO: support drag & drop to re-arrange the order
            id: symbolsField
            spacing: Kirigami.Units.smallSpacing
            model: ListModel {
                id: symbolsModel
            }
            delegate: RowLayout {
                width: parent.width
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

            Component.onCompleted: {
                cfg_symbols.forEach((symbol) => symbolsModel.append({symbol}));
            }
        }
    }
}
