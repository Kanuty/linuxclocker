import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    compactRepresentation: Item {
        id: compactRoot
        Layout.fillWidth: false
        Layout.fillHeight: true
        implicitWidth: clocksRow.implicitWidth
        implicitHeight: clocksRow.implicitHeight

        RowLayout {
            id: clocksRow
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: root.activeClocks

                delegate: RowLayout {
                    required property var modelData
                    visible: modelData.enabled !== false
                    spacing: 3

                    PlasmaComponents.Label {
                        visible: root.showTimezoneName && modelData.name !== ""
                        text: modelData.name + ":"
                        font.bold: true
                        font.pointSize: 9
                        opacity: 0.9
                    }

                    PlasmaComponents.Label {
                        text: root.formatClockTime(modelData.iana, root.currentTime)
                        font.pointSize: 9
                    }
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

    fullRepresentation: Item {
        id: fullRoot
        implicitWidth: 280
        implicitHeight: Math.max(180, clockRepeater.count * 40 + 60)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            PlasmaComponents.Label {
                text: "Multi Timezone Clocks"
                font.bold: true
                font.pointSize: 11
                Layout.alignment: Qt.AlignHCenter
            }

            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: 6

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
                                    Layout.preferredWidth: 100
                                    elide: Text.ElideRight
                                }
                                PlasmaComponents.Label {
                                    text: root.formatClockTime(modelData.iana, root.currentTime)
                                    font.pointSize: 11
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
            { "name": "Warsaw", "iana": "Europe/Warsaw", "enabled": true },
            { "name": "UTC", "iana": "UTC", "enabled": true },
            { "name": "NY", "iana": "America/New_York", "enabled": true },
            { "name": "Tokyo", "iana": "Asia/Tokyo", "enabled": true }
        ];
    }

    function formatClockTime(iana, dateObj) {
        var tz = iana;
        if (!tz || tz === "Local" || tz === "LOCAL") {
            try {
                tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
            } catch (e) {
                tz = "UTC";
            }
        }

        // Handle custom offset strings like UTC+2, +02:00, -05:00, etc.
        if (/^(UTC|GMT)?[+-]\d{1,2}(:\d{2})?$/i.test(tz)) {
            var match = tz.match(/([+-])(\d{1,2})(?::(\d{2}))?/);
            if (match) {
                var sign = match[1] === "+" ? 1 : -1;
                var hrs = parseInt(match[2], 10);
                var mins = match[3] ? parseInt(match[3], 10) : 0;
                var offsetMin = sign * (hrs * 60 + mins);

                var utcMs = dateObj.getTime() + (dateObj.getTimezoneOffset() * 60000);
                var targetMs = utcMs + (offsetMin * 60000);
                var targetDate = new Date(targetMs);

                var hours = targetDate.getHours();
                var minutes = targetDate.getMinutes();
                var seconds = targetDate.getSeconds();

                if (!root.use24HourFormat) {
                    var ampm = hours >= 12 ? "PM" : "AM";
                    hours = hours % 12;
                    if (hours === 0) hours = 12;
                    var hStr = hours < 10 ? "0" + hours : "" + hours;
                    var mStr = minutes < 10 ? "0" + minutes : "" + minutes;
                    var sStr = seconds < 10 ? "0" + seconds : "" + seconds;
                    return hStr + ":" + mStr + (root.showSeconds ? ":" + sStr : "") + " " + ampm;
                } else {
                    var hStr = hours < 10 ? "0" + hours : "" + hours;
                    var mStr = minutes < 10 ? "0" + minutes : "" + minutes;
                    var sStr = seconds < 10 ? "0" + seconds : "" + seconds;
                    return hStr + ":" + mStr + (root.showSeconds ? ":" + sStr : "");
                }
            }
        }

        // Standard IANA timezone formatting via Intl.DateTimeFormat
        try {
            var options = {
                hour: '2-digit',
                minute: '2-digit',
                hour12: !root.use24HourFormat,
                timeZone: tz
            };
            if (root.showSeconds) {
                options.second = '2-digit';
            }
            var localeTag = (Qt.locale && Qt.locale().name) ? Qt.locale().name.replace('_', '-') : undefined;
            var dtf = new Intl.DateTimeFormat(localeTag, options);
            return dtf.format(dateObj);
        } catch (e) {
            try {
                var dtfFallback = new Intl.DateTimeFormat('en-US', options);
                return dtfFallback.format(dateObj);
            } catch (e2) {
                return dateObj.toLocaleTimeString();
            }
        }
    }
}
