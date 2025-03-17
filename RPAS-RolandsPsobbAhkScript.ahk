; --------------------------------------------
; -- Directives
; --------------------------------------------
#Requires AutoHotkey v2.0				; This is an AHK v2 script
#SingleInstance Force						; Only allow one instance of the script to run
#Include Gdip_All+TTG_Patch.ahk	; An advanced image rendering library (the native one doesn't support alpha transparency)
#Include PopUpWindowV4.ahk			; A library that is compatible with Gdip
#UseHook												; Improves key state read accuracy to help mitigate rapid fire sticky keys
KeyHistory(500)									; Increases the KeyHistory from default (40) to max (500) to help when debugging is needed


; --------------------------------------------
; -- Config
; --------------------------------------------
config										:= {}																																				; The config object
config.baseDir						:= EnvGet("UserProfile") "\RPAS-RolandsPsobbAhkScript"											; The subdirectory that houses our .ini and image files
config.iniPath						:= config.baseDir "\config.ini"																							; The location & file for the config.ini
config.rapidFire					:= {}																																				; The rapidFire config object
config.rapidFire.enabled	:= IniRead(config.iniPath, "config", "rapidFireEnabled", "true") == "true"	; Are the rapid-fire actions enabled?
config.rapidFire.delay		:= Integer(IniRead(config.iniPath, "config", "rapidFireDelay", "200"))			; What's the rapid-fire delay?
config.typedShortcuts			:= IniRead(config.iniPath, "config", "typedShortcuts", "true") == "true"		; Whether or not the bank/lobby shortcuts are typed or Shift+[Fn Key]
config.images							:= {}																																				; The images object
config.images.splash			:= config.baseDir "\RPAS-Splash.png"																				; The splash screen
config.images.uiBg41			:= config.baseDir "\RPAS-UiBackground4to1.png"															; The 4:1 UI message background
config.images.commands		:= config.baseDir "\RPAS-Commands.png"																			; The server commands infographic
config.images.controlMap	:= config.baseDir "\RPAS-ControlMap.png"																		; The controls map infographic
config.images.sectionIds	:= config.baseDir "\RPAS-SectionIds.png"																		; The section IDs infographic
config.scriptPath					:= config.baseDir "\RPAS-RolandsPsobbAhkScript.ahk"													; The source code, for end user inspection
config.targetWindowTitle	:= "PHANTASY STAR ONLINE Blue Burst"																				; The title of the application window
config.testing						:= false																																		; Allows the program to launch anywhere and makes all keybinds global (this would be bad UX for end users)


; --------------------------------------------
; -- File Installs
; --------------------------------------------
DirCreate  config.baseDir
FileInstall "RPAS-Splash.png",								config.images.splash,			1
FileInstall "RPAS-UiBackground41.png",				config.images.uiBg41,			1
FileInstall "RPAS-Commands.png",							config.images.commands,		1
FileInstall "RPAS-ControlMap.png",		 				config.images.controlMap,	1
FileInstall "RPAS-SectionIds.png",					 	config.images.sectionIds,	1
FileInstall "RPAS-RolandsPsobbAhkScript.ahk",	config.scriptPath,				1


; --------------------------------------------
; -- Events & Misc Inits
; --------------------------------------------	
ElevateIfNeeded()																							; Elevate the AHK script to admin if it's not already elevated (shows UAC, so launch AHK before PSO)
AddTaskBarMenuCommands()																			; Workaround for captured WinKey+P outside of game focus. Use this when outside the game.
AddSupplementalBinds()																				; Adds supplemental binds for QUERTZ keyboards & such
ShowSplashScreen()																						; Show the splash screen on load


; --------------------------------------------
; -- Global Binds
; --------------------------------------------
; NOTE: I wanted #p::LaunchPsoLauncher() here, but with the game unfocused, Windows 11 aggressively captures that keypress most of the time. So I moved it into the PSOBB binds & added "Launch PSO" to the taskbar icon's menu.


