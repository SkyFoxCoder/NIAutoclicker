;Non-Intrusive Autoclicker, by Shadowspaz, edited by SkyFoxCoder
;v2.3.0

#InstallKeybdHook
#SingleInstance, Force
DetectHiddenWindows, on
SetControlDelay -1
SetBatchLines -1
Thread, Interrupt, 0
SetFormat, float, 0.0

toggle := false
heldToggle := false
inputPresent := false
mouseMoved := false
settingPoints := false

clickRate := 20
Mode := 0
pmx := 0
pmy := 0

totalClicks := 1
currentClick := 1

TempRateCPS := 50
TempRateSPC := 1

setTimer, checkMouseMovement, 10

ConfigSaveDir := A_AppData . "\NIAutoClicker\"
ConfigFileName := "config.ini"
Gosub, LoadConfig


setTimer, setTip, 5
TTStart = %A_TickCount%
while (A_TickCount - TTStart < 5000 && (!toggle || !heldToggle))
{
    TooltipMsg = Press (Alt + Backspace) to toggle autoclicker `nPress (Alt + Equal(=)) to hold the click `n Press (Alt + Dash(-)) for options
}
TooltipMsg =

!-::
    if heldToggle
    {
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        while (A_TickCount - TTStart < 3000 && (!toggle || !heldToggle))
        {
            TooltipMsg = Stop Autoclick Hold to open Options ( Alt + Equal(=) ).
        }
        TooltipMsg =
        Return
    }

    IfWinNotExist, NIAC Settings
    {
        if settingPoints
        {
            toggle := false
            heldToggle := false
            settingPoints := false
            actWin :=
            TooltipMsg =
        }

        prevTC := totalClicks

        Gui, Show, w210 h160, NIAC Settings
        Gui, Add, Radio, x25 y10 gActEdit1 vMode, Clicks per second:
        Gui, Add, Radio, x25 y35 gActEdit2, Seconds per click:
        Gui, Add, Edit, x135 y8 w50 Number Left vtempRateCPS, % tempRateCPS
        Gui, Add, Edit, x135 y33 w50 Number Left vtempRateSPC, % tempRateSPC
        Gui, Add, Text, x30 y65, Total click locations:
        Gui, Add, Edit, x133 y63 w50 Number Left vtotalClicks, % totalClicks
        Gui, Add, Text, x0 w210 0x10
        Gui, Add, Text, x27 y100, (Default is 50 clicks per second)
        Gui, Add, Button, x60 y117 gReset, Reset
        Gui, Add, Button, x112 y117 Default gSetVal, Set
        Gui, Font, s6
        Gui, Add, Text, x101 y151, Edited by SkyFoxCoder - v2.2.0
        if mode < 2
        {
            GuiControl,, Mode, 1
            GoSub, ActEdit1
        }
        else
        {
            GuiControl,, Seconds per click:, 1
            GoSub, ActEdit2
        }
    }
    else
        WinActivate, NIAC Settings
return

ActEdit1:
    GuiControl, Enable, tempRateCPS
    GuiControl, Disable, tempRateSPC
    GuiControl, Focus, tempRateCPS
    Send +{End}
return

ActEdit2:
    GuiControl, Enable, tempRateSPC
    GuiControl, Disable, tempRateCPS
    GuiControl, Focus, tempRateSPC
    Send +{End}
return

Reset:
    toggle := false
    heldToggle := false
    actWin :=
    setTimer, autoClick, off
    currentClick := 1
    GuiControl, Disable, Reset
    Gui, Font, s8
    Gui, Add, Text, x54 y145, Click locations reset.
return

SetVal:
    Gui, Submit
    if mode < 2
        clickRate := tempRateCPS > 0 ? 1000 / tempRateCPS : 1000
    else
        clickRate := tempRateSPC > 0 ? 1000 * tempRateSPC : 1000
    if totalClicks != %prevTC%
    {
        toggle := false
        heldToggle := false
        actWin :=
        setTimer, autoClick, off
    }
    Gosub, SaveConfig

GuiClose:
    if toggle
    {
        EmptyMem()
        setTimer, autoclick, %clickRate%
    }
    else if heldToggle
    {
        EmptyMem()
        setTimer, EnableHoldClick, on
    }
    Gui, Destroy
return

!Backspace::

    IfWinExist, NIAC Settings ; Only functional if options window is not open
    {
        return
    }

    toggle := !toggle
    if (!toggle)
    {
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        TooltipMsg = ##Autoclick disabled.
        setTimer, autoclick, off
        return
    }
    
    setTimer, setTip, 5
    if (!actWin) ; actWin value is also used to determine if checks are set. If they aren't:
    {
        settingPoints := true ; Used to allow break if options are opened
        Loop, %totalClicks%
        {
            if totalClicks < 2
                TooltipMsg = Click the desired autoclick location.
            else
                TooltipMsg = Click the location for point %A_Index%.
            toggle := false
            Keywait, LButton, D
            Keywait, LButton
            if !settingPoints ; Opening options sets this to false, breaking the loop
                return
            TooltipMsg =
            newIndex := A_Index - 1
            MouseGetPos, xp%newIndex%, yp%newIndex%
            WinGet, actWin, ID, A
        }
        settingPoints := false
    }
    else ; If values ARE set (actWin contains data):
    {
        settingPoints := false
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        TooltipMsg = ##Autoclick enabled.
    }
    toggle := true
    EmptyMem()
    setTimer, autoclick, %clickRate%
