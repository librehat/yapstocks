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
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.4 as Kirigami

ColumnLayout {
    id: root

    property var cfg_symbols: plasmoid.configuration.symbols

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        id: inputRow
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        TextField {
            id: symbolTextField
            Layout.fillWidth: true

            placeholderText: "Search Yahoo Finance for symbols to add"
        }
        Button {
            icon.name: "search"
            enabled: symbolTextField.text.trim().length > 0
            onClicked: {
                if (stack.depth == 1) {
                    stack.push(
                        searchPage,
                        { keyword: symbolTextField.text.trim(), stack: stack, symbols: cfg_symbols }
                    );
                    stack.currentItem.symbolSelected.connect((symbol) => {
                        console.log("symbol added", symbol);
                        root.cfg_symbols.push(symbol);
                        viewPage.symbols = root.cfg_symbols;
                    });
                } else { // only have one search page in the stack
                    stack.currentItem.keyword = symbolTextField.text.trim();
                }
            }
        }
    }

    Component {
        id: searchPage
        ConfigSymbolSearchPage {}
    }

    StackView {
        id: stack
        Layout.fillWidth: true
        Layout.fillHeight: true

        initialItem: ConfigSymbolViewPage {
            id: viewPage
            symbols: cfg_symbols
            onSymbolsChanged: {
                root.cfg_symbols = symbols;
            }
        }
    }
}
