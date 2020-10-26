local LIB = require("D2.Menus.SharedLibrary")
movieOnJoinInviteCompleted = WeakResource()
mainMenuMovie = WeakResource()
pressStartMovie = WeakResource()
searchGamesMovie = WeakResource()
customizeControlsMovie = WeakResource()
local CONFIRMTYPE_INVALID = -1
local CONFIRMTYPE_OKCANCEL = 0
local CONFIRMTYPE_LIST = 1
local OKCANCEL_UNSELECTED = -1
local OKCANCEL_LEFT = 0
local OKCANCEL_RIGHT = 1
local mConfirmType = CONFIRMTYPE_INVALID
local mPlatform, mRollOverStates
local mCloseMovie = true
local mDialogResult, mSelectingDevice, mTransitionInCallback
local mDescription = ""
local mLeftItem = ""
local mRightItem = ""
local mCallback
local mTransitionInComplete = false
local autoAcceptInvite = false
local inviteAcceptedMsg
function SetMovieClose(movie, v)
  mCloseMovie = tonumber(v)
end
function Initialize(movie)
  mTransitionInComplete = false
  mDialogResult = nil
end
local _SetCallback = function(movie, args)
  if not IsNull(args) then
    movie:SetVariable("_root.scriptCallback", args)
  end
end
function SetCallback(movie, args)
  _SetCallback(movie, args)
end
local _SetItemText = function(movie, idx, txt)
  FlashMethod(movie, "SetItemText", idx, txt)
end
function SetItemText(movie, idx, txt)
  _SetItemText(movie, idx, txt)
end
function SetRightItemText(movie, txt)
  mRightItem = txt
  if mTransitionInComplete then
    _SetItemText(movie, 1, txt)
  end
end
function SetLeftItemText(movie, txt)
  mLeftItem = txt
  if mTransitionInComplete then
    _SetItemText(movie, 0, txt)
  end
end
local function _SetDescription(movie, txt)
  local locTxt = movie:GetLocalized(txt)
  local startBracket = string.find(locTxt, "%[")
  local endBracket = string.find(locTxt, "%]", startBracket)
  if startBracket ~= nil and endBracket ~= nil then
    locTxt = string.sub(locTxt, startBracket + 1, endBracket - 1)
  end
  FlashMethod(movie, "SetDescription", locTxt)
  local bodyHeight = tonumber(movie:GetVariable("ItemDescription._height"))
  local descriptionHeight = tonumber(movie:GetVariable("ItemDescription.textHeight"))
  local bodyOriginalY = tonumber(movie:GetVariable("ItemDescription2._y"))
  if not (bodyHeight and descriptionHeight) or not bodyOriginalY then
    return
  end
  if mConfirmType == CONFIRMTYPE_LIST then
    bodyHeight = bodyOriginalY - (tonumber(movie:GetVariable("OptionList.ListClass.numElements")) - 1) * 26
  end
  local newY = math.floor(bodyOriginalY + (bodyHeight - descriptionHeight) / 2) - 12
  movie:SetVariable("ItemDescription._y", newY)
end
function SetDescription(movie, txt)
  _SetDescription(movie, txt)
end
local function _Setup(movie)
  mDialogResult = OKCANCEL_UNSELECTED
  movie:SetVariable("OptionList._visible", false)
  mPlatform = movie:GetVariable("$platform")
  local buttonIconLeft = ""
  local buttonIconRight = ""
  local deviceIconType = gFlashMgr:GetInputDeviceIconType()
  local showConsole = deviceIconType == DIT_XBOX360 or deviceIconType == DIT_PS3 or not LIB.IsPC(movie)
  local customizeControlsInstance = gFlashMgr:FindMovie(customizeControlsMovie)
  if not IsNull(customizeControlsInstance) then
    showConsole = false
  end
  if not showConsole then
    mRollOverStates = true
  else
    mRollOverStates = false
    buttonIconLeft = "<MENU_SELECT>"
    buttonIconRight = "<MENU_CANCEL>"
    movie:SetVariable("ItemL.TxtHolder.Txt.textColor", 16777215)
    movie:SetVariable("ItemR.TxtHolder.Txt.textColor", 16777215)
  end
  FlashMethod(movie, "SetButtonInfo", buttonIconLeft, mRollOverStates, buttonIconRight, mRollOverStates)
  FlashMethod(movie, "Initialize", mConfirmType)
  if mConfirmType ~= CONFIRMTYPE_LIST then
    _SetDescription(movie, mDescription)
    _SetItemText(movie, 0, mLeftItem)
    _SetItemText(movie, 1, mRightItem)
    _SetCallback(movie, mCallback)
    if IsNull(mRightItem) or mRightItem == "" then
      movie:SetVariable("ItemR._visible", false)
    end
    movie:SetFocus("ItemL")
  end