return

!=::
    IfWinExist, NIAC Settings ; Only functional if options window is not open
    {
        return
    }

    heldToggle := !heldToggle
    if (!heldToggle)
    {
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        TooltipMsg = ##Autoclick hold mode disabled.
        setTimer, EnableHoldClick, off
        setTimer, DisableHoldClick, on
        return
    }

    setTimer, setTip, 5
    if (!actWin) ; actWin value is also used to determine if checks are set. If they aren't:
    {
        TooltipMsg = Click the desired autoclick location.
        heldToggle := false
        Keywait, LButton, D
        Keywait, LButton
        TooltipMsg =
        MouseGetPos, xp0, yp0
        WinGet, actWin, ID, A
    }
    else ; If values ARE set (actWin contains data):
    {
        settingPoints := false
        setTimer, setTip, 5
        TTStart = %A_TickCount%
        TooltipMsg = ##Autoclick hold mode enabled.
    }
    heldToggle := true
    EmptyMem()
    setTimer, EnableHoldClick, on
return

setTip:
    StringReplace, cleanTTM, TooltipMsg, ##
    Tooltip, % cleanTTM
    if (InStr(TooltipMsg, "##") && A_TickCount - TTStart > 1000)
        TooltipMsg =
    if TooltipMsg =
    {
        Tooltip
        setTimer, setTip, off
    }
return

checkMouseMovement:
    if (WinExist("ahk_id" . actWin) || !actWin) ; If NIAC is clicking in a window, or the window isn't set, it's all good.
    {
        MouseGetPos, tx, ty
        if (tx == pmx && ty == pmy)
            mouseMoved := false
        else
            mouseMoved := true
        pmx := tx
        pmy := ty
    }
    else ; Otherwise, the target window has been closed.
    {
        Msgbox, 4, NIAC, Target window has been closed, `n Do you want to close NIAutoclicker as well?
        IfMsgBox Yes
            ExitApp
        else
        {
            actWin :=
            toggle := false
            heldToggle := false
        }
    }
return

autoclick:
    if !(WinActive("ahk_id" . actWin) && (A_TimeIdlePhysical < 50 && !mouseMoved))
    {
        cx := xp%currentClick%
        cy := yp%currentClick%
        ControlClick, x%cx% y%cy%, ahk_id %actWin%,,,, NA
        currentClick := % Mod(currentClick + 1, totalClicks)
    }
return

EnableHoldClick:
    if !(WinActive("ahk_id" . actWin) && (A_TimeIdlePhysical < 50 && !mouseMoved))
    {
        ControlClick, x%xp0% y%yp0%, ahk_id %actWin%,,,, D
    }
return

DisableHoldClick:
    if !(WinActive("ahk_id" . actWin) && (A_TimeIdlePhysical < 50 && !mouseMoved))
    {
        ControlClick, x%xp0% y%yp0%, ahk_id %actWin%,,,, U
        setTimer, DisableHoldClick, off
    }
return

LoadConfig:
    ; Check if config file exists, if not, create it.
    if !FileExist(ConfigSaveDir . ConfigFileName) {
        Gosub, CreateDefaultConfig
        return
    }

    ; Load values saved in the config file
    IniRead, TempRateCPS, %ConfigSaveDir%%ConfigFileName%, UserConfig, ClicksPerSeconds
    IniRead, TempRateSPC, %ConfigSaveDir%%ConfigFileName%, UserConfig, SecondsPerClick
return

SaveConfig:
    IniWrite, %TempRateCPS%, %ConfigSaveDir%%ConfigFileName%, UserConfig, ClicksPerSeconds
    IniWrite, %TempRateSPC%, %ConfigSaveDir%%ConfigFileName%, UserConfig, SecondsPerClick
return

CreateDefaultConfig:
    FileCreateDir, %ConfigSaveDir%
    file := FileOpen(ConfigSaveDir . ConfigFileName, "w")
    file.Write("[UserConfig]`nClicksPerSeconds=" . TempRateCPS . "`nSecondsPerClick=" . TempRateSPC)
    file.Close()
return

~*LButton up::
return

#If WinActive("ahk_id" . actWin) && toggle
    $~*LButton::
        MouseGetPos,,, winClick
        if winClick = %actWin%
            setTimer, autoclick, off
        Send {Blind}{LButton Down}
    return

    $~*LButton up::
        IfWinNotExist, NIAC Settings
            setTimer, autoclick, %clickRate%
        Send {Blind}{LButton Up}
    return

    EmptyMem()
    {
        pid:= DllCall("GetCurrentProcessId")
        h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
        DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
        DllCall("CloseHandle", "Int", h)
    }