#NoEnv
#SingleInstance, Force
#Persistent
#MaxMem 600
SendMode Input
SetWorkingDir %A_ScriptDir%
setwindelay,-1
setcontroldelay,-1
SetBatchLines, -1
SetTitleMatchMode, 2
SetTimer, register, off
SetTimer, safeguard, off
SetTimer, numcheck, 75
StringTrimRight, thisahk, A_ScriptName, 4
onexit,exitsub
IniRead, pspath, %thisahk%.ini, Settings, path

PS7list1=PokerStarsListClass15
PS7list2=PokerStarsListClass16
defaultregbutton:="PokerStarsButtonClass10"
customregbutton:="PokerStarsButtonClass10"

;;;;;;;;;;;example: logfile:="c:\Program Files\PokerStars\pokerstars.log.0"

logfile:= "c:\Users\velob\AppData\Local\PokerStars.USPA\PokerStars.log.0"

IfNotExist,%logfile%
{
  Loop, %A_ProgramFiles%\* , 2
  {
    if instr(A_LoopFileName,"PokerStars")>0
      logfile:=A_LoopFileFullPath . "\PokerStars.log.0"
  }
  IfNotExist,%logfile%
    Loop, %A_AppData%\* , 2
    if instr(A_LoopFileName,"PokerStars")>0
    logfile:=A_LoopFileFullPath . "\PokerStars.log.0"
  IfNotExist,%logfile%
  {
    StringReplace,logfile,A_AppData,Roaming,Local
    Loop, %logfile%\* , 2
      if instr(A_LoopFileName,"PokerStars")>0
      logfile:=A_LoopFileFullPath . "\PokerStars.log.0"
  }
}
IfNotExist,%logfile%
{
  logfile:= pspath . "pokerstars.log.0"
  IfNotExist,%logfile%
    msgbox, PokerStars.log.0 file path is probably incorrect, recheck the configuration
}
IniRead, Targetnum, %thisahk%.ini, Settings, Targetnum
if Targetnum is not number
  Targetnum:=0
;==============================================================
RegSofar=0
OpenTables=0
trows=17
SysGet,mon, MonitorworkArea
fivesec=0
ft:=0
two=0
ddlist4=Off|
ddlist5=Off|
ddlist6=Off|
ddlist7=Off|
LobbyList=Default|Black|
ddlist2:=ddlist2 . 1 . "|"
ddlist2:=ddlist2 . 2 . "|"
Loop 100
{
  two:=two+1
  ddlist3:=ddlist3 . two . "|"
  ddlist:=ddlist . A_index . "|"
  If (A_index<51)
  {
    fivesec:=fivesec+5
    ddlist2:=ddlist2 . fivesec . "|"
    ddlist6:=ddlist6 . fivesec . "|"
    If (A_index<22)
    {
      ddlist7:=ddlist7 . A_Index . "|"
      If (A_index<16)
      {
        ddlist4:=ddlist4 . A_index . "|"
      }
    }
  }
  else
  {
    ft:=ft+15
    ddlist5:=ddlist5 . ft . "|"
  }
}
ddlist3:=ddlist3 . 9999 . "|"
Gosub, deletelog
Gosub, BuildGui
Return
;==============================================================
;==============================================================

