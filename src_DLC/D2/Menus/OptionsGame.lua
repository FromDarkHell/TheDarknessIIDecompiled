local LIB = require("D2.Menus.SharedLibrary")
d2GameRules = WeakResource()
popupConfirmMovie = WeakResource()
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
demoGameRulesPAX = WeakResource()
turfGameRules = WeakResource()
lobbyGameRules = WeakResource()
hudMovie = WeakResource()
lobbyHUDMovie = WeakResource()
mainMenuMovie = WeakResource()
local mPopupMovie, mPlayerProfile, mProfileSettings
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local itemHints = "/D2/Language/Menu/Options_Game_Hints"
local itemHUD = "/D2/Language/Menu/Options_Game_HUD"
local itemEssenceMessages = "/D2/Language/Menu/Options_Game_EssenceMessages"
local itemSubTitles = "/D2/Language/Menu/Options_Game_SubTitles"
local itemDifficulty = "/D2/Language/Menu/Options_Game_Difficulty"
local itemList = {
  itemHints,
  itemSubTitles,
  itemHUD,
  itemEssenceMessages
}
local itemListDemo = {itemHints}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusHToggle = "/D2/Language/Menu/Shared_HToggle"
local statusDefault = "/D2/Language/Menu/Shared_Defaults"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {
  statusSelect,
  statusHToggle,
  statusDefault,
  statusBack
}
local mMovieInstance, mSelectedItem
local mIsMultiplayer = false
local itemDarklingPersonality = "/D2/Language/Menu/Options_Game_Darkling_Personality"
local itemPersonalityIndex = 5
local mDarklingPersonalityNames
local mOptionListYOffset = 0
local mGameRules
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
function ToggleDifficultyButtonPressed(movie)
  PlaySound(sndSelect)
