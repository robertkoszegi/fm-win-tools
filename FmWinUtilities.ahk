; #################################################################
; AUTHOR: Robert Koszegi
; DATE: 2025-08-10
; VERSION: 1.2
; REQUIREMENTS: Installation of AutoHotkey v2.0
; 
; #################################################################



; #################################################################
;							## HOUSEKEEPING ##
; #################################################################

#Requires AutoHotkey v2.0

; Allow Window name matching with regex
SetTitleMatchMode "Regex"

; InstallMouseHook

; Reload this script: Ctrl + Alt + R
#HotIf WinActive("ahk_exe Code.exe")

	^!r::Reload

#HotIf 

; Test shortcut: Ctrl + Alt + F
^!f:: {

	; static lastClick := 0
	; if (A_TickCount - lastClick < 500) {  ; 300 ms threshold
	; 	MsgBox "Double-click detected!"
	; }
	; lastClick := A_TickCount

}



; View clipboard: Crl + Shift + ?
^+/::{

	MsgBox A_Clipboard

}
; #################################################################


; #################################################################
; 							## FM UTILITIES ##
; #################################################################
; ==========================================================
; 					GLOBAL
; ==========================================================
; ~LButton:: {

; 	static lastClick := 0
; 	if (A_TickCount - lastClick < 300) {  ; 300 ms threshold
; 		; MsgBox "Double-click detected!"
; 		SaveUserClipboard
		
; 		Copy
; 		ClipWait
; 		wordSelected := A_Clipboard
; 		if(RegExMatch())


; 		RestoreUserClipboard

; 	}
; 	lastClick := A_TickCount

; }




; ==========================================================
; 					DOCUMENT WINDOWS
; ==========================================================
#HotIf WinActive("ahk_class FMPRO\d\d.0APP$")




	; Check for Layout Mode
	IsLayoutMode()
	{

		; View>Page Breaks menu item only exists in Layout Mode.
		TogglePageBreak()
		{

			MenuSelect("ahk_class FMPRO\d\d.0APP$","","View","Page Breaks")
		
		}

		try {

			; Turn on page breaks as a test
			TogglePageBreak()

		} catch {

			; error: menu item does not exist
			return false

		} else {

			; Turn page breaks off
			TogglePageBreak()
			return true

		}

	}


	
	; == GENERAL ==

	; Open Recent
	^!+o::SendInput "!fts"

	; Quick Open
	^!q::SendInput "^k"

	; Open Data Viewer
	^+v::SendInput "!tv"

	; Open Debugger
	^+b::SendInput "!td"

	; Open Layout Manager
	^!+a::SendInput "^+l"

	; Toggle Layout Mode / Browse Mode: Ctrl + Alt + A
	^!a::{

		if( IsLayoutMode() ){

			SendInput "^b"

		} else {

			SendInput "^l"

		}

	}


	; == BROWSE MODE ==
	
	; Ctrl+Backspace
	^BackSpace::
	{

		if( not IsLayoutMode() ){

			Send "^+{Left}"
			Send "{Backspace}"

		}

	}


	; == LAYOUT MODE ==
	
	; New Inspector
	^!i::
	{

		if( IsLayoutMode() ){

			activeWindow := WinGetTitle("A")
			SendInput "!vnn"
			Sleep 250
			WinActivate ("ahk_class FMPRO\d\d.0APP$")
			
		}

	}

	; Conditional Formatting
	; Ctrl + Alt + Shift + C (with a text object selected)
	^!+c::
	{

		if( IsLayoutMode() ){

			SendInput "!ma"
			
		}

	}

	; Slide Control Setup
	; Alt + Shift + C (with a slide control selcted)
	!+c::
	{

		if( IsLayoutMode() ){

			SendInput "!mss{Enter}"
			
		}

	}

	; Show Sample Data
	; Ctrl + Alt + Shift + S
	^!+s::
	{

		if( IsLayoutMode() ){

			SendInput "!vss"
			
		}

	}
	

#HotIf 



; ==========================================================
; 					DATA VIEWER
; ==========================================================
; by name
#HotIf WinActive("Data Viewer") 

	; Add Expression
	!a::Send "{Tab}{Tab}{Enter}"

	; Duplicate Expression
	!d::Send "{Tab}{Tab}{Tab}{Enter}"

	; Edit Expression
	!e::Send "{Tab}{Tab}{Tab}{Tab}{Enter}"

	; Remove Expression
	!r::Send "{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}"

