import QtQuick 2.12

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Symbols")
        icon: "format-text-symbol"
        source: "config/ConfigSymbols.qml"
    }
    ConfigCategory {
        name: i18n("Miscellaneous")
        icon: "configure"
        source: "config/ConfigMisc.qml"
    }
}
