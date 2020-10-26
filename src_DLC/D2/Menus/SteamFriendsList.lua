local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
hudMovie = WeakResource()
lobbyHudMovie = WeakResource()
pauseMovie = WeakResource()
chatMovie = WeakResource()
binkTexture = Resource()
local itemList = {}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {statusSelect, statusBack}
local friendList
local wasHudVisible = false
local wasLobbyVisible = false
local wasPauseVisible = false
function Initialize(movie)
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  local lobbyHudInstance = gFlashMgr:FindMovie(lobbyHudMovie)
  local pauseMenuInstance = gFlashMgr:FindMovie(pauseMovie)
  if hudInstance == nil and lobbyHudInstance == nil and pauseMenuInstance == nil then
    movie:Close()
    return
  end
  local chat = gFlashMgr:FindMovie(chatMovie)
  if not IsNull(chat) then
    movie:Close()
    return
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/SteamFriendsList_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  itemList = {}
  friendList = Engine.GetMatchingService():GetFriendsList()
  if friendList ~= nil then
    for i = 1, #friendList do
      itemList[#itemList + 1] = friendList[i].name
    end
  end
  FlashMethod(movie, "OptionList.ListClass.Clear")
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetLetterSpacing", 2)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonChanged")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  local lobbyHudWasVisibleHack = _T.lobbyHudWasVisibleHack
  local pauseWasVisibleHack = _T.pauseWasVisibleHack
  _T.lobbyHudWasVisibleHack = nil
  if hudInstance ~= nil then
    wasHudVisible = hudInstance:IsVisible()
    hudInstance:SetVisible(false)
  end
  if lobbyHudInstance ~= nil then
    wasLobbyVisible = lobbyHudInstance:IsVisible() or lobbyHudWasVisibleHack
    _T.lobbyHudWasVisibleHack = true
    lobbyHudInstance:SetVisible(false)
  end
  if pauseMenuInstance ~= nil then
    wasPauseVisible = pauseMenuInstance:IsVisible() or pauseWasVisibleHack
    _T.pauseWasVisibleHack = true
    pauseMenuInstance:SetVisible(false)
  end
end
local function Back(movie)
  if not IsNull(gRegionMgr) then
    gRegionMgr:PlaySound(sndBack, Vector(), false)
  end
  movie:Close()
  gRegion:StopVideoTexture(binkTexture)
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  if hudInstance ~= nil and wasHudVisible then
    hudInstance:SetVisible(true)
  end
  hudInstance = gFlashMgr:FindMovie(lobbyHudMovie)
  if hudInstance ~= nil and wasLobbyVisible then
    hudInstance:SetVisible(true)
  end
  hudInstance = gFlashMgr:FindMovie(pauseMovie)
  if hudInstance ~= nil and wasPauseVisible then
    hudInstance:SetVisible(true)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  end
end
function ListButtonChanged(movie, buttonArg)
  if not IsNull(gRegionMgr) then
    gRegionMgr:PlaySound(sndScroll, Vector(), false)
  end
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if not IsNull(gRegionMgr) then
    gRegionMgr:PlaySound(sndScroll, Vector(), false)
  end
  if friendList ~= nil then
    Engine.GetMatchingService():InviteFriend(friendList[index])
  end
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
