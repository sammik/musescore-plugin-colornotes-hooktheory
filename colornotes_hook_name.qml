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
    version:  "1.1"
    description: qsTr("This plugin colors notes in the selection depending on their names in Hooktheory Hookpad style")
    menuPath: "Plugins.Color Notes - Hooktheory - name based"
    
    requiresScore: false
    
    property var score: null
    property var keysig: 0
    
    readonly property var colors : [ // "#rrggbb" with rr, gg, and bb being the hex values for red, green, and blue, respectively
      "#00d300", // "F"
      "#ff0000", // "C"
      "#4800ff", // "G"
      "#ffb014", // "D"
      "#b800e5", // "A"
      "#efe600", // "E"
      "#ff00cb"  // "B"
      ]
    readonly property string black : "#000000"
    readonly property string gray : "#555555"
    
    property var tonalCenter : tonalBox.currentIndex
    property var mode: modalBox.currentIndex
    
    // Apply the given function to all notes (elements with pitch) in selection
    // or, if nothing is selected, in the entire score

    function applyToNotesInSelection(func, restore) {
        if (!score) 
            return
        
        var fullScore = !(score.selection.elements.length > 1)
        if (fullScore) {
            cmd("select-all")
            score.startCmd()
        }
        for (var i in score.selection.elements)
            if (score.selection.elements[i].pitch)
                func(score.selection.elements[i], restore)
        if (fullScore) {
            score.endCmd()
            cmd("escape")
        }
    }

    function colorNote(note, restore) {
        var color;
        var tpc = note.tpc;
        var center = tonalCenter - ( (mode * 2 + 1) % 7 - 1 );
        
        if (restore) {
            color = black;
        } 
        else { 
            if ( noAcc.checkState == Qt.Checked || tpc > (center + 5) && tpc < (center + 13) ){
                var colorIndex = ( tpc + 22 + ( noAcc.checkState == Qt.Checked || modCenter.checkState == Qt.Checked ? 0 : mode * 2 ) - tonalCenter ) % 7;
                console.log(colorIndex);
                color = colors[colorIndex];
            } 
            else {
                color = gray;
            }
        }
        
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
    
    function updateCurrentScore() {
        if (curScore && !curScore.is(score)) {
            score = curScore;
        } else if (score && !curScore) {
            score = null;
        }
        if ( score && !(keysig == score.keysig) ) {
            keysig = score.keysig;
            console.log("change")
            tonalBox.currentIndex = 7 + (score.keysig || 0);
        }
    }
    
    onScoreStateChanged: {
        updateCurrentScore();
    }

    onRun: {
        console.log("hello hookstyle colornotes");
        window.visible = true
        updateCurrentScore();
    }
    
    Window {
        id : window
        width : 200;
        height : 420
        visible: true
        
        Label {
            id: label
            width: column.width
            topPadding : 6
            wrapMode : Text.WordWrap
            text : qsTr("<font color=\"#ff0000\">C</font><font color=\"#ffb014\">o</font><font color=\"#efe600\">l</font><font color=\"#ffb014\">o</font><font color=\"#00d300\">r</font><font color=\"#4800ff\">i</font><font color=\"#b800e5\">z</font><font color=\"#ff00cb\">e</font> notes in style of 'hooktheory.com' based on note names.")
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
                model: ["Cb", "Gb", "Db", "Ab", "Eb", "Bb", "F", "C", "G", "D", "A", "E", "B", "F#", "C#"]
                currentIndex: 7
            }
            CheckBox {
                id: noAcc
                text: "Ignore accidentals"
            }
            CheckBox {
                id: modCenter
                text: "Modus base center"
                visible: noAcc.checkState !== Qt.Checked
            }
            ToolSeparator {
                width: parent.width
                orientation: Qt.Horizontal
            }
            Label {
                font.pointSize : 12
                text : qsTr("Select modus")
                visible: noAcc.checkState !== Qt.Checked
            }
            ComboBox {
                width: parent.width
                id: modalBox
                model: ["Major", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Minor", "Locrian"]
                visible: noAcc.checkState !== Qt.Checked
            }
            Button {
                id: colorize
                width: parent.width
                text: "Apply colors"
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