BuildGui:
  Gui, color, white
  Gui, font, cOlive
  Gui, add, tab, h340 w240, General|Advanced Settings
  Gui, add, text, , Auto-register
  Gui, add, Checkbox, yp xp+80 Check3 Checked-1 vRegister
  Gui, add, text, yp xp+30, Reg. next if full?
  Gui, add, Checkbox, yp xp+80 VAutoifFull
  Gui, add, text,xp-190 yp+30 , Register every (sec):
  Gui, add, DropDownList, w50 yp-5 xp+140 vInterval1, %ddlist2%
  Gui, add, text, xp-140 yp+30, No of SNG:s to keep open:
  Gui, add, DropDownList, w50 yp-5 xp+140 vKeepOpen , %ddlist%
  Gui, add, text,xp-140 yp+30, Limit total SNG:s to:
  Gui, add, DropDownList, w50 yp-5 xp+140 vTotalLimit , %ddlist3%
  Gui, add, text,xp-140 yp+30, Limit total time to (min):
  Gui, add, DropDownList, w50 yp-5 xp+140 vLimitTime , %ddlist5%

  Gui, add, text, xp-140 yp+30 cred vcdown w200
  Gui, add, text, xp yp+30 w200 vRegSofar, SNG:s registered so far:
  Gui, add, text, w200 vOpenTables, Tables open/waiting:
  Gui, add, text, w200 cRed vStatus, Status: Idle
  Gui, add, Button, w68 ggetgui, &Submit+Run
  Gui, add, text, xp+72 yp+5, (Autosaves your settings)
  Gui, Add, Button, Disabled xp-72 yp+20 w48 h20 Center , &Resume
  Gui, Add, Button, Disabled w45 h20 yp xp+48 Center , &Pause
  Gui, Add, Button, w80 h20 yp xp+45 Center globbyrestore, &Lobby restore
  Gui, Add, Button, w40 h20 yp xp+80 Center greset, Reset
  Gui, tab, 2

  Gui, add, Text, x25 y65 , Lobby Theme:
  Gui, add, DropDownList, w65 yp-5 xp+140 vLobby, %LobbyList%
  Gui, add, text,xp-140 yp+30 , Close lobbies every (sec):
  Gui, add, DropDownList, w50 yp-5 xp+140 vCloseInterv, %ddlist6%
  Gui, add, text, xp-140 yp+18 , (manually Close with ctrl+e)
  Gui, add, text, yp+30, Disable if no user Input (min):
  Gui, add, DropDownList, w50 yp-5 xp+140 vGuardtimer Choose1 , %ddlist4%
  Gui, add, text, xp-140 yp+30 ,Batch-register?
  Gui, add, Checkbox,yp xp+140 vBatchReg
  Gui, add, text, yp+20 xp-140 ,SetReg* mode?
  Gui, add, Checkbox,yp xp+140 vSetReg
  Gui, add, text, yp+20 xp-140 ,Minimize lobby?
  Gui, add, Checkbox,yp xp+140 vMinlob
  Gui, add, Text, xp-140 yp+30, Times to scroll down:
  Gui, add, DropDownList, w50 yp-5 xp+140 vscrldwn, %ddlist7%
  Gui, add, Text, xp-140 yp+25, Always start at top of lobby?
  Gui, add, Checkbox, yp xp+140 vTopReturn
  Gui, show, w256, %thisahk%
  WinGetPos, x, y, w, h, SFSO
  ;x:=monRight-w
  ;y:=monBottom-h
  x:=monLeft
  y:=monTop
  Gosub, GetIni
  Gui, show, x%x% y%y%, %thisahk%
Return

reset:
  RegSofar:=0
  OpenTables:=0
  GuiControl, , OpenTables, Tables open/waiting: %OpenTables%
  GuiControl, , RegSofar, SNG:s registered so far: %RegSofar%
  Gui, Submit, NoHide
return

deletelog:
  ifwinnotexist,ahk_class GLFW30
    filedelete,%logfile%
return

getgui:
  GuiControl,, Register, -1
  Register = 1
  Gui, Submit, NoHide
  displayedTime=
  If (lobby="Default")
  {
    regButton:=defaultregbutton
  }
  Else If (lobby="Black" or lobby="Custom*")
  {
    regButton:=customregbutton
  }
  Gosub, MakeIni
  PausedTime:=LimitTime
  Gosub, TimeLimit
  interval:=interval1*1000
  If interval is not Number
    interval=off
  If guardtimer is not Number
  {
    SetTimer, safeguard, off
  }
  Else
  {
    killtime:=guardtimer*60000
    SetTimer, safeguard, 1000
  }
  if CloseInterv is not number
    SetTimer, NukeLobbies, off
  else
  {
    lobclose:=CloseInterv*1000
    SetTimer, NukeLobbies, %lobclose%
  }
  register=1
  sleep,-1
  Gosub, ButtonResume
Return

Safeguard:
  If (A_TimeIdle > killtime)
  {
    Gosub, ButtonPause
    GuiControl, , cdown, Stopped due to inactivity!!! %displayedTime%
  }
Return