; --------------------------------------------
; -- Target Application Binds
; --------------------------------------------
#HotIf WinActive(config.targetWindowTitle) || config.testing 	; SCOPES BINDS TO APP

	; --------------------
	; --- ACTION KEY BINDS
	;---------------------
	Numpad0::RapidFire("0") ;numpad enabled binds
	Numpad1::RapidFire("1")
	Numpad2::RapidFire("2")
	Numpad3::RapidFire("3")
	Numpad4::RapidFire("4")
	Numpad5::RapidFire("5")
	Numpad6::RapidFire("6")
	Numpad7::RapidFire("7")
	Numpad8::RapidFire("8")
	Numpad9::RapidFire("9")
	;NumpadIns::RapidFire("0") ;numpad disabled binds (retired since they can cause infinite loops if shift gets stuck on rapidfire enter)
	;NumpadEnd::RapidFire("1")
	;NumpadDown::RapidFire("2")
	;NumpadPgDn::RapidFire("3")
	;NumpadLeft::RapidFire("4")
	;NumpadClear::RapidFire("5")
	;NumpadRight::RapidFire("6")
	;NumpadHome::RapidFire("7")
	;NumpadUp::RapidFire("8")
	;NumpadDot::RapidFire("9")
	;$0::RapidFire("0", "0") ;number binds (these interfere bigtime with typing numbers in ingame chat. plus, the numpad is far better ergonomically.)
	;$1::RapidFire("1", "1")
	;$2::RapidFire("2", "2")
	;$3::RapidFire("3", "3")
	;$4::RapidFire("4", "4")
	;$5::RapidFire("5", "5")
	;$6::RapidFire("6", "6")
	;$7::RapidFire("7", "7")
	;$8::RapidFire("8", "8")
	;$9::RapidFire("9", "9")
	
	
	; --------------------
	; -- CHAT SHORTCUTS
	;---------------------
	#`::DoShortcut("lobby")																						; /LOBBY SHORTCUT
	#b::DoShortcut("bank")																						; /BANK SHORTCUT
	#m::ChangeShortcutMode()																					; CHANGES SHORTCUTS FROM TYPED TO SHIFT+[FN]
	
	
	; --------------------
	; --- MISC BINDS
	;---------------------
	$PgUp::F2																													; REMAP EQUIP TO PAGE UP	(breaks PgUp)
	$PgDn::SendPlus("{Ctrl Down}{End}{Ctrl Up}", 50, 50)							; REMAP Q-MENU TO PAGE DOWN (breaks PgDn)
	#PgUp::SendPlus("{PgUp}", 50, 50)																	; REMAP SCROLL UP   TO Win+PGUP	(restores PgUp)
	#PgDn::SendPlus("{PgDn}", 50, 50)																	; REMAP SCROLL DOWN TO Win+PGDN (restores PgDn)
	F11::F12																													; DISABLE F11's "ALWAYS CHAT MODE" (since it disables keyboard controls!!!)
	NumpadDiv::F3																											; TECHNIQUE WINDOW
	NumpadMult::F4																										; MAG WINDOW
	NumpadSub::F6																											; SIMPLE MAIL
	NumpadAdd::F5																											; GUILD CARDS


	; --------------------
	; -- UTILITY BINDS
	;---------------------
	^v::SendPlus(A_Clipboard, 35, 35, {raw: 1, blind: 0})							; CLIPBOARD PASTE POLYFILL (Partial Credit: Orgodemirk)
	$+Enter::RapidFireOneMod("Enter", "Enter", "Shift", 30, 30, true)	; RAPID-FIRE ENTER (click shift again if hotkeys stop working. if it fixes it for you, shift was stuck)
	Numlock::return																										; DISABLE NUMLOCK (to toggle, hold alt & hit numlock twice (idk why lol))
	#Numpad2::RapidFireDelayToggle(false)															; RAPID-FIRE DELAY DECREMENT BIND
	#Numpad8::RapidFireDelayToggle(true)															; RAPID-FIRE DELAY INCREMENT BIND
	#f::LaunchDestinyFloorReader()																		; LAUNCH FLOOR READER (as admin)
	#p::LaunchPsoLauncher()																						; LAUNCH PSO LAUNCHER (as admin) (sadly, windows interfered with this being a global bind. so I moved it here & added the tray menu option)
	#0::SendPlus("{space}/sectionid 0{enter}", 50, 50)								; Viridia hotkey
	#1::SendPlus("{space}/sectionid 1{enter}", 50, 50)								; Greenill hotkey
	#2::SendPlus("{space}/sectionid 2{enter}", 50, 50)								; Skyly hotkey
	#3::SendPlus("{space}/sectionid 3{enter}", 50, 50)								; Bluefull hotkey
	#4::SendPlus("{space}/sectionid 4{enter}", 50, 50)								; Purplenum hotkey
	#5::SendPlus("{space}/sectionid 5{enter}", 50, 50)								; Pinkal hotkey
	#6::SendPlus("{space}/sectionid 6{enter}", 50, 50)								; Redria hotkey
	#7::SendPlus("{space}/sectionid 7{enter}", 50, 50)								; Oran hotkey
	#8::SendPlus("{space}/sectionid 8{enter}", 50, 50)								; Yellowboze hotkey
	#9::SendPlus("{space}/sectionid 9{enter}", 50, 50)								; Whitill hotkey


	; --------------------
	; -- INFOGRAPHIC BINDS
	;---------------------
	#/::ShowControlMap()
	#s::AddUiImage("info", config.images.sectionIds, 10000, {hP: 0.75, center: true, vCenter: true, toggle: true})
	#c::AddUiImage("info", config.images.commands,	 60000, {hP: 0.9,  center: true, vCenter: true, toggle: true})


	; --------------------
	; -- DEBUGGING BINDS
	;---------------------
	^!+w::ShowWindowTitle()
	^!+m::ShowHoveredWindowTitle()
	^!+Insert::KeyHistory

	
