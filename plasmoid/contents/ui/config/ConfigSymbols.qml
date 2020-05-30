import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami


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
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.TextField {
            id: symbolTextField
            Layout.fillWidth: true

            placeholderText: "Type Yahoo Finance symbol here"
        }
        PlasmaComponents.Button {
            iconSource: "list-add"
            onClicked: {
                const symbol = symbolTextField.text.trim();
                if (!validateSymbol(symbol)) {
                    return;
                }
                symbolsModel.append({symbol});
                handleSymbolsUpdate();
                symbolTextField.text = "";
            }
        }
    }

    function validateSymbol(symbol) {
        for (let i = 0; i < symbolsModel.count; ++i) {
            if (symbol === symbolsModel.get(i).symbol) {
                errorMessage.text = `Duplicate: ${symbol} already exists`
                errorMessage.visible = true;
                return false;
            }
        }
        // TODO: validate it with Yahoo Finance
        return true;
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
                PlasmaComponents.Button {
                    iconSource: "edit-delete"
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
