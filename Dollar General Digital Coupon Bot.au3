#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\ISN AutoIt Studio\autoitstudioicon.ico
#AutoIt3Wrapper_Compression=4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include "Includes\ImageSearch.au3"
#include <GDIPlus.au3>
#include <Misc.au3>
_Singleton("DGDCB")
Global $path = @TempDir & "\BetaLeaf Software\Dollar General Digital Coupon Bot"
Global $wintitle = "Dollar General Digital Coupon Bot"
DirCreate($path)
FileChangeDir($path)
FileInstall("Includes\ImageSearchDLL.dll", $path & "\ImageSearchDLL.dll", 1)
FileInstall("Includes\ImageSearch.au3", $path & "\ImageSearch.au3", 1)
FileInstall("Images\Click1.png", $path & "\Click1.png", 1)
FileInstall("Images\Click2.png", $path & "\Click2.png", 1)
FileInstall("Images\Click3.png", $path & "\Click3.png", 1)
_GDIPlus_Startup()
OnAutoItExitRegister("_Exit")
Global $iX, $iY, $Count
ProcessSetPriority(@ScriptName, 3)
ProcessSetPriority("AutoIt3.exe", 3)
Opt("MouseCoordMode", 1)
Opt("PixelCoordMode", 2)
Opt("TrayIconDebug", 1)
Opt("WinTitleMatchMode", 2)
;Opt("MouseClickDelay", 30)
;Opt("MouseClickDownDelay", 30)
If Not WinExists("Coupons Gallery") Then
	If ShellExecute("https://dg.coupons.com/coupons/") = 0 Then MsgBox(16, $wintitle, "Could not open browser to dg.coupons.com/coupons" & @CRLF & "Please open your browser to this url before continuing.")
	Sleep(3000)
EndIf
Global $hwnd = WinWait("Coupons Gallery")
Global $hwndpos = WinGetPos($hwnd)
Global $iLeft = $hwndpos[0]
Global $iTop = $hwndpos[1]
Global $iRight = $hwndpos[2] + $hwndpos[0]
Global $iBottom = $hwndpos[3] + $hwndpos[1]
MsgBox(64, $wintitle, "Make sure you are logged in, then press ok.")
Sleep(100)
WinActivate("Coupons Gallery")
For $i = 1 To 100
	Send("{end}")
	Sleep(100)
Next
Send("{home}")
Do
	For $i = 1 To 3
		$iFound = _FindImage($path & "\Click" & $i & ".png")
		If $iFound = 1 Then ExitLoop
	Next
	If $iFound = 0 Then ;if failed
		$Count += 1 ;increase count
	Else
		Sleep(100)
		$Count = 0
	EndIf
	If $Count > 2 Then
		Send("{pgdn}") ;if count exceeds 2 then page down
		Sleep(500)
	EndIf
	ConsoleWrite("Count = " & $Count & @CRLF)
Until $Count > 30
MsgBox(0, $wintitle, "Done.")
Func _FindImage($image) ;the function that searches
	Global $hImage = _GDIPlus_ImageLoadFromFile($image)
	If @error Then MsgBox(16, $wintitle, "Error1")
	Global $hHBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	If @error Then MsgBox(16, $wintitle, "Error2")
	Local $iRet = _ImageSearchArea($hHBmp, 1, $iLeft, $iTop, $iRight, $iBottom, $iX, $iY, 10, 0)
	_WinAPI_DeleteObject($hHBmp)
	_GDIPlus_ImageDispose($hImage)
	If $iRet = 1 Then
		ConsoleWrite("Found " & $image & "!" & @CRLF)
		MouseClick("", $iX, $iY, 1, 0)
		MouseMove(0, 0, 0)
		Return 1
	Else
		ConsoleWrite("Did not find " & $image & "." & @CRLF)
		Return 0
	EndIf
EndFunc   ;==>_FindImage
Func _Exit()
	_GDIPlus_Shutdown()
EndFunc   ;==>_Exit