TimeLimit:
  If LimitTime is Number
  {
    allowedMinutes := LimitTime
    endTime := A_Now
    endTime += %allowedMinutes%, Minutes
    SetTimer, CountDown, 1000
  }
  Else
  {
    SetTimer, CountDown, off
    sleep,-1
    GuiControl, , cdown, Time Limit off
  }
Return

Countdown:
  remainingTime := endTime
  EnvSub remainingTime, %A_Now%, Seconds
  m := remainingTime // 60
  s := Mod(remainingTime, 60)
  displayedTime := Format3Digits(m) ":" Format2Digits(s)
  GuiControl, , cdown, Running another (mm:ss): %displayedTime%
  If (A_now > endTime)
  {
    SetTimer, Countdown, off
    Gosub, ButtonPause
    GuiControl, , cdown, Time Limit reached.
  }
Return

GuiClose:
  Gui, Submit
  Gosub, MakeIni
ExitApp
Return

ButtonResume:
  Gui, Submit, NoHide
  GuiControl, Disable, &Resume
  GuiControl, Enable, &Pause
  if LimitTime is Number
    If PausedTime is Number
    LimitTime:=PausedTime
  Gosub, TimeLimit
  GuiControl, , Register, -1
  Register:=1
  SetTitleMatchMode, 2
  WinGet, LobbyID, id, PokerStars Lobby,,Tournament
  ;regbutton:=regbutton()
  settimer, AutoReg,37
  OpenTables:=0
  tables=
  OpenTables:=CountTourneys(1)
  Gosub,Register
  SetTimer, Register, %Interval%
  sleep,-1
Return

ButtonPause:
  Critical
  Gui, Submit, NoHide
  if LimitTime is Number
    PausedTime:=remainingTime/60
  Register:=0
  settimer, AutoReg,off
  SetTimer, Countdown, off
  SetTimer, Register, off
  GuiControl, Disable, Pause
  GuiControl, Enable, Resume
  GuiControl, , Register, 0
  GuiControl, , cdown, Manually Paused %displayedTime%
  GuiControl, , Status, Status: Waiting ;TEST
Return

Register:
  SetTitleMatchMode, 2
  WinGet, LobbyID, id, PokerStars Lobby,,Tournament
  If !LobbyID
  {
    Gosub, ButtonPause
    GuiControl,, Status, Status: PokerStars Lobby not found
    Gui, show, NoActivate, %thisahk%
    Return
  }
  If (TopReturn=1)
  {
    ControlGet,vis,visible,,%PS7list1%,ahk_id%lobbyid%
    if vis
      list:=PS7list1
    else
      list:=PS7list2
    ControlSend, %list%, {Blind}{NumpadUp 20}, ahk_id%lobbyid%
  }
  WinGet, PhysicalTables, list,Table ahk_class GLFW30
  If PhysicalTables is not Number
    PhysicalTables:=0
  If (PhysicalTables >= KeepOpen)
  {
    GuiControl,, Status, Set Full waiting
    Return
  }
  OpenTables:=CountTourneys()
  If OpenTables is not Number
    OpenTables:=0
  GuiControl, , OpenTables, Tables open/waiting: %OpenTables%
  GuiControl, , RegSofar, SNG:s registered so far: %RegSofar%
  If (RegSofar >= TotalLimit)
  {
    Gosub, ButtonPause
    GuiControl, , cdown, SNG Total Limit reached
    GuiControl, , Status, Status: Idle ;TEST
    Return
  }
  If (OpenTables >= TotalLimit)
  {
    Gosub, ButtonPause
    GuiControl, , cdown, SNG Total Limit reached
    GuiControl, , Status, Status: Idle ;TEST
    Return
  }
  If (OpenTables>=KeepOpen)
  {
    GuiControl, , OpenTables, Tables open/waiting: %OpenTables% (Set full)
    GuiControl, , Status, Status: Waiting ;TEST
    Return
  }
  Else
  {
    If (BatchReg=1)
    {
      Times:= KeepOpen - OpenTables
      RegSNGexec(LobbyID, Times, scrldwn)
    }
    Else
    {
      RegSNGexec(LobbyID, 1, scrldwn)
    }
  }
Return