; --------------------------------------------
; --- Functions
;---------------------------------------------
ElevateIfNeeded(){
	if( not FileExist( "psobb.exe" ) && !config.testing ){
		ShowUiMessage("⚠ RPAS shutting down...  Move RPAS to a PSO directory & then relaunch.", 5000, {
			wP:0.5, center: true, vCenter: true, monitorFocus: true, fsP: 0.2
		})
		Sleep 5000
		ExitApp
	}
	if not A_IsAdmin													; Confirm admin privileges
		try {																		; Since this will throw an error if they refuse the UAC prompt
			Run "*RunAs " A_ScriptFullPath				; Will show UAC (Use a task scheduler shortcut to skip this Run command)
		} catch {
			ShowUiMessage("Elevated privileges refused, closing script...", 3000, {wP:0.5, center: true, vCenter: true, monitorFocus: true, fsP: 0.2})
			Sleep 3000
			ExitApp																; Exit the app if they refuse to elevate
		}
	return
}
ShowSplashScreen(){
	AddUiImage("splash", config.images.splash, 5000, {hP: 0.4, center: true, vCenter: true, monitorFocus: true, alpha: 250})
}
ShowUiMessage(msg, dur, options:={wP:0.2, marginP: 0.01}) => AddUiImage( "uiMessage", config.images.uiBg41, dur, options, msg	)
; #### AddUiImage() ######################################################################################################
;
; Functions		AddUiImage
; Description	Adds a GUI image
;
; type				The type of the image. Only of image for each type are allowed onscreen at a time.
; imagePath		The filepath for the image.
; duration		How many ms to display the image for
; options			Options for the image
;					wP hP					: required	: widthPercent / heightPercent
;					alpha					: optional	: will set the alpha transparency. if omitted, the default will be set
;					toggle				: optional	: will toggle off the existing same-hwnd image, if there is one, and exit
;					monitorFocus	: optional 	: will focus the image on the monitor instead of the active window
;					fsP						: optional	: fontSize
;					marginP				: optional	: marginPercent, will add this % of the width to the L/B margins
;					center				: optional	: will center the image horizontally in the active window
;					vCenter				: optional	: will center the image vertically in the active window
; caption		The text to show atop the image
;
; ########################################################################################################################
AddUiImage(type:="N/A", imagePath:="", duration:=3000, options:={}, caption:=false) {
	static ImgObjs		:= {}
	static Busy			:= 0
	static Retries		:= 0
	
	;<<< RE-QUEUE IF BUSY >>>
	if( Busy && ++Retries < 10 )
		return SetTimer( AddUiImage.Bind(type, imagePath, duration, options, caption), -100 )
	Retries := 0
	Busy := 1
	
	;<<< BUILD HWND >>> (build unique(?) hwnd from incoming parameters (don't include token))
	hwnd 			:= type imagePath duration StringifyObject(options) caption
	ImgObjs.%type%	:= ImgObjs.HasProp( type ) ? ImgObjs.%type% : 0
	token			:= Number(A_Now)
	
	;<<< DESTROY PREVIOUS, IF VISIBLE >>>
	if( IsObject( ImgObjs.%type% ) ) {
		destroyData := DestroyImage( type, hwnd )
		if ( options.HasProp("toggle") && options.toggle && destroyData.hwnd == hwnd )
			return ;don't rebuild when simply toggling the existing image off
	}
	
	;<<< DETERMINE APP TARGET >>>
	if( options.HasProp("monitorFocus") )
		X := 0, Y := 0, W := A_ScreenWidth, H := A_ScreenHeight
	else
		WinGetClientPos &X, &Y, &W, &H, "A"
	
	;<<< PREPARE IMAGE >>>
	ImgObjs.%type%		:= {}
	ImgObj					:= ImgObjs.%type%
	ImgObj.pToken		:= Gdip_Startup()
	ImgObj.bitmap		:= Gdip_CreateBitmapFromFile( imagePath )
	origWidth				:= Gdip_GetImageWidth(ImgObj.bitmap)
	origHeight			:= Gdip_GetImageHeight(ImgObj.bitmap)
	ImgObj.width		:= options.HasProp("wP") ? W * options.wP : (H * options.hP) * (origWidth / origHeight)
	ImgObj.height		:= options.HasProp("hP") ? H * options.hP : (W * options.wP) * (origHeight / origWidth)
	margin					:= options.HasProp("marginP") ? {x: W * options.marginP, y: W * options.marginP} : {x: 0, y: 0}
	margin.x				:= options.HasProp("center") ? (W / 2) - (ImgObj.width / 2) : margin.x
	margin.y				:= options.HasProp("vCenter") ? (H / 2) - (ImgObj.height / 2) : margin.y
	
	;<<< PREPARE POPUP >>>
	popupConfig := {}
	if( options.HasProp("monitorFocus") )
		popupConfig.Options	:= "+AlwaysOnTop +ToolWindow"
	else
		popupConfig.Options	:= "+Owner" WinActive( "A" ) " +ToolWindow"
	popupConfig.Rect	:= {W: ImgObj.width, H: ImgObj.height, X: X + margin.x, Y: Y + H - ImgObj.height - margin.y}
	ImgObj.Gui			:= PopupWindow_v4( popupConfig, 0, 0 )
	
	;<<< BUILD IMAGE >>>
	ImgObj.Gui.Clear()
	Gdip_DrawImage( ImgObj.Gui.G ,ImgObj.bitmap, 0, 0, ImgObj.width, ImgObj.height )
	Gdip_DisposeImage( ImgObj.bitmap )
	
	;<<< BUILD TEXT >>>
	if ( caption ) {
		FontSize := (options.HasProp("fsP") ? Float(options.fsP) : 0.27) * ImgObj.height
		FontOptions := "s" FontSize " cFF000000 vCenter Center Bold x" (FontSize * 0.1) " y" (FontSize * 0.1)
		Gdip_TextToGraphics( ImgObj.Gui.G, caption, FontOptions, "Calibri", ImgObj.width, ImgObj.height )	;black background text
		BgFontOptions := "s" FontSize " cFFFFFFFF vCenter Center Bold x0 y0"
		Gdip_TextToGraphics( ImgObj.Gui.G, caption, BgFontOptions, "Calibri", ImgObj.width, ImgObj.height ) ;white foreground text
	}
	
	;<<< SHOW OBJECTS >>>
	ImgObj.Gui.Update( options.HasProp("alpha") ? options.alpha : 100 )
	ImgObj.Gui.Show(,true,10,15) ;Show the window without activating it.
	SetTimer( DestroyImage.Bind( type, hwnd, token ) , -Abs( duration ) )
	ImgObj.hwnd			:= hwnd
	ImgObj.token		:= token
	ImgObj.options	:= options
	Busy						:= 0

	DestroyImage( wasType, wasHwnd, wasToken:=0 ){
		destroyData := {}
		try{
			if ( HasProp( ImgObjs, wasType ) && ( wasToken == 0 || ImgObjs.%wasType%.token == wasToken ) ) {
				destroyData.hwnd := ImgObjs.%wasType%.hwnd
				;fadeDur := wasToken != 0 ? 600 : 0
				;HideImage( ImgObjs.%wasType%, fadeDur ) ;doesn't produce a fade-out effect in the end...
				ImgObjs.%wasType%.Gui.Destroy()
				Gdip_Shutdown( ImgObjs.%wasType%.pToken )
				ImgObjs.%wasType% := 0
			}
		}
		Busy := 0
		return destroyData
	}
	
	HideImage(ImgObj, duration:=0) {
		duration := ImgObj.options.hasProp('fadeDur') ? ImgObj.options.fadeDur : duration
		if ( duration == 0 )
			ImgObj.Gui.Hide()
		else
			ImgObj.Gui.Hide( , 10, duration / 10 )
		;Sleep duration ;redundant? ImgObj.Gui.Hide (from PopUpWindowV4) does Sleeps...
	}
}
RapidFireDelayToggle(Increasing, Increment:=10) {
	oldDelay := Number(config.rapidFire.delay)
	if ( config.rapidFire.enabled == 0 && !Increasing ) {
		return ShowUiMessage( "Rapid fire disabled", 3000 )
	}
	config.rapidFire.delay += (Increasing ? Increment : -Increment)
	if ( config.rapidFire.delay == 0 ) {
		config.rapidFire.enabled := false
		ShowUiMessage("Rapid fire disabled", 3000)
	} else {
		if ( oldDelay == 0 ) {
			config.rapidFire.enabled := true
		}
		ShowUiMessage("Rapid fire delay: " config.rapidFire.delay " (" (Increasing ? "+" : "-") Increment ")", 3000)
	}
	IniWrite(config.rapidFire.delay, config.iniPath, "config", "rapidFireDelay")
	IniWrite(BooleanToString(config.rapidFire.enabled), config.iniPath, "config", "rapidFireEnabled")
}
RapidFireOneMod( pressedKey, targetKey, modKey:=false, delay:="default", duration:=10, alwaysOn:=false, unstickDelay:=200 ) { ;(for rapid-fires that use one mod key)
	delay := (delay == "default" ? config.rapidFire.delay : delay)
	static Busy := 0
	;<<< IGNORE IF ENGAGED >>>
	if( Busy )
		return
	Busy := 1
	
	;<<< CASE 1: TRIGGER W/RF ENABLED: GOGOGO >>>
	if( config.rapidFire.enabled || alwaysOn )
		SetTimer( RapidFireCallback.bind(pressedKey, targetKey, modKey), -1 )
	;<<< CASE 2: TRIGGER W/RF DISABLED: GO ON 1ST >>> (the key will repeat infinitely while held, so ignore the repeats)
	else {
		SendPlus("{" targetKey "}", delay, duration)
		KeyWait pressedKey ;delays the release of busy until the key is released, to ignore key repeats
		Busy := 0
	}
	
	;<<< RAPID-FIRE CALLBACK >>>
	RapidFireCallback(pressedKey, targetKey, modKey:=false) {
		if( GetKeyState(pressedKey, "P") && (modKey ? GetKeyState(modKey, "P") : true) ){
			SendEvent "{BLIND}{" targetKey " down}"
			Sleep duration
			SendEvent "{BLIND}{" targetKey " up}"
			Sleep delay
			SetTimer( RapidFireCallback.bind(pressedKey, targetKey, modKey), -1 )
		} else {
			Busy := 0
			SetTimer( UnstickModifierKeyCallback.bind(modKey), -Abs(unstickDelay) )
		}
	}
	
	;<<< UNSTICK-MODKEY CALLBACK >>> (When releasing Shift+Enter, occasionally Shift is virtually released & re-pressed (phsPress>vrtRls>vrtPress>pshRelease) causing shift to get stuck down, oddly)
	UnstickModifierKeyCallback(modKey) {
		if( modKey )
			SendEvent( "{BLIND} {" modKey " up}" )
	}
}
RapidFire( targetKey, pressedKey:=String(A_ThisHotKey), delay:="default", duration:=50, alwaysOn:=false ) { ; (for rapid-fires that lack a mod key)
	RapidFireOneMod( pressedKey , targetKey, false, delay, duration, alwaysOn )
}
ChangeShortcutMode(){
	config.typedShortcuts := !config.typedShortcuts
	IniWrite(BooleanToString(config.typedShortcuts), config.iniPath, "config", "typedShortcuts")
	ShowUiMessage( "Shortcut Mode: " (config.typedShortcuts ? "Typed" : "Chat Shortcuts"), 3000 )
}
DoShortcut(input, *){
	if ( config.typedShortcuts )
		SendPlus( " /" input "{Enter}", 50, 50, {blind: 0} ) ;disable blind mode to protect against WinKey+L lockscreen
	else if( input == "lobby" )
		SendPlus( "{Shift down}{F1}{Shift up}", 50, 50 )
	else if( input == "bank" )
		SendPlus( "{Shift down}{F2}{Shift up}", 50, 50 )
}
SendPlus(input, delay:="", duration:="", options:={}){
	options := ExtendObject( {raw: 0, blind: 1}, options )
	if (delay != "" || duration != "")
		SetKeyDelay (delay == "" ? 50 : delay), (duration == "" ? 50 : duration)
	return SendEvent( ( options.blind ? "{BLIND}" : "" ) ( options.raw ? "{RAW}" : "" ) input )
}
LaunchPsoLauncher(*){ ; (No UAC prompt, since RPAS is in admin)
	If ( FileExist("launcher.exe") ) {
		ShowUiMessage("Launching the PSO launcher...", 1500, {wP:0.5, center: true, vCenter: true, monitorFocus: true, fsP: 0.2})
		Sleep 1000 ;otherwise the UI message appears to linger too long, yet if we shortened it they wouldn't have time to read it
		return Run( "*RunAs " A_ScriptDir "\launcher.exe" )
	}
	ShowUiMessage("Unable to find launcher.exe...", 3000, {wP:0.5, center: true, vCenter: true, monitorFocus: true, fsP: 0.2})
}
LaunchDestinyFloorReader(*){ ; (No UAC prompt, since RPAS is in admin)
	If ( WinExist("Destiny Reader") ) {
		return ShowUiMessage("Destiny Reader is running", 3000)
	}
	target := {version: ""}
	Loop Files, "DestinyReader v*.exe" {
		thisVersion := StrReplace(StrReplace(A_LoopFileName, "DestinyReader v", ""),".exe", "")
		if( thisVersion != A_LoopFileName && ( target.version == "" || StrCompare( thisVersion, target.version ) > 0 ) ){
			target.version	:= thisVersion
			target.fullPath	:= A_LoopFileFullPath
			target.fileName := A_LoopFileName
		}
	}
	if( target.version != "" ){
		ShowUiMessage("Launching " target.fileName "...", 3000)
		Run( "*RunAs " target.fullPath )
		QueueRefocus() ;destiny reader sometimes (~15%) steals focus. let's steal it back! lol
	} else
		ShowUiMessage( "Destiny Reader not found", 3000 )
}
QueueRefocus( duration:=3000, tickRate:=200 ){ ; refocuses on target app
	SetTimer( Listener, tickRate )
	Listener() {
		static wasFocused := false, isFocused := false, active := 1, ticks := 0
		
		;<<< Expiration >>>
		if( ++ticks >= ( duration / tickRate ) )
			active := 0
		
		;<< Queued >>
		if ( active ) {
			isFocused := WinActive(config.targetWindowTitle)
			if( !isFocused && wasFocused && WinExist( config.targetWindowTitle ) ){
				active := 0
				WinActivate( config.targetWindowTitle )
			}
			wasFocused := isFocused
		}
		
		;<< Termination >>
		else {
			wasFocused := false, isFocused := false, active := 1, ticks := 0
			SetTimer( , 0 )
		}
	}
}
ShowControlMap(isMenuCommand:=false,*){ ; (shared between keybind and taskbard icon context menu command)
	options := {hP: 0.9,  center: true, vCenter: true, toggle: true}
	if( isMenuCommand )
		options.monitorFocus := true
	AddUiImage("info", config.images.controlMap, 60000, options)
}
AddTaskBarMenuCommands(){
	A_TrayMenu.Insert( "1&", "Launch PSO",							LaunchPsoLauncher																	)
	A_TrayMenu.Insert( "2&", "Launch Floor Reader",			LaunchDestinyFloorReader													)
	A_TrayMenu.Insert( "3&", "Show/Hide Control Map",		ShowControlMap.Bind(true)													)
	A_TrayMenu.Insert( "4&", "Open Screenshots Folder",	(*) => Run( "explorer.exe " A_ScriptDir "\bmp\" )	)
	A_TrayMenu.Insert( "5&", "Open PSO Folder",					(*) => Run( "explorer.exe " A_ScriptDir "\" )			)
}
AddSupplementalBinds(){
	;<<< QUERTZ LAYOUTS >>>
	HotIfWinActive config.targetWindowTitle		; scopes the binds to the target window
	HotKey( "#^", DoShortcut.Bind("lobby") )	; the equivalent of their ` key
	if( GetKeyVK( "ß" ) )											; the equivalent of their ? key
		HotKey( "#ß", ShowControlMap )
}
ShowWindowTitle(){
	ShowUiMessage( "The active window title is '" WinGetTitle("A") "'", 3000, { wP:0.4, fsP: 0.15, monitorFocus: true } )
}
ShowHoveredWindowTitle(){
  MouseGetPos(,,&hwnd,&classNN)
  title := WinGetTitle("ahk_id " hwnd)
  ShowUiMessage( "Mouse window hwnd:'" hwnd "', classNN:'" classNN "', title:'" title "'", 3000, { wP:0.4, fsP: 0.15, monitorFocus: true } )
}
BooleanToString(bool:=false) {
	return bool ? 'true' : 'false'
}
StringifyObject(Obj, Depth:=5, IndentLevel:="") {
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
	for k,v in Obj
	{
		ObjStr .= IndentLevel "[" k "]"
		if (IsObject(v) && Depth>1)
			ObjStr .= "`n" StringifyObject(v, Depth-1, IndentLevel . "    ")
		Else
			ObjStr .= " => " v
		ObjStr .= "`n"
	}
	return RTrim(ObjStr)
}
ExtendObject(TemplateObj, UniqueObject) { ;ex: ExtendObject( {raw: 0, blind: 1}, options )
	TemplateObj		:= Type(TemplateObj)	== "Object" ? DeepClone(TemplateObj)	: {}
	UniqueObject	:= Type(UniqueObject)	== "Object" ? DeepClone(UniqueObject)	: {}
	for k, v in UniqueObject.OwnProps() {
		TemplateObj.%k% := v
	}
	return TemplateObj
}
DeepClone(Obj) {
	CloneObj := {}
	for k, v in Obj.OwnProps() {
		CloneObj.%k% := IsObject(v) ? DeepClone(v) : v
	}
	return CloneObj
}
