import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_use24HourFormat: use24HourCheckBox.checked
    property alias cfg_showSeconds: showSecondsCheckBox.checked
    property alias cfg_showTimezoneName: showTimezoneNameCheckBox.checked
    property string cfg_clocksConfig: "[]"

    property bool isInternalSaving: false

    readonly property var availableTimezones: [
        { "label": "Local (System Local Time)", "iana": "Local" },
        { "label": "UTC (Coordinated Universal Time)", "iana": "UTC" },
        { "label": "Europe / Warsaw", "iana": "Europe/Warsaw" },
        { "label": "Europe / London (BST/GMT)", "iana": "Europe/London" },
        { "label": "Europe / Paris", "iana": "Europe/Paris" },
        { "label": "Europe / Berlin", "iana": "Europe/Berlin" },
        { "label": "Europe / Rome", "iana": "Europe/Rome" },
        { "label": "Europe / Madrid", "iana": "Europe/Madrid" },
        { "label": "Europe / Athens", "iana": "Europe/Athens" },
        { "label": "Europe / Moscow", "iana": "Europe/Moscow" },
        { "label": "America / New York (EDT/EST)", "iana": "America/New_York" },
        { "label": "America / Chicago (CDT/CST)", "iana": "America/Chicago" },
        { "label": "America / Denver (MDT/MST)", "iana": "America/Denver" },
        { "label": "America / Los Angeles (PDT/PST)", "iana": "America/Los_Angeles" },
        { "label": "America / Toronto", "iana": "America/Toronto" },
        { "label": "America / Sao Paulo", "iana": "America/Sao_Paulo" },
        { "label": "Asia / Tokyo (JST)", "iana": "Asia/Tokyo" },
        { "label": "Asia / Shanghai (CST)", "iana": "Asia/Shanghai" },
        { "label": "Asia / Hong Kong", "iana": "Asia/Hong_Kong" },
        { "label": "Asia / Singapore", "iana": "Asia/Singapore" },
        { "label": "Asia / Kolkata (IST)", "iana": "Asia/Kolkata" },
        { "label": "Asia / Dubai (GST)", "iana": "Asia/Dubai" },
        { "label": "Australia / Sydney (AEST)", "iana": "Australia/Sydney" },
        { "label": "Pacific / Auckland (NZST)", "iana": "Pacific/Auckland" },
        { "label": "Custom Timezone / Offset...", "iana": "Custom" }
    ]

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
        var rawJson = cfg_clocksConfig;
        if ((!rawJson || rawJson === "[]") && typeof Plasmoid !== "undefined" && Plasmoid.configuration && Plasmoid.configuration.clocksConfig) {
            rawJson = Plasmoid.configuration.clocksConfig;
        }

        try {
            var parsed = JSON.parse(rawJson);
            if (Array.isArray(parsed) && parsed.length > 0) {
                for (var i = 0; i < parsed.length; i++) {
                    clocksModel.append({
                        "name": parsed[i].name || "",
                        "iana": parsed[i].iana || "UTC",
                        "enabled": parsed[i].enabled !== undefined ? parsed[i].enabled : true
                    });
                }
            } else {
                defaultClocks();
            }
        } catch (e) {
            defaultClocks();
        }
    }

    function defaultClocks() {
        clocksModel.clear();
        clocksModel.append({ "name": "Local", "iana": "Local", "enabled": true });
        clocksModel.append({ "name": "Warsaw", "iana": "Europe/Warsaw", "enabled": true });
        clocksModel.append({ "name": "UTC", "iana": "UTC", "enabled": true });
        clocksModel.append({ "name": "NY", "iana": "America/New_York", "enabled": true });
        clocksModel.append({ "name": "Tokyo", "iana": "Asia/Tokyo", "enabled": true });
        saveClocks();
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
        var jsonStr = JSON.stringify(list);
        cfg_clocksConfig = jsonStr;
        if (typeof Plasmoid !== "undefined" && Plasmoid.configuration) {
            Plasmoid.configuration.clocksConfig = jsonStr;
        }
        isInternalSaving = false;
    }

    function getTzComboIndex(ianaVal) {
        for (var i = 0; i < availableTimezones.length; i++) {
            if (availableTimezones[i].iana === ianaVal) {
                return i;
            }
        }
        return availableTimezones.length - 1; // Custom
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
            text: "Show timezone name near clock on panel"
        }

        Item {
            Kirigami.FormData.isHeader: true
            Kirigami.FormData.label: "Configured Clocks & Timezones"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            ListView {
                id: clocksListView
                Layout.fillWidth: true
                implicitHeight: Math.min(380, Math.max(160, clocksModel.count * 55))
                model: clocksModel
                clip: true

                delegate: QQC2.ItemDelegate {
                    width: clocksListView.width
                    contentItem: RowLayout {
                        spacing: 8

                        QQC2.CheckBox {
                            checked: model.enabled
                            text: "Show"
                            onCheckedChanged: {
                                clocksModel.setProperty(index, "enabled", checked);
                                root.saveClocks();
                            }
                        }

                        QQC2.TextField {
                            text: model.name
                            placeholderText: "Name (e.g. Warsaw)"
                            Layout.preferredWidth: 100
                            onEditingFinished: {
                                clocksModel.setProperty(index, "name", text);
                                root.saveClocks();
                            }
                        }

                        QQC2.ComboBox {
                            Layout.preferredWidth: 200
                            model: root.availableTimezones.map(function(item) { return item.label; })
                            currentIndex: root.getTzComboIndex(model.iana)
                            onActivated: function(idx) {
                                var selected = root.availableTimezones[idx];
                                if (selected.iana !== "Custom") {
                                    clocksModel.setProperty(index, "iana", selected.iana);
                                    root.saveClocks();
                                }
                            }
                        }

                        QQC2.TextField {
                            text: model.iana
                            placeholderText: "IANA string or offset"
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
                spacing: 12
                QQC2.Button {
                    text: "Add New Clock"
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
                    id: addPresetCombo
                    model: ["Quick Add Timezone Preset..."].concat(root.availableTimezones.map(function(item) { return item.label; }))
                    onActivated: function(idx) {
                        if (idx <= 0) return;
                        var tzItem = root.availableTimezones[idx - 1];
                        var defaultName = tzItem.iana.split("/").pop().replace("_", " ");
                        if (tzItem.iana === "Local") defaultName = "Local";
                        if (tzItem.iana === "UTC") defaultName = "UTC";

                        clocksModel.append({
                            "name": defaultName,
                            "iana": tzItem.iana,
                            "enabled": true
                        });
                        root.saveClocks();
                        addPresetCombo.currentIndex = 0;
                    }
                }
            }
        }
    }
}
