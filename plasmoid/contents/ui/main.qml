import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property bool loading: false
    property string lastUpdated

    readonly property var symbols: plasmoid.configuration.symbols
    readonly property int updateInterval: plasmoid.configuration.updateInterval

    Plasmoid.icon: Qt.resolvedUrl("./finance.svg")

    WorkerScript {
        id: worker
        source: "dataloader.mjs"
        onMessage: {
            loading = false;
            lastUpdated = (new Date()).toLocaleString();
            timer.restart();
        }
    }

    Timer {
        id: timer
        interval: updateInterval
        running: true
        repeat: true
        onTriggered: {
            if (symbolsModel.count > 0) {
                loading = true;
                worker.sendMessage({action: "refresh", model: symbolsModel});
            }
        }
    }

    onSymbolsChanged: {
        loading = true;
        worker.sendMessage({action: "modify", symbols: symbols, model: symbolsModel});
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            id: view
            spacing: PlasmaCore.Units.smallSpacing

            model:  ListModel {
                id: symbolsModel
            }
            delegate: StockQuoteDelegate {
                width: parent.width
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        view.currentIndex = index; // TODO: highlight item
                        // TODO: overlay showing details
                    }
                }
            }

            header: PlasmaExtras.Title {
                text: "Stocks"
            }
            headerPositioning: ListView.OverlayHeader

            footer: RowLayout {
                width: parent.width
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    font.pointSize: 8
                    font.underline: true
                    opacity: 0.7
                    linkColor: PlasmaCore.ColorScope.textColor
                    text: "<a href='https://finance.yahoo.com/'>Powered by Yahoo! Finance</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignRight
                    font.pointSize: 8
                    visible: !!lastUpdated
                    text: "Last Updated: " + lastUpdated
                }
            }
            footerPositioning: ListView.OverlayFooter
        }
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        visible: loading
        running: loading
    }
}
