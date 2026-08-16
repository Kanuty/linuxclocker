import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    compactRepresentation: Component {
        PanelCompactRepresentation {}
    }
    fullRepresentation: Component {
        PanelFullRepresentation {}
    }

    // Config accessors
    readonly property string clocksConfigStr: Plasmoid.configuration.clocksConfig || "[]"
    readonly property bool use24HourFormat: Plasmoid.configuration.use24HourFormat
    readonly property bool showSeconds: Plasmoid.configuration.showSeconds
    readonly property bool showTimezoneName: Plasmoid.configuration.showTimezoneName

    // Reactive currentTime updated every second
    property var currentTime: new Date()

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    // Parsed clock items
    property var activeClocks: []

    onClocksConfigStrChanged: updateClocks()
    Component.onCompleted: updateClocks()

    function updateClocks() {
        try {
            var parsed = JSON.parse(clocksConfigStr);
            if (Array.isArray(parsed) && parsed.length > 0) {
                activeClocks = parsed;
            } else {
                activeClocks = defaultClocks();
            }
        } catch (e) {
            activeClocks = defaultClocks();
        }
    }

    function defaultClocks() {
        return [
            { "name": "Local", "iana": "Local", "enabled": true },
            { "name": "UTC", "iana": "UTC", "enabled": true },
            { "name": "NY", "iana": "America/New_York", "enabled": true },
            { "name": "London", "iana": "Europe/London", "enabled": true },
            { "name": "Tokyo", "iana": "Asia/Tokyo", "enabled": true }
        ];
    }

    function formatClockTime(iana, dateObj) {
        try {
            var options = {
                hour: '2-digit',
                minute: '2-digit',
                hour12: !root.use24HourFormat
            };
            if (root.showSeconds) {
                options.second = '2-digit';
            }
            if (iana && iana !== "Local") {
                options.timeZone = iana;
            }
            var localeTag = (Qt.locale && Qt.locale().name) ? Qt.locale().name.replace('_', '-') : undefined;
            return dateObj.toLocaleTimeString(localeTag, options);
        } catch (e) {
            try {
                return dateObj.toLocaleTimeString(undefined, options);
            } catch (e2) {
                return dateObj.toLocaleTimeString();
            }
        }
    }

    // Inline Compact Representation Component for KDE Plasma Panel
    component PanelCompactRepresentation : RowLayout {
        spacing: 12

        Repeater {
            model: root.activeClocks

            delegate: RowLayout {
                required property var modelData
                visible: modelData.enabled !== false
                spacing: 4

                PlasmaComponents.Label {
                    visible: root.showTimezoneName && modelData.name !== ""
                    text: modelData.name + ":"
                    font.bold: true
                    font.pixelSize: 12
                    opacity: 0.85
                }

                PlasmaComponents.Label {
                    text: root.formatClockTime(modelData.iana, root.currentTime)
                    font.pixelSize: 13
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                root.expanded = !root.expanded;
            }
        }
    }

    // Expanded Popup Representation Component when clicked
    component PanelFullRepresentation : ColumnLayout {
        Layout.preferredWidth: 260
        Layout.preferredHeight: Math.max(150, clockRepeater.count * 45 + 50)
        spacing: 10

        PlasmaComponents.Label {
            text: "Multi Timezone Clocks"
            font.bold: true
            font.pixelSize: 15
            Layout.alignment: Qt.AlignHCenter
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                width: parent.width
                spacing: 8

                Repeater {
                    id: clockRepeater
                    model: root.activeClocks

                    delegate: QQC2.ItemDelegate {
                        required property var modelData
                        visible: modelData.enabled !== false
                        Layout.fillWidth: true

                        contentItem: RowLayout {
                            spacing: 10
                            PlasmaComponents.Label {
                                text: modelData.name
                                font.bold: true
                                Layout.preferredWidth: 90
                                elide: Text.ElideRight
                            }
                            PlasmaComponents.Label {
                                text: root.formatClockTime(modelData.iana, root.currentTime)
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        QQC2.Button {
            text: "Configure Timezones..."
            icon.name: "configure"
            Layout.fillWidth: true
            onClicked: {
                root.expanded = false;
                Plasmoid.action("configure").trigger();
            }
        }
    }
}
