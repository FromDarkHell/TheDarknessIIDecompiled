local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
sndTime = Resource()
lobbyGameRules = WeakResource()
turfGameRules = WeakResource()
local mMovieInstance
local WAITSTATE_Idle = 0
local WAITSTATE_PreInputWait = 0.1
local WAITSTATE_InputWait = 2
local mStatusBack = "/D2/Language/Menu/Shared_Back"
local mStatusList = {mStatusBack}
local mKeyBinding = {
  action = "",
  loc = "",
  preText = "",
  postText = "",
  isReadyOnly = false,
  keyList = "",
  gridKeys = {}
}
local mKeyBindings = {}
local mKeyLabels = {}
local mIsMultiplayer = false
local mBindings = {
  input = {}
}
local mPlatform = ""
function ListButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg)
  gRegion:PlaySound(sndScroll, Vector(), false)
end
local function UpdateKeyBindingLayout(movie)
  for i = 1, #mKeyBindings do
    local thisLoc = mKeyBindings[i].loc
    local thisAction = mKeyBindings[i].action
    if thisAction == nil then
    else
      local theBindings = gFlashMgr:GetBindingsForAction(thisAction, true)
      if theBindings == nil then
      else
        local tokenList = LIB.StringTokenize(theBindings, " ")
        if #tokenList == 0 then
        else
          for j = 1, #tokenList do
            local thisToken = tokenList[j]
            if string.find(thisToken, "GAMEPAD") == nil then
            else
              local paramList = LIB.StringTokenize(thisToken, ":")
              if 1 < #paramList then
                thisToken = paramList[1]
                local postCommandParams = mKeyBindings[i].post
                local hasParams = false
                for k = 2, #paramList do
                  if paramList[k] == postCommandParams then
                    hasParams = true
                  end
                end
                if postCommandParams ~= "" and not hasParams then
              end
              else
                local mcName = string.format("%sLabel.%s_Text.text", mPlatform, thisToken)
                local locID = string.format("/D2/Language/Menu/Action_%s", thisLoc)
                if mIsMultiplayer and thisLoc == "POWER_HELD" then
                  movie:SetVariable(string.format("%sBLine._visible", mPlatform), false)
                  locID = ""
                end
                movie:SetLocalized(mcName, locID)
              end
            end
          end
        end
      end
    end
  end
end
function Initialize(movie)
  mMovieInstance = movie
  mPlatform = movie:GetVariable("$platform")
  if LIB.IsPC(movie) then
    mPlatform = "XBOX360"
  end
  mIsMultiplayer = false
  if Engine.GetMatchingService():GetState() ~= 0 then
    mIsMultiplayer = true
  end
  local gm = gRegion:GetGameRules()
  if not IsNull(gm) and (gm:IsA(lobbyGameRules) or gm:IsA(turfGameRules)) then
    mIsMultiplayer = true
  end
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_Z",
    loc = "WALK_FORWARD",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_Z",
    loc = "WALK_BACKWARD",
    pre = "",
    post = "INVERT=1"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_X",
    loc = "STRAFE",
    pre = "",
    post = "INVERT=1"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_X",
    loc = "STRAFE",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "PRE_ATTACK",
    loc = "PRE_ATTACK",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "ACTION",
    loc = "ACTION",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "AIM_WEAPON",
    loc = "AIM_WEAPON",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MELEE",
    loc = "MELEE",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "USE",
    loc = "USE",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "CONTEXT_POWER",
    loc = "CONTEXT_POWER",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "POWER_HELD",
    loc = "POWER_HELD",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "JUMP",
    loc = "JUMP",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "CROUCH",
    loc = "CROUCH",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "RUN",
    loc = "RUN",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "UBER_ATTACK",
    loc = "UBER_ATTACK",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "LOOK_X",
    loc = "LOOK_X",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MINI_INVENTORY",
    loc = "CHANGE_WEAPON",
    pre = "",
    post = ""
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "SHOW_PAUSE_MENU",
    loc = "SHOW_PAUSE_MENU",
    pre = "",
    post = ""
  }
  local ps3Vis = false
  local xboxVis = false
  if LIB.IsPS3(movie) then
    ps3Vis = true
  elseif LIB.IsXbox360(movie) or LIB.IsPC(movie) then
    xboxVis = true
  end
  local isConsole = ps3Vis or xboxVis
  movie:SetVariable("PS3Image._visible", ps3Vis)
  movie:SetVariable("PS3Label._visible", ps3Vis)
  movie:SetVariable("PS3BLine._visible", ps3Vis)
  movie:SetVariable("XBOX360Image._visible", xboxVis)
  movie:SetVariable("XBOX360Label._visible", xboxVis)
  movie:SetVariable("XBOX360BLine._visible", xboxVis)
  UpdateKeyBindingLayout(movie)
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/ControllerLayout_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  local locFmt = movie:GetLocalized("/D2/Language/Menu/ControllerLayout_Layout")
  local numLayouts = 1
  movie:SetVariable("OptionList._visible", false)
  for i = 1, #mStatusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", mStatusList[i], true)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
local function Back(movie)
  gRegion:PlaySound(sndBack, Vector(), false)
  mMovieInstance:Close()
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if mStatusList[index] == mStatusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_LEFT(movie)
  return 1
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_RIGHT(movie)
  return 1
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_UP(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
