/*
 * Copyright (C) 2021 sammik
 * https://github.com/sammik/musescore-plugin-colornotes-hooktheory
 * AGPL 3 
 * 
 * based on Musescore Colornotes Plugin https://github.com/musescore/MuseScore/blob/master/share/plugins/colornotes.qml
 *
 */

import QtQuick 2.6
import QtQuick.Controls 2.2
import MuseScore 3.0
import QtQuick.Window 2.2


MuseScore {
    version:  "1.0"
    description: qsTr("This plugin colors notes in the selection depending on their pitch in Hooktheory Hookpad style")
    menuPath: "Plugins.Color Notes - Hooktheory"
    
    readonly property var colors : [ // "#rrggbb" with rr, gg, and bb being the hex values for red, green, and blue, respectively
      "#ff0000", // I.
      "#ffb014", // II.
      "#efe600", // III.
      "#00d300", // IV.
      "#4800ff", // V.
      "#b800e5", // VI.
      "#ff00cb"  // VII.
      ]
    readonly property string black : "#000000"
    readonly property string gray : "#333333"
    
    readonly property var scale : [0, , 1, , 2, 3, , 4, , 5, , 6]
    readonly property var modus : [0, 2, 4, 5, 7, 9, 11]

    property var modalIndex : modalBox.currentIndex
    property var tonalCenter : tonalBox.currentIndex
    
    // Apply the given function to all notes (elements with pitch) in selection
    // or, if nothing is selected, in the entire score

    function applyToNotesInSelection(func, restore) {
        var fullScore = !curScore.selection.elements.length
        if (fullScore) {
              cmd("select-all")
              curScore.startCmd()
        }
        for (var i in curScore.selection.elements)
            if (curScore.selection.elements[i].pitch)
                    func(curScore.selection.elements[i], restore)
        if (fullScore) {
            curScore.endCmd()
            cmd("escape")
        }
    }

    function colorNote(note, restore) {
        console.log(note.pitch, ((note.pitch + modus[modalIndex]) % 12), ((scale[(note.pitch + modus[modalIndex] + 12 - tonalCenter) % 12] + 7 - modalIndex) % 7));
        var color = (!restore) ? colors[(scale[(note.pitch + modus[modalIndex] + 12 - tonalCenter) % 12] + (modCenter.checkState == Qt.Checked ? (7 - modalIndex) : 0)) % 7] || gray : black;
        //var color = (!restore) ? colors[scale[(note.pitch + modus[modalIndex] + 12 - tonalCenter) % 12]] || gray : black;
         
        note.color = color;
        
        if (note.accidental) {
            note.accidental.color = color;
        }

        if (note.dots) {
            for (var i = 0; i < note.dots.length; i++) {
                if (note.dots[i]) {
                    note.dots[i].color = color;
                }
            }
        }
    }

    onRun: {
        console.log("hello hookstyle colornotes");
        window.visible = true
    }
    
    Window {
        id : window
        width : 200;
        height : 400
        visible: true
        
        Label {
            id: label
            width: column.width
            topPadding : 6
            wrapMode : Text.WordWrap
            text : qsTr("<font color=\"#ff0000\">C</font><font color=\"#ffb014\">o</font><font color=\"#efe600\">l</font><font color=\"#ffb014\">o</font><font color=\"#00d300\">r</font><font color=\"#4800ff\">i</font><font color=\"#b800e5\">z</font><font color=\"#ff00cb\">e</font> notes in style of 'hooktheory.com'.")
            anchors.horizontalCenter : parent.horizontalCenter
        }
        
        Column {
            id: column
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: label.bottom
            spacing : 6
            topPadding : 6
            
            Label {
                font.pointSize : 12
                text : qsTr("Select tonal center")
            }
            ComboBox {
                width: parent.width
                id: tonalBox
                model: ["C", "C# / Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]
            }
            CheckBox {
                id: modCenter
                text: "Modus base center"
            }
            ToolSeparator {
                width: parent.width
                orientation: Qt.Horizontal
            }
            Label {
                font.pointSize : 12
                text : qsTr("Select modus")
            }
            ComboBox {
                width: parent.width
                id: modalBox
                model: ["Major", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Minor", "Locrian"]
            }
            Button {
                id: colorize
                width: parent.width
                text: "Aply colors"
                onClicked: applyToNotesInSelection(colorNote)
            }
            ToolSeparator {
                width: parent.width
                orientation: Qt.Horizontal
            }
            Button {
                id: restore
                width: parent.width
                text: "Remove colors"
                onClicked: applyToNotesInSelection(colorNote, true)
            }
            
            
        }
        
        onClosing: Qt.quit()
    }
}
