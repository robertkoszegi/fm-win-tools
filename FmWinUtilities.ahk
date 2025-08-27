; #################################################################
; AUTHOR: Robert Koszegi
; DATE: 2025-08-26
; VERSION: 2.1
; REQUIREMENTS: 
;  - Installation of AutoHotkey v2.0
;  - FileMaker 21 Windows (but majority of the features work on any recent FM versions for Windows)
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



; View clipboard: Crl + Shift + ?
^+/::{

	MsgBox A_Clipboard

}
; #################################################################


; #################################################################
; 							## FM UTILITIES ##
; #################################################################
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
			
			if(WinExist(gBadgePanelTitle)) {

				WinClose(gBadgePanelTitle)
				
			}
			SendInput "^b"

		} else {

			SendInput "^l"

		}

	}

	; Switch to Browse Mode: Ctrl + B
	; Closing the Show Badges panes automatically when using the native shortcut 
	^b::{

		if( IsLayoutMode() ){
			
			; Show Badges panes if open
			if(WinExist(gBadgePanelTitle)) {

				WinClose(gBadgePanelTitle)
				
			}
			SendInput "^b"

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


	; ===== Show Badges panel ============================
	; Ctrl + Shift + Alt + S
	; ================== Config & State ==================
	global gBadgePanel := ""
	global gBadgePanelVisible := false
	global gBadgePanelTitle := "Show Badges"

	badgeIcons := [
		"button","sample","text","field",
		"sliding","print","popover","placeholder",
		"hide","conditional","script","quickfind",
		"tooltip"
	]

	badgeTooltips := [
		"Buttons","Sample Data","Text Boundaries","Field Boundaries",
		"Sliding Objects","Non-Printing Objects","Popover Buttons","Placeholder Text",
		"Hide Condition","Conditional Formatting","Script Triggers","Quickfind",
		"Tooltips"
	]

	BTN_W := 36, BTN_H := 36          ; button size
	BMP_W := 32, BMP_H := 32          ; render size for PNG onto button

	; PNG resources & hover tooltip state
	global gBtnBmps := Map()          ; hwnd -> hBmp (for cleanup)
	global gBtnTips := Map()          ; hwnd -> tooltip text
	global gHoverHwnd := 0
	global gHoverTimerMs := 350
	global gHoverScheduled := false

	^+!s:: { ; Ctrl+Shift+Alt+S
		if IsLayoutMode() {                ; assuming you defined this elsewhere

			global gBadgePanel, gBadgePanelVisible

			; FMP acive window position
			WinGetPos &fmpX, &fmpY,,, "A"
			badgePanelPosX := fmpX + 950
			badgePanelPosY := fmpY + 10

			if (!IsObject(gBadgePanel)) {

				gBadgePanel := BuildBadgePanel()

			}

			if gBadgePanelVisible {

				gBadgePanel.Hide()
				gBadgePanelVisible := false
				ToolTip() ; hide any active tooltip

			} else {

				gBadgePanel.Show("x" badgePanelPosX "y" badgePanelPosY ) ; "AutoSize Center"
				gBadgePanelVisible := true

			}
		}
	}

	BuildBadgePanel() {
		global badgeIcons, badgeTooltips, BTN_W, BTN_H, BMP_W, BMP_H, gBadgePanelTitle
		global gBtnBmps, gBtnTips

		g := Gui("+AlwaysOnTop -Resize", gBadgePanelTitle)
		g.MarginX := 12, g.MarginY := 12
		g.SetFont("s10")

		; layout: 13 columns (single row when room allows)
		colCount := 13
		gapX := 8, gapY := 8
		marginX := g.MarginX, marginY := g.MarginY

		for i, icon in badgeIcons {

			row := Ceil(i / colCount)
			col := Mod(i - 1, colCount) + 1
			x := marginX + (col - 1) * (BTN_W + gapX)
			y := marginY + (row - 1) * (BTN_H + gapY)

			; Bitmap button (no caption). BS_BITMAP = 0x80
			btn := g.AddButton("x" x " y" y " w" BTN_W " h" BTN_H " +0x80", "")
			btn.id := icon

			; Load PNG -> HBITMAP and assign to button
			pngPath := A_ScriptDir "\Icons\" icon "_badge.png"
			if FileExist(pngPath) {

				hBmp := LoadPicture(pngPath, "w" BMP_W " h" BMP_H " hBitmap")
				
				if hBmp {

					; BM_SETIMAGE (0xF7), IMAGE_BITMAP (0)
					SendMessage 0xF7, 0, hBmp, btn.Hwnd
					gBtnBmps[btn.Hwnd] := hBmp

				}
			} else {
				; Uncomment to debug missing assets:
				; MsgBox "Missing icon: " pngPath
			}

			; Store tooltip text for custom hover tooltip system
			gBtnTips[btn.Hwnd] := badgeTooltips[i]

			btn.OnEvent("Click", BadgeButtonClick)
		}

		; -- Hover --
		; Reliable hover tooltips for bitmap buttons
		OnMessage(0x200, WM_MOUSEMOVE)  ; WM_MOUSEMOVE
		
		WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {

			global gBtnTips, gHoverHwnd
			MouseGetPos ,, &win, &ctrl, 2
			if (ctrl != gHoverHwnd) {

				gHoverHwnd := ctrl
				ToolTip()
				if (gBtnTips.Has(ctrl)) {

					ToolTip gBtnTips[ctrl]

				}

			}

		}
		; ---

		g.OnEvent("Escape", BadgePanel_Hide)
		g.OnEvent("Close",  BadgePanel_Hide)
		return g
	}

	BadgeButtonClick(ctrl, *) {

		; MsgBox "Clicked: " gBtnTips[ctrl.Hwnd]
		if(gBtnTips[ctrl.Hwnd] = "Buttons"){
			ButtonAction("!vsb")			

		} else if(gBtnTips[ctrl.Hwnd] = "Sample Data") {
			ButtonAction("!vss")	

		} else if(gBtnTips[ctrl.Hwnd] = "Text Boundaries") {
			ButtonAction("!vst")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Field Boundaries") {
			ButtonAction("!vsf")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Sliding Objects") {
			ButtonAction("!vso")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Non-Printing Objects") {
			ButtonAction("!vsn")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Popover Buttons") {
			ButtonAction("!vsv")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Placeholder Text") {
			ButtonAction("!vsl")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Hide Condition") {
			ButtonAction("!vsh")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Conditional Formatting") {
			ButtonAction("!vsr")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Script Triggers") {
			ButtonAction("!vsc")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Quickfind") {
			ButtonAction("!vsq")
			
		} else if(gBtnTips[ctrl.Hwnd] = "Tooltips") {
			ButtonAction("!vsp")
			
		}

		ButtonAction(shortcut) {
			WinActivate("ahk_class FMPRO\d\d.0APP$")
			SendInput shortcut
		}

	}

	BadgePanel_Hide(gui, *) {

		global gBadgePanelVisible, gHoverScheduled
		gBadgePanelVisible := false
		gHoverScheduled := false
		ToolTip()              ; hide tooltip immediately
		gui.Hide()

	}

	; --- Custom hover tooltip logic (works with BS_BITMAP buttons) ---
	BadgePanel_MouseMove(gui, x, y, *) {

		global gHoverHwnd, gHoverScheduled, gBtnTips
		MouseGetPos &mx, &my, &winHwnd, &ctrlHwnd, 2
		if (ctrlHwnd != gHoverHwnd) {

			gHoverHwnd := ctrlHwnd
			ToolTip()                ; hide current tooltip
			gHoverScheduled := false
			if (ctrlHwnd && gBtnTips.Has(ctrlHwnd)) {

				SetTimer(ShowHoverTooltip, -gHoverTimerMs)  ; one-shot delay
				gHoverScheduled := true
				
			}

		}

	}

	ShowHoverTooltip() {
		global gHoverHwnd, gBtnTips
		if (!gHoverHwnd)
			return
		if gBtnTips.Has(gHoverHwnd) {
			MouseGetPos &mx, &my
			ToolTip gBtnTips[gHoverHwnd], mx + 16, my + 16
		}
	}

	; Cleanup bitmaps on script exit
	OnExit(*) {
		global gBtnBmps
		for hwnd, hbmp in gBtnBmps {
			if hbmp
				DllCall("gdi32\DeleteObject", "ptr", hbmp)
		}
		gBtnBmps.Clear()
		ToolTip()
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
	!Enter::SendInput "!o"

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

	; Bullet: Alt + 8
	!8::{
		SendInput "•"
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

		if (A_PriorHotkey = "~LButton" && A_TimeSincePriorHotkey < 400) {
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

