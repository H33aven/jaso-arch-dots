import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real padding: 4

    property var inputField: inputCanvas.inputTextArea
    property string translatedText: ""
    property list<string> languages: []

    property string targetLanguage: Config.options.language.translator.targetLanguage
    property string sourceLanguage: Config.options.language.translator.sourceLanguage

    property bool showLanguageSelector: false
    property bool languageSelectorTarget: false

    function showLanguageSelectorDialog(isTargetLang: bool) {
        root.languageSelectorTarget = isTargetLang;
        root.showLanguageSelector = true
    }

    function swapLanguages() {
        let temp = root.sourceLanguage;
        root.sourceLanguage = root.targetLanguage;
        root.targetLanguage = temp;
        Config.options.language.translator.sourceLanguage = root.sourceLanguage;
        Config.options.language.translator.targetLanguage = root.targetLanguage;
        translateTimer.restart();
        root.inputField.forceActiveFocus();
    }

    onFocusChanged: (focus) => {
        if (focus) {
            root.inputField.forceActiveFocus()
        }
    }

    Timer {
        id: translateTimer
        interval: Config.options.sidebar.translator.delay
        repeat: false
        onTriggered: () => {
            if (root.inputField.text.trim().length > 0) {
                translateProc.running = false;
                translateProc.buffer = "";
                translateProc.running = true;
            } else {
                root.translatedText = "";
            }
        }
    }

    Process {
        id: translateProc
        command: ["bash", "-c", `trans -brief -no-bidi`
            + ` -source '${StringUtils.shellSingleQuoteEscape(root.sourceLanguage)}'`
            + ` -target '${StringUtils.shellSingleQuoteEscape(root.targetLanguage)}'`
            + ` '${StringUtils.shellSingleQuoteEscape(root.inputField.text.trim())}'`]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => {
                translateProc.buffer += data + "\n";
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.translatedText = translateProc.buffer.trim();
        }
    }

    Process {
        id: getLanguagesProc
        command: ["trans", "-list-languages", "-no-bidi"]
        property list<string> bufferList: ["auto"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                getLanguagesProc.bufferList.push(data.trim());
            }
        }
        onExited: (exitCode, exitStatus) => {
            let langs = getLanguagesProc.bufferList
                .filter(lang => lang.trim().length > 0 && lang !== "auto")
                .sort((a, b) => a.localeCompare(b));
            langs.unshift("auto");
            root.languages = langs;
            getLanguagesProc.bufferList = [];
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            LanguageSelectorButton {
                id: sourceButton
                Layout.fillWidth: true
                displayText: root.sourceLanguage
                onClicked: root.showLanguageSelectorDialog(false)
            }

            GroupButton {
                id: swapButton
                implicitWidth: height
                colBackground: Appearance.colors.colTertiaryContainer
                buttonRadius: Appearance.rounding.full
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "autorenew"
                    iconSize: 20
                    color: Appearance.colors.colOnLayer1
                }
                onClicked: root.swapLanguages()
            }

            LanguageSelectorButton {
                id: targetButton
                Layout.fillWidth: true
                displayText: root.targetLanguage
                onClicked: root.showLanguageSelectorDialog(true)
            }
        }

        TextCanvas {
            id: inputCanvas
            isInput: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            placeholderText: Translation.tr("Enter text to translate...")
            onInputTextChanged: translateTimer.restart()

            GroupButton {
                id: pasteButton
                baseWidth: height
                buttonRadius: Appearance.rounding.small
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "content_paste"
                    iconSize: Appearance.font.pixelSize.larger
                    color: deleteButton.enabled ? Appearance.colors.colOnLayer1 : Appearance.colors.colSubtext
                }
                onClicked: {
                    root.inputField.text = Quickshell.clipboardText
                }
            }
            GroupButton {
                id: deleteButton
                baseWidth: height
                buttonRadius: Appearance.rounding.small
                enabled: inputCanvas.inputTextArea.text.length > 0
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "close"
                    iconSize: Appearance.font.pixelSize.larger
                    color: deleteButton.enabled ? Appearance.colors.colOnLayer1 : Appearance.colors.colSubtext
                }
                onClicked: {
                    root.inputField.text = ""
                }
            }
        }

        TextCanvas {
            id: outputCanvas
            isInput: false
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            placeholderText: Translation.tr("Translation goes here...")
            text: root.translatedText

            GroupButton {
                id: copyButton
                baseWidth: height
                buttonRadius: Appearance.rounding.small
                enabled: outputCanvas.displayedText.trim().length > 0
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "content_copy"
                    iconSize: Appearance.font.pixelSize.larger
                    color: copyButton.enabled ? Appearance.colors.colOnLayer1 : Appearance.colors.colSubtext
                }
                onClicked: {
                    Quickshell.clipboardText = outputCanvas.displayedText
                }
            }
            GroupButton {
                id: searchButton
                baseWidth: height
                buttonRadius: Appearance.rounding.small
                enabled: outputCanvas.displayedText.trim().length > 0
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "travel_explore"
                    iconSize: Appearance.font.pixelSize.larger
                    color: searchButton.enabled ? Appearance.colors.colOnLayer1 : Appearance.colors.colSubtext
                }
                onClicked: {
                    let url = Config.options.search.engineBaseUrl + outputCanvas.displayedText;
                    for (let site of Config.options.search.excludedSites) {
                        url += ` -site:${site}`;
                    }
                    Qt.openUrlExternally(url);
                }
            }
        }

        Text {
            id: hintText
            Layout.fillWidth: true
            Layout.topMargin: 2
            horizontalAlignment: Text.AlignHCenter
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smallest
            text: Translation.tr("Alt+Tab to swap languages")
            opacity: (root.inputField.text.length > 0 || root.translatedText.length > 0) ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: root.showLanguageSelector
        visible: root.showLanguageSelector
        z: 9999
        sourceComponent: SelectionDialog {
            id: languageSelectorDialog
            titleText: Translation.tr("Select Language")
            items: root.languages
            defaultChoice: root.languageSelectorTarget ? root.targetLanguage : root.sourceLanguage
            onCanceled: () => {
                root.showLanguageSelector = false;
            }
            onSelected: (result) => {
                root.showLanguageSelector = false;
                if (!result || result.length === 0) return;
                if (root.languageSelectorTarget) {
                    root.targetLanguage = result;
                    Config.options.language.translator.targetLanguage = result;
                } else {
                    root.sourceLanguage = result;
                    Config.options.language.translator.sourceLanguage = result;
                }
                translateTimer.restart();
            }
        }
    }

    component TextCanvas: Rectangle {
        id: textCanvasRoot
        property bool isInput: true
        property string placeholderText
        property string text: ""
        property var inputTextArea: isInput ? inputLoader.item : undefined
        readonly property string displayedText: isInput ? (inputLoader.item ? inputLoader.item.text : "") :
            (text.length > 0 ? outputLoader.item.text : "")
        default property alias actionButtons: actions.data
        Layout.fillWidth: true
        implicitHeight: Math.max(150, inputColumn.implicitHeight)
        color: Appearance.colors.colLayer2
        radius: Appearance.rounding.normal

        signal inputTextChanged()

        ColumnLayout {
            id: inputColumn
            anchors.fill: parent
            spacing: 0

            Loader {
                id: inputLoader
                active: textCanvasRoot.isInput
                visible: textCanvasRoot.isInput
                Layout.fillWidth: true
                sourceComponent: StyledTextArea {
                    id: inputTextArea
                    placeholderText: textCanvasRoot.placeholderText
                    wrapMode: TextEdit.Wrap
                    textFormat: TextEdit.PlainText
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                    padding: 15
                    background: null
                    onTextChanged: textCanvasRoot.inputTextChanged()
                }
            }

            Loader {
                id: outputLoader
                active: !textCanvasRoot.isInput
                visible: !textCanvasRoot.isInput
                Layout.fillWidth: true
                sourceComponent: StyledText {
                    id: outputTextArea
                    padding: 15
                    wrapMode: Text.Wrap
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: textCanvasRoot.text.length > 0 ? Appearance.colors.colOnLayer1 : Appearance.colors.colSubtext
                    text: textCanvasRoot.text.length > 0 ? textCanvasRoot.text : textCanvasRoot.placeholderText
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 10

                Loader {
                    active: textCanvasRoot.isInput
                    visible: textCanvasRoot.isInput
                    Layout.leftMargin: 10
                    sourceComponent: Text {
                        text: Translation.tr("%1 characters").arg(inputLoader.item ? inputLoader.item.text.length : 0)
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
                Item { Layout.fillWidth: true }
                ButtonGroup {
                    id: actions
                }
            }
        }
    }

    component LanguageSelectorButton: RippleButton {
        id: langButton
        property string displayText: ""
        colBackground: Appearance.colors.colLayer2

        implicitWidth: contentItem.implicitWidth + horizontalPadding * 2
        implicitHeight: contentItem.implicitHeight + verticalPadding * 2

        contentItem: Item {
            anchors.centerIn: parent
            implicitWidth: languageRow.implicitWidth
            implicitHeight: languageText.implicitHeight
            RowLayout {
                id: languageRow
                anchors.centerIn: parent
                spacing: 0
                StyledText {
                    id: languageText
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 5
                    text: langButton.displayText
                    color: Appearance.colors.colOnLayer2
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    iconSize: Appearance.font.pixelSize.hugeass
                    text: "arrow_drop_down"
                    color: Appearance.colors.colOnLayer2
                }
            }
        }
    }

    Shortcut {
        sequence: "Alt+Tab"
        onActivated: {
            swapLanguages();
        }
    }
}