#HotIf


; ==========================================================
; 					SCRIPT DEBUGGER
; ==========================================================
#HotIf WinActive("Script Debugger")

	; Step Over
	^!Down::SendInput "{F5}"

	; Step Into
	^Down::{

		SendInput "{F6}"
		
		; Try bring focus back to debugger if it switches to Data Viewer or another window after executing script step
		Sleep 500
		if (WinExist("Script Debugger") and !WinActive("Script Debugger")) {
			
			WinActivate("Script Debugger")

		}

	}

	; Step Out
	^Up::SendInput "{F7}"

	; Set Next Step
	^Right::SendInput "^+{F5}"

	; Halt Script
	^Space::SendInput "^{F8}"

	

#HotIf 


; ==========================================================
; 					SCRIPT WORKSPACE
; ==========================================================
#HotIf WinActive("^Script Workspace.*") 

	; Open Debugger
	^+b::SendInput "^!r"

#HotIf


; ==========================================================
; 					LAYOUT MANAGER
; ==========================================================
; Functions to be added
#HotIf WinActive("^Manage Layouts.*") 

	; Open selected layout: E
	e::SendInput "!o"

#HotIf


; ==========================================================
;  					CALCULATION WINDOW
; ==========================================================
; (Specyfy Calculation[...], Edit Expression)
#HotIf WinActive("Edit Expression") || WinActive("^Specify Calculation.*") || WinActive("Edit Custom Function")
    ; Hotkeys that only work in "Edit Expression" of Specify Calculation window

	; == TEXT EDITING SHORTCUTS ==
	
	; UTILITY FUNCTIONS (for shortcuts below)
	SaveUserClipboard()
	{
		global userContent := ClipboardAll()
		ClearClipboard
	}

	RestoreUserClipboard()
	{
		global
		Sleep 1000
		A_Clipboard := userContent
		ClipWait
		userContent := ""
	}

	; Text management functions for shortcut definitions below (keeping things DRY)
	GoToStartOfText()
	{
		SendInput "^a"
		SendInput "{Left}"
	}

	GoToEndOfText()
	{
		SendInput "^a"
		SendInput "{Right}"
	}

	SelectRow()
	{
		SendInput "{End}"
		SendInput "+{Home}"
	}

	ClearClipboard()
	{
		A_Clipboard := ""
	}

	Copy()
	{
		SendInput "^c"
	}

	Paste()
	{
		SendInput "^v"
	}

	CopyCurrentRow()
	{
		ClearClipboard
		SelectRow
		Copy
		ClipWait
	}

	LineCount(text)
	{
		; Normalize to LF newlines (so CRLF and CR are treated the same)
		text := RegExReplace(text, "\r\n?", "`n")

		; Split into lines
		lines := StrSplit(text, "`n")

		; Count lines
		lineCount := lines.Length

		return lineCount
	}

		
	; SHORTCUTS
	; Comment out entire calculation: Ctrl + Alt + /
	^!/::{

		SaveUserClipboard
		
		SendInput "^a" ; select text
		Copy
		ClipWait ; Wait for content (Just need any number other than 0 seems as a parameter)
		selectedText := A_Clipboard
		isTextCommented := RegExMatch(selectedText, "^0\s*\/\*") > 0 
		
		; selectedText := A_Clipboard
		; ClearClipboard
		if(isTextCommented) {
			
			; Remove comment
			deleteCommentStart := RegExReplace( selectedText, "^0\s*\/\*", "")
			deleteCommentEnd := RegExReplace( deleteCommentStart, "\*\/$", "")
			deleteNewLines := RegExReplace(deleteCommentEnd, "^\r?\n|\r?\n$", "")
			A_Clipboard := deleteNewLines
			ClipWait()
			SendInput "^a" ; select text
			SendInput "{Backspace}"
			Paste
			
		} else {

			; text already selected 
			SendInput "{Left}" ; go to the beginning
			SendText "0" ; to leave something to evaluate (prevents the calculaton text from becoming a concatenated string with ¶'s)
			SendInput "{Enter}"
			SendText "/*"
			SendInput "{Enter}"
			GoToEndOfText
			SendInput "{Enter}"
			SendText "*/"
		
		}
		
		RestoreUserClipboard

	}

	; Comment out row: Ctrl + /
	^/::{

		SaveUserClipboard

		; Hightlight row a copy to clipboard
		CopyCurrentRow
		ClipWait ; Wait for content (Just need any number other than 0 seems as a parameter)
		selectedText := A_Clipboard
		isTextCommented := RegExMatch(selectedText, "^\/\/") > 0 
	
		if(isTextCommented){
		
			; Remove comment
			SendInput "{Home}"
			; ## Use RegExReplace() in the future?
			SendInput "{Delete}{Delete}" ; normal delete above Enter

		} else {
		
			; Comment line out
			SendInput "{Home}"
			SendText "//"

		}

		RestoreUserClipboard

	}

	; Switch row down: Alt + Down
	!Down::{

		KeyWait("Alt")	
		SaveUserClipboard

		; Detect if cursor is on last row
		SendInput "{Home}"
		SendInput "+{End}"
		SendInput "+{Down}"
		Copy
		ClipWait(0.5)
		textBelow := A_Clipboard

		if(LineCount(textBelow) < 2){
			
			; Move to the end
			SendInput "{Right}"
		
		} else {

			; Execute switch
			SendInput "{Left}"
			CopyCurrentRow
			SendInput "{Backspace}" ; empty row
			SendInput "{Delete}" ; remove empy row (positions: start of next row)
			SendInput "{End}" ; move to end of next row
			SendInput "{Enter}" ; new line
			Paste

		}

		RestoreUserClipboard

	}

	; Switch row up: Alt + Up
	!Up::{

		KeyWait("Alt")
		SaveUserClipboard

		; Detect if curson is on first row
		SendInput "{End}"
		SendInput "+{Home}"
		SendInput "+{Up}"
		Copy
		ClipWait(0.5)
		textAbove := A_Clipboard

		if(LineCount(textAbove) < 2){

			; Move to that start
			SendInput "{Left}"

		} else {

			SendInput "{Right}"
			CopyCurrentRow
			SendInput "{Backspace}" ; empty row
			SendInput "{Backspace}" ; remove empy row (position: end of previous row)
			SendInput "{Home}"
			SendInput "{Enter}"
			SendInput "{UP}"
			Paste
		
		}

		RestoreUserClipboard

	}

	; Duplicate Row Down
	!+Down::{

		KeyWait("Alt")
		KeyWait("Shift")
		SaveUserClipboard

		SelectRow
		Copy
		SendInput "{End}"
		SendInput "{Enter}"
		Paste

		RestoreUserClipboard

	}
	

	; Duplicate Row Up
	!+Up::{

		KeyWait("Alt")
		KeyWait("Shift")
		SaveUserClipboard

		SelectRow
		Copy
		SendInput "{Home}"
		SendInput "{Enter}"
		SendInput "{Up}"
		Paste

		RestoreUserClipboard

	}

	;  = Special Characters =
	; Pilcrow: Alt + 7
	; (this is the same shortcut as it is natively on Mac)
	!7::{
		SendInput "¶"
	}	
	
	; Not Equal: Alt + =
	 !=::{
		SendInput "≠"
	}

	; Less than or equal to: Alt + ,
	!,::{
		SendInput "≤"
	}

	; Greater than or equal to: Alt + .
	!.::{
		SendInput "≥"
	}

	; -- Switching up TAB and CTRL+TAB --
	Tab::{
		SendInput "^{Tab}"
	}

	^Tab::{
		SendInput "{Tab}"
	}
	; ------------------------------------
	
	; Detect a left-button double-click and trim trailing whitespace from the selection.
		~LButton:: {  ; fire on every left click, let it pass through
    if (A_PriorHotkey = "~LButton" && A_TimeSincePriorHotkey < 300) {
        TrimSelectionTrailingSpaces()
    }
}

	TrimSelectionTrailingSpaces() {
		SaveUserClipboard
		try {
			Copy
			ClipWait
			sel := A_Clipboard

			; Count trailing horizontal whitespace (spaces/tabs) at end of selection.
			; Use " +$" if you only want literal spaces.
			if RegExMatch(sel, "\h+$", &m) {   ; \h = horizontal whitespace (space or tab)
				n := StrLen(m[0])
				Loop n
					Send "+{Left}"            ; shrink selection from right by n chars
			}

		} finally {
			RestoreUserClipboard
		}
	}


#HotIf
; #################################################################