MakeIni:
  IniWrite, %AutoIfFull%, %thisahk%.ini, Settings, AutoIfFull
  IniWrite, %TopReturn%, %thisahk%.ini, Settings, TopReturn
  IniWrite, %scrldwn%, %thisahk%.ini, Settings, scrldwn
  IniWrite, %Lobby%, %thisahk%.ini, Settings, Lobby
  IniWrite, %BatchReg%, %thisahk%.ini, Settings, BatchReg
  IniWrite, %Setreg%, %thisahk%.ini, Settings, SetReg
  IniWrite, %Minlob%, %thisahk%.ini, Settings, MinLob
  IniWrite, %Interval1%, %thisahk%.ini, Settings, Interval1
  IniWrite, %CloseInterv%, %thisahk%.ini, Settings, CloseInterv
  IniWrite, %KeepOpen%, %thisahk%.ini, Settings, KeepOpen
  IniWrite, %TotalLimit%, %thisahk%.ini, Settings, TotalLimit
  IniWrite, %GuardTimer%, %thisahk%.ini, Settings, GuardTimer
  IniWrite, %LimitTime%, %thisahk%.ini, Settings, LimitTime
Return

GetIni:
  IfExist, %thisahk%.ini
  {
    IniRead, AutoIfFull, %thisahk%.ini, Settings, AutoIfFull
    IniRead, TopReturn, %thisahk%.ini, Settings, TopReturn,0
    IniRead, scrldwn, %thisahk%.ini, Settings, scrldwn
    IniRead, Lobby, %thisahk%.ini, Settings, Lobby
    IniRead, BatchReg, %thisahk%.ini, Settings, BatchReg
    IniRead, SetReg, %thisahk%.ini, Settings, SetReg, 1
    IniRead, MinLob, %thisahk%.ini, Settings, MinLob, 0
    IniRead, Interval1, %thisahk%.ini, Settings, Interval1
    IniRead, CloseInterv, %thisahk%.ini, Settings, CloseInterv
    IniRead, KeepOpen, %thisahk%.ini, Settings, KeepOpen
    IniRead, TotalLimit, %thisahk%.ini, Settings, TotalLimit
    IniRead, GuardTimer, %thisahk%.ini, Settings, GuardTimer, Off
    IniRead, LimitTime, %thisahk%.ini, Settings, LimitTime, Off
    GuiControl, , AutoIfFull, %AutoIfFull%
    StringReplace, ddlist7, ddlist7, %scrldwn%, %scrldwn%|
    GuiControl, , scrldwn, |%ddlist7%
    StringReplace, LobbyList, LobbyList, %Lobby%, %Lobby%|
    GuiControl, , Lobby, |%LobbyList%
    GuiControl, , BatchReg, %BatchReg%
    GuiControl, , SetReg, %SetReg%
    GuiControl, , MinLob, %MinLob%
    GuiControl, , TopReturn, %TopReturn%
    StringReplace, ddlist2, ddlist2, %interval1%, %Interval1%|
    GuiControl, , Interval1, |%ddlist2%
    StringReplace, ddlist6, ddlist6, %CloseInterv%, %CloseInterv%|
    GuiControl, , CloseInterv, |%ddlist6%
    StringReplace, ddlist, ddlist, %KeepOpen%, %KeepOpen%|
    GuiControl, , KeepOpen, |%ddlist%
    StringReplace, ddlist3, ddlist3, %TotalLimit%, %TotalLimit%|,
    GuiControl, , TotalLimit, |%ddlist3%
    StringReplace, ddlist4, ddlist4, %GuardTimer%, %GuardTimer%|
    GuiControl, , GuardTimer, |%ddlist4%
    StringReplace, ddlist5, ddlist5, %LimitTime%, %LimitTime%|
    GuiControl, , LimitTime, |%ddlist5%
  }
Return

#e::
  gosub,NukeLobbies
Return

NukeLobbies:
  SetTitleMatchMode, 2
  GroupAdd, TLobbies, Lobby ahk_class GLFW30,,, PokerStars Lobby
  GroupClose, TLobbies, A
Return

#H::
  WinHide, %thisahk%
return

#S::
  WinShow, %thisahk%
return

Format2Digits(_val) {
  _val :=Round(_val) + 100
  StringRight _val, _val, 2
Return _val
}

