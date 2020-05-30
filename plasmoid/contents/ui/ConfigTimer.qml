import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    property int cfg_interval: plasmoid.configuration.updateInterval

    RowLayout {
        Label {
            text: i18n("Update every:")
        }

        SpinBox {
            id: updateIntervalSpin
            from: 5
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