end
local function PopulateDifficultySettings(movie)
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.EraseItems")
  local toggleB0 = 100
  local toggleB1 = 320
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetAlignment", "center")
  movie:SetVariable("ToggleDifficulty.Button0._x", toggleB0)
  movie:SetVariable("ToggleDifficulty.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetTextLabelCallbackOnPress", "DifficultyTextLabelPressed")
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetButton0PressedCallback", "ToggleDifficultyButtonPressed")
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetButton1PressedCallback", "ToggleDifficultyButtonPressed")
  local difficultyTable = LIB.GetDifficultyTable()
  local d = 1
  if mIsMultiplayer then
    local d2profileData = mPlayerProfile:GetGameSpecificData()
    d = d2profileData:GetHitListDifficulty()
    if mGameRules:IsPlayingMPCampaign() then
      d = d2profileData:GetCampaignDifficulty()
    end
  else
    d = mProfileSettings:Difficulty()
  end
  local difficultyIdx = 0
  for i = 1, #difficultyTable do
    local name = difficultyTable[i].name
    FlashMethod(movie, "ToggleDifficulty.ToggleListClass.AddItem", name)
    if d == difficultyTable[i].difficulty then
      difficultyIdx = i - 1
    end
  end
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetSelected", difficultyIdx)
end
local function PopulateDarklingPersonalities(movie)
  local d2profileData = mPlayerProfile:GetGameSpecificData()
  if d2profileData == nil then
    return
  end
  local mainMenuInstance = gFlashMgr:FindMovie(mainMenuMovie)
  local isVisible = false
  if not mIsMultiplayer and not IsNull(mainMenuInstance) and Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_DARKLING_AND_TALENTS) then
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.EraseItems")
    local toggleB0 = 100
    local toggleB1 = 320
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetAlignment", "center")
    movie:SetVariable("ToggleDarklingPersonality.Button0._x", toggleB0)
    movie:SetVariable("ToggleDarklingPersonality.Button1._x", toggleB1)
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetTextLabelCallbackOnPress", "DarklingPersonalityTextLabelPressed")
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetButton0PressedCallback", "ToggleDifficultyButtonPressed")
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetButton1PressedCallback", "ToggleDifficultyButtonPressed")
    mDarklingPersonalityNames = d2profileData:GetDarklingPersonalities()
    if mDarklingPersonalityNames ~= nil and 1 < #mDarklingPersonalityNames then
      local defaultSelection = d2profileData:GetActiveDarklingPersonality()
      local defaultSelectionIdx = 0
      isVisible = true
      itemList[#itemList + 1] = itemDarklingPersonality
      for i = 1, #mDarklingPersonalityNames do
        FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.AddItem", mDarklingPersonalityNames[i])
        if mDarklingPersonalityNames[i] == defaultSelection then
          defaultSelectionIdx = i - 1
        end
      end
      FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetSelected", defaultSelectionIdx)
    end
  end
  movie:SetVariable("ToggleDarklingPersonality._visible", isVisible)
end
local function UpdateEssenceOption(movie)
  local alpha = 25
  local enabled = false
  if mProfileSettings:HUD() then
    alpha = 100
    enabled = true
  end
  movie:SetVariable("EssenceEnabled.enabled", enabled)
  movie:SetVariable("EssenceEnabled._alpha", alpha)
  movie:SetVariable("OptionList.ButtonLabel4._alpha", alpha)
end
function Initialize(movie)
  mOptionListYOffset = 17
  mMovieInstance = movie
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mProfileSettings = mPlayerProfile:Settings()
  mGameRules = gRegion:GetGameRules()
  if not IsNull(mGameRules) and (mGameRules:IsA(turfGameRules) or mGameRules:IsA(lobbyGameRules)) then
    mIsMultiplayer = true
  else
    mIsMultiplayer = false
  end
  FlashMethod(movie, "Tutorial.CheckBoxClass.SetChecked", mProfileSettings:TutorialEnabled())
  FlashMethod(movie, "SubTitles.CheckBoxClass.SetChecked", mProfileSettings:Subtitles())
  FlashMethod(movie, "HUDEnabled.CheckBoxClass.SetChecked", mProfileSettings:HUD())
  FlashMethod(movie, "EssenceEnabled.CheckBoxClass.SetChecked", mProfileSettings:EssenceMessages())
  movie:SetVariable("Tutorial.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("SubTitles.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("HUDEnabled.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("EssenceEnabled.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_Game_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  if not IsNull(demoGameRulesPAX) and not IsNull(mGameRules) and mGameRules:IsA(demoGameRulesPAX) then
    itemList = itemListDemo
    movie:SetVariable("SubTitles._visible", false)
  end
  local baseY = 3
  movie:SetVariable("ToggleDifficulty._y", baseY + movie:GetVariable("ToggleDifficulty._y"))
  movie:SetVariable("Tutorial._y", baseY + movie:GetVariable("Tutorial._y"))
  movie:SetVariable("SubTitles._y", baseY + movie:GetVariable("SubTitles._y"))
  movie:SetVariable("HUDEnabled._y", baseY + movie:GetVariable("HUDEnabled._y"))
  movie:SetVariable("EssenceEnabled._y", baseY + movie:GetVariable("EssenceEnabled._y"))
  movie:SetVariable("ToggleDarklingPersonality._y", baseY + movie:GetVariable("ToggleDarklingPersonality._y"))
  mSelectedItem = nil
  if mIsMultiplayer and not Engine.GetMatchingService():IsHost() and not IsNull(mGameRules) and not mGameRules:IsPlayingOffline() then
    movie:SetVariable("ToggleDifficulty._visible", false)
    local parentY = 9 + mOptionListYOffset + movie:GetVariable("OptionList._y")
    local buttonIdx = 0
    movie:SetVariable("Tutorial._y", parentY + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", buttonIdx)))
    buttonIdx = buttonIdx + 1
    movie:SetVariable("SubTitles._y", parentY + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", buttonIdx)))
    buttonIdx = buttonIdx + 1
    movie:SetVariable("HUDEnabled._y", parentY + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", buttonIdx)))
    buttonIdx = buttonIdx + 1
    movie:SetVariable("EssenceEnabled._y", parentY + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", buttonIdx)))
    buttonIdx = buttonIdx + 1
    movie:SetVariable("ToggleDarklingPersonality._y", parentY + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", buttonIdx)))
    buttonIdx = buttonIdx + 1
  else
    table.insert(itemList, 1, itemDifficulty)
    PopulateDifficultySettings(movie)
  end
  PopulateDarklingPersonalities(movie)
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect and statusList[i] ~= statusHToggle)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  UpdateEssenceOption(movie)
end
local function ValidateDifficultySelection(movie, default)
  if not mIsMultiplayer then
    local oldDifficulty = mProfileSettings:Difficulty()
    local difficultyTable = LIB.GetDifficultyTable()
    local difficultyIdx = movie:GetVariable("ToggleDifficulty.ToggleListClass.mCurSelection")
    local theDifficulty = difficultyTable[difficultyIdx + 1].difficulty
    if oldDifficulty == 4 and (default or oldDifficulty > theDifficulty) then
      local popupMovie = movie:PushChildMovie(popupConfirmMovie)
      if default then
        FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Options_Game_DifficultyConfirm_Windows", popupItemOk, popupItemCancel, "ConfirmChangeDifficultyDefault")
      else
        FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Options_Game_DifficultyConfirm_Windows", popupItemOk, popupItemCancel, "ConfirmChangeDifficulty")
      end
      return false
    end
  end
  return true
end
local function Back(movie)
  PlaySound(sndBack)
  local gameRules = gRegion:GetGameRules()
  if not mIsMultiplayer or Engine.GetMatchingService():IsHost() or not IsNull(gameRules) and gameRules:IsPlayingOffline() then
    local oldDifficulty = mProfileSettings:Difficulty()
    local difficultyTable = LIB.GetDifficultyTable()
    local difficultyIdx = movie:GetVariable("ToggleDifficulty.ToggleListClass.mCurSelection")
    local theDifficulty = difficultyTable[difficultyIdx + 1].difficulty
    local thisGameRules = gRegion:GetGameRules()
    local d2profileData = mPlayerProfile:GetGameSpecificData()
    if mIsMultiplayer and not IsNull(thisGameRules) and not IsNull(d2profileData) then
      if thisGameRules:IsPlayingMPCampaign() then
        oldDifficulty = d2profileData:GetCampaignDifficulty()
        d2profileData:SetCampaignDifficulty(theDifficulty)
      else
        oldDifficulty = d2profileData:GetHitListDifficulty()
        d2profileData:SetHitListDifficulty(theDifficulty)
      end
    else
      mPlayerProfile:Settings():SetDifficulty(theDifficulty)
    end
    local lobbyInstance = gFlashMgr:FindMovie(lobbyHUDMovie)
    if not IsNull(lobbyInstance) then
      lobbyInstance:Execute("SetDifficultyIndex", difficultyIdx + 1)
    end
    if not IsNull(thisGameRules) and thisGameRules:IsA(d2GameRules) then
      local changeAmount = theDifficulty - oldDifficulty
      thisGameRules:SetDifficulty(changeAmount)
    end
    local d2profileData = mPlayerProfile:GetGameSpecificData()
    if not IsNull(mDarklingPersonalityNames) then
      local personalityIdx = tonumber(movie:GetVariable("ToggleDarklingPersonality.ToggleListClass.mCurSelection"))
      if not IsNull(mDarklingPersonalityNames[personalityIdx + 1]) then
        d2profileData:SetActiveDarklingPersonality(mDarklingPersonalityNames[personalityIdx + 1])
      end
    end
  end
  local r = gFlashMgr:FindMovie(hudMovie)
  if not IsNull(r) then
    r:Execute("NotifyGameSettingsChange", "")
  end
  mMovieInstance:Close()
end
local function SetDefaults(movie)
  mProfileSettings:SetGameDefaults()
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.SetSelected", mProfileSettings:Difficulty())
  FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.SetSelected", 0)
  FlashMethod(movie, "Tutorial.CheckBoxClass.SetChecked", mProfileSettings:TutorialEnabled())
  FlashMethod(movie, "SubTitles.CheckBoxClass.SetChecked", mProfileSettings:Subtitles())
  FlashMethod(movie, "HUDEnabled.CheckBoxClass.SetChecked", mProfileSettings:HUD())
  UpdateEssenceOption(movie)
  FlashMethod(movie, "EssenceEnabled.CheckBoxClass.SetChecked", mProfileSettings:EssenceMessages())
  PlaySound(sndSelect)
end
function ConfirmChangeDifficultyDefault(movie, args)
  if tonumber(args) == 0 then
    SetDefaults(movie)
  end
end
function ConfirmChangeDifficulty(movie, args)
  if tonumber(args) == 0 then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  if ValidateDifficultySelection(movie, false) then
    Back(movie)
  end
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusDefault then
    if ValidateDifficultySelection(movie, true) then
      SetDefaults(movie)
    end
  elseif statusList[index] == statusBack and ValidateDifficultySelection(movie, false) then
    Back(movie)
  end
end
function onKeyDown_MENU_GENERIC1(movie)
  if ValidateDifficultySelection(movie, true) then
    SetDefaults(movie)
  end
end
local function ToggleTutorial(movie)
  local newState = not mProfileSettings:TutorialEnabled()
  mProfileSettings:SetTutorialEnabled(newState)
  FlashMethod(movie, "Tutorial.CheckBoxClass.SetChecked", newState)
end
local function ToggleHUDEnabled(movie)
  local newState = not mProfileSettings:HUD()
  mProfileSettings:SetHUD(newState)
  FlashMethod(movie, "HUDEnabled.CheckBoxClass.SetChecked", newState)
  UpdateEssenceOption(movie)
end
local function ToggleEssenceEnabled(movie)
  if mProfileSettings:HUD() then
    local newState = not mProfileSettings:EssenceMessages()
    mProfileSettings:SetEssenceMessages(newState)
    FlashMethod(movie, "EssenceEnabled.CheckBoxClass.SetChecked", newState)
  end
end
local function HighlightControl(movie, index, on)
  local clip
  if itemList[index] == itemDifficulty then
    clip = "ToggleDifficulty"
  elseif itemList[index] == itemHints then
    clip = "Tutorial"
  elseif itemList[index] == itemSubTitles then
    clip = "SubTitles"
  elseif itemList[index] == itemHUD then
    clip = "HUDEnabled"
  elseif itemList[index] == itemEssenceMessages then
    clip = "EssenceEnabled"
  elseif itemList[index] == itemDarklingPersonality then
    clip = "ToggleDarklingPersonality"
  end
  if not IsNull(clip) then
    local newColor = 16777215
    if on then
      newColor = LIB.SELECTED_COLOR
    end
    movie:SetVariable(clip .. "._color", newColor)
  end
end
function ListButtonSelected(movie, buttonArg)
  mSelectedItem = tonumber(buttonArg)
  local visible = itemList[mSelectedItem + 1] == itemDifficulty or itemList[mSelectedItem + 1] == itemDarklingPersonality
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusHToggle, visible)
  PlaySound(sndScroll)
  local btn = tonumber(buttonArg) + 1
  HighlightControl(movie, btn, true)
end
function ListButtonUnselected(movie, buttonArg)
  mSelectedItem = nil
  local btn = tonumber(buttonArg) + 1
  HighlightControl(movie, btn, false)
end
local function ToggleSubTitles(movie)
  local newValue = not mProfileSettings:Subtitles()
  mProfileSettings:SetSubtitles(newValue)
  FlashMethod(movie, "SubTitles.CheckBoxClass.SetChecked", newValue)
end
function CheckBoxPressed(movie, cbName)
  PlaySound(sndSelect)
  if cbName == "Tutorial" then
    ToggleTutorial(movie)
  elseif cbName == "SubTitles" then
    ToggleSubTitles(movie)
  elseif cbName == "HUDEnabled" then
    ToggleHUDEnabled(movie)
  elseif cbName == "EssenceEnabled" then
    ToggleEssenceEnabled(movie)
  end
end
local function ChangeDifficulty(movie, dir)
  if mSelectedItem == nil or itemList[mSelectedItem + 1] ~= itemDifficulty then
    return 1
  end
  if dir == 1 then
    FlashMethod(movie, "ToggleDifficulty.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleDifficulty.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  return 1
end
local function ChangeDarklingPersonality(movie, dir)
  if mSelectedItem == nil or itemList[mSelectedItem + 1] ~= itemDarklingPersonality then
    return 1
  end
  if dir == 1 then
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  return 1
end
function DarklingPersonalityTextLabelPressed(movie)
  FlashMethod(movie, "ToggleDarklingPersonality.ToggleListClass.NextItem")
  PlaySound(sndSelect)
end
function DifficultyTextLabelPressed(movie)
  FlashMethod(movie, "ToggleDifficulty.ToggleListClass.NextItem")
  PlaySound(sndSelect)
end
function ListButtonPressed(movie, buttonArg)
  PlaySound(sndSelect)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemHints then
    ToggleTutorial(movie)
  elseif itemList[index] == itemSubTitles then
    ToggleSubTitles(movie)
  elseif itemList[index] == itemHUD then
    ToggleHUDEnabled(movie)
  elseif itemList[index] == itemEssenceMessages then
    ToggleEssenceEnabled(movie)
  elseif itemList[index] == itemDifficulty then
    ChangeDifficulty(movie, 1)
  elseif itemList[index] == itemDarklingPersonality then
    ChangeDarklingPersonality(movie, 1)
  end
end
local function _ToggleSomething(movie, dir)
  if mSelectedItem == nil or itemList[mSelectedItem + 1] == itemDifficulty then
    ChangeDifficulty(movie, dir)
  elseif itemList[mSelectedItem + 1] == itemDarklingPersonality then
    ChangeDarklingPersonality(movie, dir)
  end
  return true
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return _ToggleSomething(movie, -1)
end
function onKeyDown_MENU_LEFT(movie)
  return _ToggleSomething(movie, -1)
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return _ToggleSomething(movie, 1)
end
function onKeyDown_MENU_RIGHT(movie)
  return _ToggleSomething(movie, 1)
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