end
function Setup(movie)
  _Setup(movie)
end
function TransitionInComplete(movie)
  mTransitionInComplete = true
  _Setup(movie)
  local parentMovie = movie:GetParent()
  if not IsNull(mTransitionInCallback) and not IsNull(parentMovie) then
    parentMovie:Execute(mTransitionInCallback, "")
  end
end
function ListButtonPressed(movie, buttonArg)
  local parentMovie = movie:GetParent()
  local cblPressed = movie:GetVariable("_root.cblPressed")
  if not IsNull(parentMovie) and cblPressed ~= nil then
    parentMovie:Execute(cblPressed, buttonArg)
  end
end
function ListButtonSelected(movie, buttonArg)
  local parentMovie = movie:GetParent()
  local cblSelected = movie:GetVariable("_root.cblSelected")
  if not IsNull(parentMovie) and cblSelected ~= nil then
    parentMovie:Execute(cblSelected, tonumber(buttonArg))
  end
  movie:SetVariable("_root.buttonArg", buttonArg)
end
function ListButtonUnselected(movie, buttonArg)
  local parentMovie = movie:GetParent()
  local cblUnselected = movie:GetVariable("_root.cblUnselected")
  if not IsNull(parentMovie) and cblUnselected ~= nil then
    parentMovie:Execute(cblUnselected, buttonArg)
  end
end
function CreateList(movie, cblPressed, cblSelected, cblUnselected)
  mConfirmType = CONFIRMTYPE_LIST
  FlashMethod(movie, "Initialize", mConfirmType)
  movie:SetVariable("_root.cblPressed", cblPressed)
  movie:SetVariable("_root.cblSelected", cblSelected)
  movie:SetVariable("_root.cblUnselected", cblUnselected)
  movie:SetVariable("OptionList._visible", true)
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
end
function CreateOkCancel(movie, description, leftItem, rightItem, itemCallback)
  if not IsNull(leftItem) and leftItem ~= "" and leftItem ~= "undefined" or not IsNull(rightItem) and rightItem ~= "" and rightItem ~= "undefined" then
    mConfirmType = CONFIRMTYPE_OKCANCEL
  else
    mConfirmType = CONFIRMTYPE_INVALID
  end
  mDescription = description
  mLeftItem = leftItem
  mRightItem = rightItem
  mCallback = itemCallback
end
function CreateOk(movie, description, leftItem, itemCallback)
  if not IsNull(leftItem) and leftItem ~= "" and leftItem ~= "undefined" then
    mConfirmType = CONFIRMTYPE_OKCANCEL
  else
    mConfirmType = CONFIRMTYPE_INVALID
  end
  mDescription = description
  mLeftItem = leftItem
  mRightItem = ""
  mCallback = itemCallback
end
local function CloseMovie(movie)
  if mCloseMovie then
    movie:ResetButtons()
    movie:ResetAutoRepeat()
    movie:Close()
  end
end
local function NotifyCallback(movie, selection, device)
  local text = ""
  local cookedUI
  if selection == OKCANCEL_LEFT then
    cookedUI = CI_SELECT
    text = movie:GetVariable("ItemL.TxtHolder.Txt.text")
  elseif selection == OKCANCEL_RIGHT then
    cookedUI = CI_CANCEL
    text = movie:GetVariable("ItemR.TxtHolder.Txt.text")
  end
  if mConfirmType == CONFIRMTYPE_OKCANCEL and text == "" then
    return
  end
  if cookedUI ~= nil then
    movie:ProcessDialogBoxCallback(cookedUI)
  end
  local parentMovie = movie:GetParent()
  if parentMovie ~= nil then
    local scriptCallback = movie:GetVariable("_root.scriptCallback")
    parentMovie:Execute(scriptCallback, selection)
  end
  movie:SetVariable("_root.buttonArg", selection)
  if mConfirmType ~= CONFIRMTYPE_INVALID then
    CloseMovie(movie)
  end
end
local function ShowChatDisabledPopup(movie)
  mConfirmType = CONFIRMTYPE_OKCANCEL
  mDescription = "Menu/NoVoicePS3"
  mLeftItem = "/D2/Language/Menu/Confirm_Item_Ok"
  mRightItem = "/D2/Language/Menu/Confirm_Item_Cancel"
  _SetDescription(movie, mDescription)
  _SetItemText(movie, 0, mLeftItem)
  _SetItemText(movie, 1, mRightItem)
  movie:SetFocus("ItemL")
end
local function SetDialogResult(movie, result, device, force)
  if mDialogResult ~= OKCANCEL_UNSELECTED then
    return
  end
  if not force then
    local focusClip = movie:GetFocus()
    if device == nil then
      device = -1
    end
    device = tonumber(device)
    if LIB.IsPCInputDevice(device) and LIB.IsPC(movie) then
      if focusClip == "ItemR" then
        result = OKCANCEL_RIGHT
      elseif focusClip == "ItemL" then
        result = OKCANCEL_LEFT
      else
        return
      end
    end
  end
  mDialogResult = result
  mSelectingDevice = device
  FlashMethod(movie, "gotoAndPlay", "TransitionOut")
