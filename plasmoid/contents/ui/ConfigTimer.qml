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