Format3Digits(_val) {
  _val :=Round(_val) + 1000
  StringRight _val, _val, 3
  StringTrimRight, FirstZ, _val, 2
  If FirstZ=0
  {
    StringTrimLeft, _val, _val, 1
  }
  StringTrimRight, FirstZ, _val, 1
  If FirstZ=0
  {
    StringTrimLeft, _val, _val, 1
  }
Return _val
}

LobbyRestore:
  WinGet, lobbyid, id, PokerStars Lobby
  WinShow, ahk_id%lobbyid%
  WinMove, ahk_id%lobbyid%,,0,0
return

RegSNGexec(id, times, scrldwn) {
  global RegSofar
  global Register
  global OpenTables
  global KeepOpen
  global TotalLimit
  ;global RegButton
  global AutoIfFull
  global list,lobbytitle,lobbyid,PS7list1,PS7list2

  Loop %times%
  {
    ControlGet,vis,visible,,%PS7list1%,ahk_id%lobbyid%
    if vis
      list:=PS7list1
    else
      list:=PS7list2
    ControlSend, %list%, {Blind}{NumpadUp 20}, ahk_id%id%
    If (OpenTables >= KeepOpen)
      Exit
    If (OpenTables >= TotalLimit)
      Exit
    ClickdirectionCount=0
    direction=0
    GuiControl, , Status, Status: Registering ;TEST
    Loop 16
    {
      If (Register=0)
      {
        GuiControl, , Status, Status: Idle ;TEST
        Exit
      }

      if regbutton:=regbutton()
        ControlGet, v, Visible, , %regButton%, ahk_id%id%
      else
        v:=0

      If (v = 0)
        If (scrldwn!="Off")
      {
        If (ClickdirectionCount<scrldwn) {
          ControlGet,vis,visible,,%PS7list1%,ahk_id%lobbyid%
          if vis
            list:=PS7list1
          else
            list:=PS7list2
          If (direction=0) {
            ControlSend, %list%, {Blind}{NumpadDown}, ahk_id%id%
          } Else {
            ControlSend, %list%, {Blind}{NumpadUp}, ahk_id%id%
          }
          ClickdirectionCount:=ClickdirectionCount+1
        } Else {
          If (direction=0) {
            direction:=1
          } Else {
            direction:=0
          }
          ClickdirectionCount:=0
        }
        Sleep,1000
      }
      If ( v = 1 ) {
        wingetclass,class,A
        SetTitleMatchMode, 2
        ControlSend, %regButton%, {Blind}{Space}, ahk_id%id%
        ;ControlSend, %regButton%, {Blind}{Space}, ahk_id%id%
        WinWait, Tournament Registration ahk_class #32770,,1
        {
          WinGet, regid, id, Tournament Registration ahk_class #32770
          wingettext,text,
          if instr(text,"Confirm")>0
          {
            autobtn=PokerStarsButtonClass3
            okbtn=PokerStarsButtonClass2
          }
          else
          {
            autobtn=Button2
            okbtn=PokerStarsButtonClass1
          }
          controlget,vis,visible,,%autobtn%,ahk_id%regid%
          if vis
          {
            If (AutoIfFull = 1)
            {
              Control,Check,,%autobtn%, ahk_id%regid%
              ;ControlSend, %autobtn%, {Blind}{Space}, ahk_id%regid%
              Sleep, 30
            }
            ControlSend, %okbtn%, {Blind}{Space}, ahk_id%regid%
          }
        }
        sleep,30
        WinWait, Tournament Registration ahk_class #32770,,1
        {
          WinGet, regid, id, Tournament Registration ahk_class #32770
          controlget,vis,visible,,Button2,ahk_id%regid%
          controlget,vis1,visible,,PokerStarsButtonClass3,ahk_id%regid%
          if !vis && !vis1
            winclose,ahk_id%regid%
          ;ControlSend, PokerStarsButtonClass1, {Blind}{Space}, ahk_id%regid%
        }
        GuiControl, , Status, Status: Waiting ;TEST
        ;if class=GLFW30
        ;winactivate,ahk_class GLFW30
        Break
      }
    }
  }
}
return

AutoReg:
  AutoReg()
return