end
function TransitionOutComplete(movie)
  NotifyCallback(movie, mDialogResult, mSelectingDevice)
end
function onKeyDown_MENU_SELECT(movie, device)
  if mConfirmType == CONFIRMTYPE_OKCANCEL then
    if LIB.IsPS3(movie) then
      if inviteAcceptedMsg == nil then
        inviteAcceptedMsg = movie:GetLocalized("Menu/InviteAccept")
      end
      if mDescription == inviteAcceptedMsg then
        local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        if not IsNull(profile) and profile:IsOnline() and not profile:IsVoiceAllowed() then
          ShowChatDisabledPopup(movie)
          return false
        end
      end
    end
    SetDialogResult(movie, OKCANCEL_LEFT, device)
  end
end
function onKeyDown_MENU_CANCEL(movie, device)
  if mConfirmType == CONFIRMTYPE_OKCANCEL then
    local searchGamesInstance = gFlashMgr:FindMovie(searchGamesMovie)
    if not IsNull(searchGamesInstance) then
      searchGamesInstance:Execute("RefreshStuff", "")
    end
    SetDialogResult(movie, OKCANCEL_RIGHT, device, true)
  elseif mConfirmType == CONFIRMTYPE_LIST then
    CloseMovie(movie)
  end
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  if mRollOverStates then
    return false
  end
  return true
end
function onKeyDown_MENU_LEFT(movie)
  if mRollOverStates then
    return false
  end
  return true
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  if mRollOverStates then
    return false
  end
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  if mRollOverStates then
    return false
  end
  return true
end
function OnGameEvent(movie, eventName, deviceId)
  print("Confirm Popup: OnGameEvent " .. eventName)
  if eventName == "AutoAcceptInvite" then
    autoAcceptInvite = true
    local pressStartInstance = gFlashMgr:FindMovie(pressStartMovie)
    if not IsNull(pressStartInstance) then
      local args = tostring(deviceId) .. ",1"
      pressStartInstance:Execute("LoginUserForInvite", args)
    else
      Engine.GetMatchingService():JoinSessionByInvite()
    end
  elseif eventName == "OnJoinInviteCompleted" then
    if not IsNull(Engine.GetPlayerProfileMgr():GetPlayerProfile(0)) then
      local profileData = Engine.GetPlayerProfileMgr():GetPlayerProfile(0):GetGameSpecificData()
      if not IsNull(profileData) then
        profileData:SetCharacterId(-1)
      end
    end
    gFlashMgr:SetExclusiveDeviceID(tonumber(deviceId))
    while _T.doingTransition ~= nil and _T.doingTransition == true do
      Sleep(0.1)
    end
    local mainMenuInstance = gFlashMgr:FindMovie(mainMenuMovie)
    if not IsNull(mainMenuInstance) then
      local searchGamesInstance = gFlashMgr:FindMovie(searchGamesMovie)
      if not IsNull(searchGamesInstance) then
        searchGamesInstance:Close()
      end
      Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(true)
      mainMenuInstance:Execute("TransitionToMultiplayer", "")
      movie:Close()
    else
      local pressStartInstance = gFlashMgr:FindMovie(pressStartMovie)
      if not IsNull(pressStartInstance) then
        if not autoAcceptInvite then
          pressStartInstance:Execute("LoginUserForInvite", deviceId)
        elseif IsNull(Engine.GetMatchingService():GetSession()) and not IsNull(Engine.GetMatchingService():GetPartySession()) then
          autoAcceptInvite = false
          pressStartInstance:Execute("TransitionToMainMenu", "")
        end
      elseif not IsNull(Engine.GetPlayerProfileMgr():GetPlayerProfile(0)) and Engine.GetPlayerProfileMgr():GetPlayerProfile(0):IsOnline() and Engine.GetMatchingService():GetState() == 0 then
        print("no game session available for party: returning to frontend to wait with party host")
        Engine.GetMatchingService():DisableSessionReconnect()
        gClient:CancelDisconnect()
        Sleep(0)
        local args = Engine.OpenLevelArgs()
        args:SetLevel("")
        args.gameRules = gClient:GetMainMenuGameRules()
        args:SetMenuMovie(mainMenuMovie:GetResourceName())
        args.hostingMultiplayer = true
        args.migrateServer = false
        Engine.OpenLevel(args)
      end
    end
  end
  return 1
end
function SetTransitionInDoneCallback(movie, callback)
  print("Confirm::SetTransitionInDoneCallback(" .. tostring(callback) .. ")")
  mTransitionInCallback = callback
end
