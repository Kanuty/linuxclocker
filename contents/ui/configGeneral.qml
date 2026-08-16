import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_use24HourFormat: use24HourCheckBox.checked
    property alias cfg_showSeconds: showSecondsCheckBox.checked
    property alias cfg_showTimezoneName: showTimezoneNameCheckBox.checked
    property string cfg_clocksConfig: "[]"

    property bool isInternalSaving: false

    ListModel {
        id: clocksModel
    }

    onCfg_clocksConfigChanged: {
        if (!isInternalSaving) {
            loadClocks();
        }
    }

    Component.onCompleted: {
        loadClocks();
    }

    function loadClocks() {
        clocksModel.clear();
        try {
            var parsed = JSON.parse(cfg_clocksConfig);
            if (Array.isArray(parsed)) {
                for (var i = 0; i < parsed.length; i++) {
                    clocksModel.append({
                        "name": parsed[i].name || "",
                        "iana": parsed[i].iana || "UTC",
                        "enabled": parsed[i].enabled !== undefined ? parsed[i].enabled : true
                    });
                }
            }
        } catch (e) {
            console.error("Error parsing clocksConfig JSON: " + e);
        }
    }

    function saveClocks() {
        isInternalSaving = true;
        var list = [];
        for (var i = 0; i < clocksModel.count; i++) {
            var item = clocksModel.get(i);
            list.push({
                "name": item.name,
                "iana": item.iana,
                "enabled": item.enabled
            });
        }
        cfg_clocksConfig = JSON.stringify(list);
        isInternalSaving = false;
    }

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: use24HourCheckBox
            Kirigami.FormData.label: "Time Format:"
            text: "Use 24-hour clock format"
        }

        QQC2.CheckBox {
            id: showSecondsCheckBox
            text: "Show seconds"
        }

        QQC2.CheckBox {
            id: showTimezoneNameCheckBox
            Kirigami.FormData.label: "Display:"
            text: "Show timezone name near clock"
        }

        Item {
            Kirigami.FormData.isHeader: true
            Kirigami.FormData.label: "Configured Timezone Clocks"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            ListView {
                id: clocksListView
                Layout.fillWidth: true
                implicitHeight: Math.min(300, Math.max(120, clocksModel.count * 45))
                model: clocksModel
                clip: true

                delegate: QQC2.ItemDelegate {
                    width: clocksListView.width
                    contentItem: RowLayout {
                        spacing: 8

                        QQC2.CheckBox {
                            checked: model.enabled
                            onCheckedChanged: {
                                clocksModel.setProperty(index, "enabled", checked);
                                root.saveClocks();
                            }
                        }

                        QQC2.TextField {
                            text: model.name
                            placeholderText: "Clock Name (e.g., NY)"
                            Layout.preferredWidth: 120
                            onEditingFinished: {
                                clocksModel.setProperty(index, "name", text);
                                root.saveClocks();
                            }
                        }

                        QQC2.TextField {
                            text: model.iana
                            placeholderText: "Timezone (e.g. America/New_York, UTC, Local)"
                            Layout.fillWidth: true
                            onEditingFinished: {
                                clocksModel.setProperty(index, "iana", text);
                                root.saveClocks();
                            }
                        }

                        QQC2.Button {
                            icon.name: "go-up"
                            enabled: index > 0
                            onClicked: {
                                clocksModel.move(index, index - 1, 1);
                                root.saveClocks();
                            }
                        }

                        QQC2.Button {
                            icon.name: "go-down"
                            enabled: index < clocksModel.count - 1
                            onClicked: {
                                clocksModel.move(index, index + 1, 1);
                                root.saveClocks();
                            }
                        }

                        QQC2.Button {
                            icon.name: "list-remove"
                            onClicked: {
                                clocksModel.remove(index);
                                root.saveClocks();
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 10
                QQC2.Button {
                    text: "Add Clock"
                    icon.name: "list-add"
                    onClicked: {
                        clocksModel.append({
                            "name": "Clock " + (clocksModel.count + 1),
                            "iana": "UTC",
                            "enabled": true
                        });
                        root.saveClocks();
                    }
                }

                QQC2.ComboBox {
                    id: presetCombo
                    model: [
                        "Quick Preset...",
                        "Local (System Local)",
                        "UTC (Coordinated Universal Time)",
                        "America/New_York (New York / EDT)",
                        "America/Los_Angeles (Los Angeles / PDT)",
                        "Europe/London (London / GMT/BST)",
                        "Europe/Paris (Paris / CET)",
                        "Asia/Tokyo (Tokyo / JST)",
                        "Asia/Kolkata (India / IST)",
                        "Australia/Sydney (Sydney / AEST)"
                    ]
                    onActivated: function(idx) {
                        if (idx <= 0) return;
                        var presets = [
                            {},
                            {"name": "Local", "iana": "Local"},
                            {"name": "UTC", "iana": "UTC"},
                            {"name": "NY", "iana": "America/New_York"},
                            {"name": "LA", "iana": "America/Los_Angeles"},
                            {"name": "London", "iana": "Europe/London"},
                            {"name": "Paris", "iana": "Europe/Paris"},
                            {"name": "Tokyo", "iana": "Asia/Tokyo"},
                            {"name": "India", "iana": "Asia/Kolkata"},
                            {"name": "Sydney", "iana": "Australia/Sydney"}
                        ];
                        var item = presets[idx];
                        clocksModel.append({
                            "name": item.name,
                            "iana": item.iana,
                            "enabled": true
                        });
                        root.saveClocks();
                        presetCombo.currentIndex = 0;
                    }
                }
            }
        }
    }
}