AutoReg()
{
  global AutoIfFull
  setwindelay,-1
  settitlematchmode,2
  IfWinExist, Tournament Registration ahk_class #32770
  {
    wingettext,text,
    if instr(text,"Confirm")>0
    {
      autobtn=PokerStarsButtonClass3
      okbtn=PokerStarsButtonClass2
    }
    else
    {
      autobtn=Button2
      okbtn=PokerStarsButtonClass1
    }
    winget,id,id,
    controlget,vis,visible,,%autobtn%,ahk_id%id%
    if vis
    {
      If (AutoIfFull = 1)
      {
        ControlFocus, %autobtn%, ahk_id%id%
        Sleep, -1
        ControlSend, %autobtn%, {Blind}{Space}, ahk_id%id%
        Sleep, 30
      }
      ControlSend, %okbtn%, {Blind}{Space}, ahk_id%id%
    }
    else
      ControlSend, %okbtn%, {Blind}{Space}, ahk_id%id%
    ;winclose,ahk_id%id%
  }
}
return

CountTourneys(mode=0) {
  global logfile,RegSofar,regtourneys,tables,Targetnum
  If (SetReg=1)
    Return 0
  log := CheckFile(logfile,mode)

  Loop, Parse, log, `n,
  {
    tnumber=
    if (instr(A_loopField,"RT add")>0)
    {
      if instr(A_loopField,"=")>0
        StringtrimLeft, tnumber, A_loopField, instr(A_loopField,A_space,"",instr(A_loopField,"="))
      else
        tnumber:=A_loopField
      tnumber:=RegExReplace(tnumber, "[`n,`r,']", "")
      tnumber:=RegExReplace(tnumber, "RT add ", "")

      if instr(tnumber,A_space)>0
        StringLeft, tnumber, tnumber, instr(tnumber,A_space)-1

      tnumber:=Floor(tnumber)

      if !(instr(tables,tnumber)>0) ;&& ((Targetnum=0) || ((Targetnum>0) && (tnumber>=(Targetnum-50000)) && (tnumber<(Targetnum+150000))))
        listadd(tables,tnumber)
    }
    else
      If (instr(A_loopField,"RT remove")>0)
    {
      if instr(A_loopField,"=")>0
        StringtrimLeft, tnumber, A_loopField, instr(A_loopField,A_space,"",instr(A_loopField,"="))
      else
        tnumber:=A_loopField

      tnumber:=RegExReplace(tnumber, "[`n,`r,']", "")
      tnumber:=RegExReplace(tnumber, "RT remove ", "")

      if instr(tnumber,A_space)>0
        stringleft,tnumber,tnumber,instr(tnumber,A_space)-1

      tnumber:=Floor(tnumber)
      if instr(tables,tnumber)>0
        listDelItem(tables,tnumber)
    }
  }
  log=
  tcount:=0
  Loop, Parse, tables, -,
  {

    if A_Loopfield is number
    {
      tcount++
      if !(instr(regtourneys,A_Loopfield)>0)
      {
        listadd(regtourneys,A_Loopfield)
        if mode=0
          RegSofar++
      }
    }
  }

return tcount
}

numcheck:
  winget,nlist,list,Table ahk_class GLFW30
  loop %nlist%
  {
    id:=nlist%A_index%
    wingettitle,title,ahk_id%id%
    stringtrimleft,num,title,instr(title,A_space,"",instr(title,"Tournament"))
    stringleft,num,num,instr(num,A_space)-1
    if num is not number
      num:=0
    if (num>targetnum)
      targetnum:=num
    StringReplace,targetnum,targetnum,A_space,,All
    StringReplace,targetnum,targetnum,`n,,All
    StringReplace,targetnum,targetnum,`r,,All
  }
return

Ansi2Unicode(sString, CP = 0)
{
  nSize := DllCall("MultiByteToWideChar"
  , "Uint", CP
  , "Uint", 0
  , "Uint", &sString
  , "int", -1
  , "Uint", 0
  , "int", 0)

  VarSetCapacity(wString, nSize * 2)

  DllCall("MultiByteToWideChar"
  , "Uint", CP
  , "Uint", 0
  , "Uint", &sString
  , "int", -1
  , "Uint", &wString
  , "int", nSize)
return wstring
}

ReplaceByte( hayStackAddr, hayStackSize, ByteFrom=0, ByteTo=1, StartOffset=0, NumReps=-1)
{	Static fun
  IfEqual,fun,
  {
    h=
    ( LTrim join
    5589E553515256579C8B4D0C8B451831D229C17E25837D1C00741F8B7D0801C70FB6451
    00FB65D14FCF2AE750D885FFF42FF4D1C740409C975EF9D89D05F5E5A595BC9C21800
    )
    VarSetCapacity(fun,StrLen(h)//2)
    Loop % StrLen(h)//2
    NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
  }
Return DllCall(&fun
, "uint",haystackAddr, "uint",hayStackSize, "short",ByteFrom, "short",ByteTo
, "uint",StartOffset, "int",NumReps)
}

CheckFile(File, mode=0) {
  ; THX Sean for File.ahk : http://www.autohotkey.com/forum/post-124759.html
  Static CF := "" ; Current File
  Static FP := 0 ; File Pointer
  Static OPEN_EXISTING := 3
  Static GENERIC_READ := 0x80000000
  Static FILE_SHARE_READ := 1
  Static FILE_SHARE_WRITE := 2
  Static FILE_SHARE_DELETE := 4
  Static FILE_BEGIN := 0
  BatchLines := A_BatchLines
  SetBatchLines, -1
  If (File != CF) {
    CF := File
    FP := 0
  }
  hFile := DllCall("CreateFile"
  , "Str", File
  , "Uint", GENERIC_READ
  , "Uint", FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE
  , "Uint", 0
  , "Uint", OPEN_EXISTING
  , "Uint", 0
  , "Uint", 0)
  If (!hFile) {
    CF := ""
    FP := 0
    SetBatchLines, %BatchLines%
    Return False
  }
  DllCall("GetFileSizeEx"
  , "Uint", hFile
  , "Int64P", nSize)
  if mode=1
    FP:=1
  If (FP = 0 Or nSize <= FP) {
    FP := nSize
    SetBatchLines, %BatchLines%
    DllCall("CloseHandle", "Uint", hFile) ; close file
    Return False
  }
  DllCall("SetFilePointerEx"
  , "Uint", hFile
  , "Int64", FP
  , "Uint", 0
  , "Uint", FILE_BEGIN)
  VarSetCapacity(Tail, Length := nSize - FP, 0)
  DllCall("ReadFile"
  , "Uint", hFile
  , "Str", Tail
  , "Uint", Length
  , "UintP", Length
  , "Uint", 0)
  DllCall("CloseHandle", "Uint", hFile)
  FP := nSize
  if A_IsUnicode
  {
    tail:=Ansi2Unicode(tail)
    Length:=strlen(tail)
  }
  ReplaceByte(&Tail, Length)
  VarSetCapacity(Tail, -1)
  SetBatchLines, %BatchLines%
Return Tail
}

listAdd( byRef list, item, del="-" ) {
  list:=( list!="" ? ( list . del . item ) : item )
return list
}

listDelItem( byRef list, item, del="-") {
ifEqual, item,, return list
list:=del . list . del
StringReplace, list, list, %del%%item%%del%,%del%,All
StringTrimLeft, list, list, 1
StringTrimRight, list, list, 1
return list
}

lobbyStars() {
  SetTitleMatchMode 2
  WinGet, id, id, PokerStars Lobby ahk_class #32770,,Tournament
Return id
}

regbutton()
{
  WinGet, LobbyID, id, PokerStars Lobby,,Tournament
  WinGet,ctrls,ControlList,ahk_id%LobbyID%
  Loop,Parse,ctrls,`n
  {
    controlgettext,text,%A_LoopField%,ahk_id%LobbyID%
    ;if text=Register
    if (text="Play Now")
    {
      ControlGet,v,Visible,,%A_LoopField%,ahk_id%LobbyID%
      if v
        regButton:=A_LoopField
    }
  }
return regButton
}

exitsub:
  if Targetnum>0
    IniWrite, %Targetnum%, %thisahk%.ini, Settings, Targetnum
  ifwinnotexist,ahk_class GLFW30
    filedelete,%logfile%
exitapp
return