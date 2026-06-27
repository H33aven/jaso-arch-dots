pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: root
    property real padding: 6

    property var player: Mpris.players.values[playerSelector.currentIndex] ?? Mpris.players.values[0]
    property var artUrl: player?.trackArtUrl ?? ""
    property string artDownloadLocation: Directories.coverArt
    property string artFileName: Qt.md5(artUrl)
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property color artDominantColor: Config.options.sidebar.media.artColors
        ? ColorUtils.mix(
            (colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary),
            Appearance.colors.colPrimaryContainer,
            0.8
          )
        : Appearance.colors.colPrimaryContainer
    property bool downloaded: false
    property string displayedArtFilePath: root.downloaded ? Qt.resolvedUrl(artFilePath) : ""

    Timer {
        running: root.player?.playbackState == MprisPlaybackState.Playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: root.player?.positionChanged()
    }

    onArtFilePathChanged: {
        if (!root.artUrl || root.artUrl.length == 0) {
            root.artDominantColor = Appearance.m3colors.m3secondaryContainer
            return
        }
        coverArtDownloader.targetFile = root.artUrl
        coverArtDownloader.artFilePath = root.artFilePath
        root.downloaded = false
        coverArtDownloader.running = true
    }

    Process {
        id: coverArtDownloader
        property string targetFile: root.artUrl
        property string artFilePath: root.artFilePath
        command: ["bash", "-c", `[ -f ${artFilePath} ] || curl -sSL '${targetFile}' -o '${artFilePath}'`]
        onExited: (exitCode, exitStatus) => { root.downloaded = true }
    }

    ColorQuantizer {
        id: colorQuantizer
        source: root.displayedArtFilePath
        depth: 0
        rescaleSize: 1
    }

    property QtObject blendedColors: AdaptedMaterialScheme {
        color: artDominantColor
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

            StyledComboBox {
                id: playerSelector
                visible: Mpris.players.values.length > 1
                Layout.fillWidth: true
                model: Mpris.players.values.map(p => p.identity ?? p.desktopEntry ?? "Unknown")
                currentIndex: 0
            }

            Item { Layout.fillWidth: true }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                Rectangle {
                    id: artBackground
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(parent.width * 1, parent.height * 0.4)
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: Appearance.rounding.normal
                    color: ColorUtils.transparentize(blendedColors.colLayer1, 0.5)

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: artBackground.width
                            height: artBackground.height
                            radius: artBackground.radius
                        }
                    }

                    StyledImage {
                        anchors.fill: parent
                        source: root.displayedArtFilePath
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        antialiasing: true
                        sourceSize.width: artBackground.width
                        sourceSize.height: artBackground.height
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    StyledText {
                        Layout.fillWidth: true
                        font.pixelSize: Appearance.font.pixelSize.huge
                        font.weight: Font.Bold
                        color: blendedColors.colOnLayer0
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: StringUtils.cleanMusicTitle(root.player?.trackTitle) || "Untitled"
                    }

                    StyledText {
                        Layout.fillWidth: true
                        font.pixelSize: Appearance.font.pixelSize.large
                        color: blendedColors.colSubtext
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: root.player?.trackArtist || "Unknown Artist"
                    }
                }

                Lyrics {
                    id: lyricsComp
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textAlignment: Text.AlignHCenter
                    textColor: blendedColors.colOnLayer0
                    activeColor: blendedColors.colPrimary
                    dimColor: blendedColors.colSubtext
                    indicatorColor: {
                        let c = blendedColors.colPrimaryContainer
                        return (c && c != "#000000" && c != "transparent") ? c : root.artDominantColor
                    }
                    indicatorShapeColor: {
                        let c = blendedColors.colOnPrimaryContainer
                        if (c && c != "#000000" && c != "#ffffff" && c != "transparent") return c
                        return blendedColors.colPrimary || Appearance.colors.colPrimary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    StyledText {
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: blendedColors.colSubtext
                        font.letterSpacing: -0.4
                        font.features: { "tnum": 1 }
                        text: StringUtils.friendlyTimeForSeconds(root.player?.position ?? 0)
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: Math.max(sliderLoader.implicitHeight, progressBarLoader.implicitHeight)

                        Loader {
                            id: sliderLoader
                            anchors.fill: parent
                            active: root.player?.canSeek ?? false
                            sourceComponent: StyledSlider {
                                configuration: StyledSlider.Configuration.Wavy
                                highlightColor: blendedColors.colPrimary
                                trackColor: blendedColors.colSecondaryContainer
                                handleColor: blendedColors.colPrimary
                                value: (root.player?.position ?? 0) / (root.player?.length ?? 1)
                                onMoved: {root.player.position = value * root.player.length
                                    lyricsComp.restartLyrics()
                                }
                            }
                        }

                        Loader {
                            id: progressBarLoader
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                right: parent.right
                            }
                            active: !(root.player?.canSeek ?? false)
                            sourceComponent: StyledProgressBar {
                                wavy: root.player?.isPlaying ?? false
                                highlightColor: blendedColors.colPrimary
                                trackColor: blendedColors.colSecondaryContainer
                                value: (root.player?.position ?? 0) / (root.player?.length ?? 1)
                            }
                        }
                    }

                    StyledText {
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: blendedColors.colSubtext
                        font.letterSpacing: -0.4
                        font.features: { "tnum": 1 }
                        text: StringUtils.friendlyTimeForSeconds(root.player?.length ?? 0)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    RippleButton {
                        property real baseSize: Math.max(42, parent.parent.height * 0.06)
                        implicitWidth: baseSize * 1.5
                        implicitHeight: baseSize * 1.5
                        buttonRadius: Appearance.rounding.verylarge
                        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 0.7)
                        colBackgroundHover: blendedColors.colSecondaryContainerHover
                        colRipple: blendedColors.colSecondaryContainerActive
                        downAction: () => root.player?.previous()
                        contentItem: MaterialSymbol {
                            iconSize: 25
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: blendedColors.colOnSecondaryContainer
                            text: "skip_previous"
                        }
                    }

                    RippleButton {
                        property real baseSize: Math.max(70, parent.parent.height * 0.1)
                        Layout.fillWidth: true
                        implicitHeight: baseSize
                        buttonRadius: (root.player?.isPlaying ?? false) ? Appearance.rounding.verylarge : baseSize / 2
                        colBackground: (root.player?.isPlaying ?? false) ? blendedColors.colPrimary : blendedColors.colSecondaryContainer
                        colBackgroundHover: (root.player?.isPlaying ?? false) ? blendedColors.colPrimaryHover : blendedColors.colSecondaryContainerHover
                        colRipple: (root.player?.isPlaying ?? false) ? blendedColors.colPrimaryActive : blendedColors.colSecondaryContainerActive
                        downAction: () => root.player?.togglePlaying()
                        contentItem: MaterialSymbol {
                            iconSize: 50
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: (root.player?.isPlaying ?? false) ? blendedColors.colOnPrimary : blendedColors.colOnSecondaryContainer
                            text: (root.player?.isPlaying ?? false) ? "pause" : "play_arrow"
                            Behavior on color {
                                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                        }
                    }

                    RippleButton {
                        property real baseSize: Math.max(42, parent.parent.height * 0.06)
                        implicitWidth: baseSize * 1.5
                        implicitHeight: baseSize * 1.5
                        buttonRadius: Appearance.rounding.verylarge
                        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 0.7)
                        colBackgroundHover: blendedColors.colSecondaryContainerHover
                        colRipple: blendedColors.colSecondaryContainerActive
                        downAction: () => root.player?.next()
                        contentItem: MaterialSymbol {
                            iconSize: 25
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: blendedColors.colOnSecondaryContainer
                            text: "skip_next"
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RippleButton {
                        property real baseSize: Math.max(36, parent.parent.height * 0.05)
                        implicitWidth: baseSize
                        implicitHeight: baseSize
                        buttonRadius: Appearance.rounding.large
                        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 0.7)
                        colBackgroundHover: blendedColors.colSecondaryContainerHover
                        colRipple: blendedColors.colSecondaryContainerActive
                        downAction: () => {
                            if (root.player) root.player.volume = (root.player.volume > 0) ? 0 : 1.0
                        }
                        contentItem: MaterialSymbol {
                            iconSize: 18
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: blendedColors.colOnSecondaryContainer
                            text: (root.player?.volume ?? 1) <= 0 ? "volume_off"
                                : (root.player?.volume ?? 1) < 0.5 ? "volume_down"
                                : "volume_up"
                        }
                    }

                    RippleButton {
                        property real baseSize: Math.max(36, parent.parent.height * 0.05)
                        Layout.fillWidth: true
                        implicitHeight: baseSize
                        buttonRadius: Appearance.rounding.large
                        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 0.7)
                        colBackgroundHover: blendedColors.colSecondaryContainerHover
                        colRipple: blendedColors.colSecondaryContainerActive
                        downAction: () => {
                            if (root.player) root.player.volume = Math.max(0, (root.player.volume ?? 1) - 0.1)
                        }
                        contentItem: MaterialSymbol {
                            iconSize: 18
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: blendedColors.colOnSecondaryContainer
                            text: "volume_down"
                        }
                    }

                    RippleButton {
                        property real baseSize: Math.max(36, parent.parent.height * 0.05)
                        Layout.fillWidth: true
                        implicitHeight: baseSize
                        buttonRadius: Appearance.rounding.large
                        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 0.7)
                        colBackgroundHover: blendedColors.colSecondaryContainerHover
                        colRipple: blendedColors.colSecondaryContainerActive
                        downAction: () => {
                            if (root.player) root.player.volume = Math.min(1.5, (root.player.volume ?? 1) + 0.1)
                        }
                        contentItem: MaterialSymbol {
                            iconSize: 18
                            fill: 1
                            horizontalAlignment: Text.AlignHCenter
                            color: blendedColors.colOnSecondaryContainer
                            text: "volume_up"
                        }
                    }
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
            text: "Space to play/pause, Ctrl+→ to next, Ctrl+← to previous"
            visible: root.player !== undefined
            opacity: 0.6
            Behavior on opacity {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.opacity = 1.0
                onExited: {
                    if (!hintTimer.running) {
                        parent.opacity = 0.3
                    }
                }
            }
            Timer {
                id: hintTimer
                interval: 4000
                running: true
                repeat: false
                onTriggered: {
                    hintText.opacity = 0.3
                }
            }
        }
    }
}