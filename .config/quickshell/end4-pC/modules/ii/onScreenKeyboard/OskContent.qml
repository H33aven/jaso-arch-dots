import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: 560
    implicitHeight: 460

    property int rows: 9
    property int cols: 9
    property int totalMines: 10
    property int flagsLeft: totalMines
    property bool gameOver: false
    property bool gameWon: false
    property var grid: []
    property var cellStates: [] // 0 = closed, 1 = opened, 2 = flagged

    function initGame() {
        gameOver = false
        gameWon = false
        flagsLeft = totalMines
        grid = []
        cellStates = []
        for (var r = 0; r < rows; r++) {
            grid[r] = []
            cellStates[r] = []
            for (var c = 0; c < cols; c++) {
                grid[r][c] = 0
                cellStates[r][c] = 0
            }
        }
        var placed = 0
        while (placed < totalMines) {
            var rr = Math.floor(Math.random() * rows)
            var cc = Math.floor(Math.random() * cols)
            if (grid[rr][cc] === 0) {
                grid[rr][cc] = -1
                placed++
            }
        }
        for (r = 0; r < rows; r++) {
            for (c = 0; c < cols; c++) {
                if (grid[r][c] === -1) continue
                var count = 0
                for (var dr = -1; dr <= 1; dr++) {
                    for (var dc = -1; dc <= 1; dc++) {
                        if (dr === 0 && dc === 0) continue
                        var nr = r + dr
                        var nc = c + dc
                        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] === -1)
                            count++
                    }
                }
                grid[r][c] = count
            }
        }
        flagCountText.text = flagsLeft
        updateAllCells()
    }

    function openCell(row, col) {
        if (row < 0 || row >= rows || col < 0 || col >= cols) return
        if (gameOver || gameWon) return
        if (cellStates[row][col] === 2) return
        if (cellStates[row][col] === 1) return

        if (grid[row][col] === -1) {
            gameOver = true
            revealAll()
            updateAllCells()
            return
        }

        cellStates[row][col] = 1

        if (grid[row][col] === 0) {
            for (var dr = -1; dr <= 1; dr++) {
                for (var dc = -1; dc <= 1; dc++) {
                    if (dr === 0 && dc === 0) continue
                    var nr = row + dr
                    var nc = col + dc
                    if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
                        if (cellStates[nr][nc] === 0) {
                            openCell(nr, nc)
                        }
                    }
                }
            }
        }

        checkWin()
        updateAllCells()
    }

    function checkWin() {
        var opened = 0
        for (var r = 0; r < rows; r++) {
            for (var c = 0; c < cols; c++) {
                if (cellStates[r][c] === 1) opened++
            }
        }
        if (opened === rows * cols - totalMines) {
            gameWon = true
            gameOver = true
            for (r = 0; r < rows; r++) {
                for (c = 0; c < cols; c++) {
                    if (grid[r][c] === -1) cellStates[r][c] = 2
                }
            }
        }
    }

    function revealAll() {
        for (var r = 0; r < rows; r++) {
            for (var c = 0; c < cols; c++) {
                if (cellStates[r][c] !== 2) {
                    cellStates[r][c] = 1
                }
            }
        }
    }

    function toggleFlag(row, col) {
        if (gameOver || gameWon) return
        if (cellStates[row][col] === 1) return
        if (cellStates[row][col] === 0) {
            cellStates[row][col] = 2
            flagsLeft--
        } else if (cellStates[row][col] === 2) {
            cellStates[row][col] = 0
            flagsLeft++
        }
        flagCountText.text = flagsLeft
        var correctFlags = 0
        for (var r = 0; r < rows; r++) {
            for (var c = 0; c < cols; c++) {
                if (cellStates[r][c] === 2 && grid[r][c] === -1) correctFlags++
            }
        }
        if (correctFlags === totalMines) {
            gameWon = true
            gameOver = true
        }
        updateAllCells()
    }

    function updateAllCells() {
        for (var i = 0; i < rows * cols; i++) {
            var cell = gridRepeater.itemAt(i)
            if (cell) cell.updateState()
        }
        gameStatusText.text = gameOver ? (gameWon ? "You win!" : "Game over!") : ""
        gameStatusText.color = gameWon ? "#00b894" : "#d63031"
    }

    Component.onCompleted: {
        initGame()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        anchors.margins: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                spacing: 4
                MaterialSymbol {
                    iconSize: 20
                    text: "flag"
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    id: flagCountText
                    text: flagsLeft
                    font.pixelSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer0
                }
            }

            Item { Layout.fillWidth: true }

            RippleButton {
                buttonRadius: Appearance.rounding.normal
                implicitWidth: 40
                implicitHeight: 40
                onClicked: {
                    initGame()
                }
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: 24
                    color: Appearance.colors.colOnLayer0
                }
                StyledToolTip {
                    text: "New game"
                }
            }
        }

        Grid {
            id: gridContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: root.cols
            rows: root.rows
            spacing: 2

            Repeater {
                id: gridRepeater
                model: root.rows * root.cols

                delegate: Rectangle {
                    id: cellRect
                    width: (gridContainer.width - (root.cols - 1) * gridContainer.spacing) / root.cols
                    height: (gridContainer.height - (root.rows - 1) * gridContainer.spacing) / root.rows
                    radius: 4
                    color: {
                        var r = Math.floor(index / root.cols)
                        var c = index % root.cols
                        if (root.cellStates[r][c] === 2) return Appearance.colors.colPrimaryContainer
                        if (root.cellStates[r][c] === 1) {
                            if (root.grid[r][c] === -1) return Appearance.colors.colError
                            return Appearance.colors.colSurfaceContainerHighest
                        }
                        return Appearance.colors.colSurfaceContainer
                    }
                    border.color: Appearance.colors.colOutlineVariant
                    border.width: 1

                    function updateState() {
                        var r = Math.floor(index / root.cols)
                        var c = index % root.cols
                        if (root.cellStates[r][c] === 2) {
                            cellRect.color = Appearance.colors.colPrimaryContainer
                            cellSymbol.text = "flag"
                            cellSymbol.color = Appearance.colors.colOnPrimaryContainer
                            cellSymbol.visible = true
                        } else if (root.cellStates[r][c] === 1) {
                            if (root.grid[r][c] === -1) {
                                cellRect.color = Appearance.colors.colError
                                cellSymbol.text = "block"
                                cellSymbol.color = Appearance.colors.colOnError
                                cellSymbol.visible = true
                            } else {
                                cellRect.color = Appearance.colors.colSurfaceContainerHighest
                                if (root.grid[r][c] === 0) {
                                    cellSymbol.text = ""
                                    cellSymbol.visible = false
                                } else {
                                    cellSymbol.text = root.grid[r][c]
                                    cellSymbol.color = Appearance.colors.colOnSurface
                                    cellSymbol.visible = true
                                }
                            }
                        } else {
                            cellRect.color = Appearance.colors.colSurfaceContainer
                            cellSymbol.text = ""
                            cellSymbol.visible = false
                        }
                    }

                    MaterialSymbol {
                        id: cellSymbol
                        anchors.centerIn: parent
                        iconSize: Math.min(parent.width, parent.height) * 0.6
                        color: "transparent"
                        text: ""
                        visible: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: {
                            var r = Math.floor(index / root.cols)
                            var c = index % root.cols
                            if (mouse.button === Qt.LeftButton) {
                                if (root.cellStates[r][c] === 0) {
                                    root.openCell(r, c)
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                root.toggleFlag(r, c)
                            }
                        }
                    }

                    Component.onCompleted: {
                        updateState()
                    }
                }
            }
        }

        StyledText {
            id: gameStatusText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: ""
            font.pixelSize: Appearance.font.pixelSize.large
            color: "transparent"
            visible: gameOver
        }
    }
}