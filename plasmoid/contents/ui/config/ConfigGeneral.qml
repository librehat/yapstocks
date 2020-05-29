import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0


ColumnLayout {
    id: root

    property var cfg_symbols: plasmoid.configuration.symbols
    property int cfg_interval: plasmoid.configuration.updateInterval


    RowLayout {
        Layout.fillWidth: true

        Label {
            text: i18n("Symbols:")
        }

        TextField {
            // TODO: Make this nicer by using a ListView
            Layout.fillWidth: true
            id: symbolsField
            text: cfg_symbols.join(",")
            placeholderText: "Yahoo! Finance symbols separated by comma ','"
            onTextEdited: {
                const symbols = text.split(",").map(sym => sym.trim());
                cfg_symbols = [...new Set(symbols)]; // Remove duplicates
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            text: i18n("Update every:")
        }

        SpinBox {
            id: updateIntervalSpin
            from: 30
            to: 3600
            editable: true
            textFromValue: (value) => i18np("%1 minute", "%1 minutes", value)
            valueFromText: (text) => parseInt(text, 10)

            value: cfg_interval / 60000

            onValueChanged: (value) => {
                cfg_interval = value * 60000;
            }
        }
    }
}
