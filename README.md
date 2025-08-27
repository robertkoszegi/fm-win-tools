# FM Win Tools v2.1

An AutoHotkey project to implement a comprehensive set of convenient keyboard shortcuts and functionality fixes for the FileMaker development environment on Windows.<br>
<br>
Edit as you wish to fit your preferences. Please reach out if you have any suggestions. 
<br>
More complex features and function templates to come. 



## Highlights

* *Window-specific, mode-specific shortcuts*
* *Primarily left-handed key combinations to reduce switching between mouse and keyboard with the right hand*
* *Basic code editing features in the calculation window*
* *Easily open main developer windows*
* *Easily manage expressions in the Data Viewer*
* *Intuitively use arrows to step through your script in the Debugger*
* *One shortcut to open Debugger from either window (Document or Script Workspace)*
* *One shortcut to toggle between Layout and Browse modes*
* Dedicated button panel for items under **View > Show** menu in **layout mode**

## Requirements
AutoHotkey v2.0 <br>
Unless otherwise noted below, FileMaker 16+ for Windows should be compatible

## Release Notes
### Badge Panel
* `Ctrl + Alt + Shift + S` updated the Show Badges panel to icon buttons with tooltip
* Badges panel now disappears when using Ctrl + B or custom shortcut Ctrl + Alt + A. Still the panel does not respond if switching to browse mode using 'Exit Layout' button or the View menu

* Added bullet character to the calculation window shortcuts

## Shortcuts

### Document Window

#### Browse Mode:
`Ctrl + Backspace`: Delete entire words in Browse Mode. (Not sure why this has always been missing from the document window in browse mode, but not anywhere else in FM.)

#### Layout Mode:
`Ctrl + Alt + I`: New inspector window<br>
`Ctrl + Alt + Shift + C`: Conditional formatting dialog (select object first)<br>
`Ctrl + Alt + Shift + S`: Show Badges Panel<br>
`Alt + Shift + C`: Slide control setup dialog (select object first) \[Kind of redundant, but why not?]<br>

#### General:
`Ctrl + Alt + Shift + O`: Open recent<br>
`Ctrl + Alt + Q`: Quick open (FM version 21+)<br>
`Ctrl + Shift + V`: Open Data Viewer<br>
`Ctrl + Shift + B`: Open Debugger (one shortcut for document and script workspace)<br>
`Ctrl + Shift + Alt + A`: Open Layout Manager <br>
`Ctrl + Alt + A`: Toggle layout mode / browse mode <br>

### Data Viewer
`Alt + A`: Add expression (sometimes you have to select an existing expression)<br>
`Alt + D`: Duplicate selected expression<br>
`Alt + E`: Edit selected expression<br>
`Alt + R`: Remove selected expression<br>

### Calculation Window
#### Editing Functions
`Ctrl + /`: Comment out current row<br>
`Ctrl + Alt + /`: Comment out entire calculation with number added to prevent the calc window from turning it into a concatenated string<br>
`Alt + Down`: Switch row down<br>
`Alt + Up`: Switch row up<br>
`Alt + Shift + Down`: Duplicate row down<br>
`Alt + Shift + Up`: Dublicate row up<br>
`Double click`: When double clicking a word, trailing spaces are removed from selection<br>

#### Special Characters
`Alt + 7`: Pilcrow character (same as on Mac and it's convenient with "\&" character)<br>
`Alt + 8`: Bullet character<br>
`Alt + =`: Not equal sign<br>
`Alt + ,`: Less than or equal to<br>
`Alt + .`: Greater or equal to<br>
`Tab`: Tab character (instead of Ctrl + Tab, which is annoying)<br>
`Ctrl + Tab`: Moves around dialog window (instead of regular Tab)<br>

### Script Debugger
`Ctrl + Down`: Step into<br>
`Ctrl + Alt + Down`: Step over<br>
`Ctrl + Up`: Step out<br>
`Ctrl + Right`: Set next step<br>
`Ctrl + Space`: Halt script<br>

### Script Workspace
`Ctrl + Shift + B`: Open Debugger (one shortcut for document and script workspace)<br>

### Layout Manager
`Alt + Enter`: More intuitive than Alt + O<br>
<br>

## History
**2.1 - 2025-08-17**<br>
-Updated Show Badges panel with icons and tooltips<br>
-Added bullet character to calculation window shortcuts<br>

**2.0 - 2025-08-17**<br>
-Added Show Badges panel<br>
-Updated shortcut for opening layout in Manage Layouts<br>

**1.2 - 2025-08-15**<br>
-Added removal of trailing spaces from highlight when double clicking a word

**1.1 - 2025-08-14**<br>
-Calculation window - row duplication added<br>
-Enableed calculation window features in Edit Custom Function window<br>

**1.0 - 2025-08-12**<br>
-Inital feature set<br>















