import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
    spacing: -1

    MenuSeparator {
        Layout.fillWidth: true
        visible: index != 0
    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: symbol
            font.weight: Font.Black
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
        }

        Label {
            text: currentPrice.toFixed(2)
            Layout.alignment: Qt.AlignRight
        }

        Label {
            text: currency
            Layout.alignment: Qt.AlignRight
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: exchangeName
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
        }

        Text {
            text: `${priceChange.toFixed(2)} (${priceChangePercentage.toFixed(2)}%)`
            color: priceChange == 0 ? PlasmaCore.ColorScope.neutralTextColor : (priceChange > 0 ? PlasmaCore.ColorScope.positiveTextColor : PlasmaCore.ColorScope.negativeTextColor)
            Layout.alignment: Qt.AlignRight
        }
    }
}
