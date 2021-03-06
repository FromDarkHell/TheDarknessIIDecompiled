function Initialize(movie)
  FlashMethod(movie, "InitScreen", "/EE_Menus/GameRulesSelection_Title")
  local gameRules = gGameConfig:GetMultiplayerGameRules()
  if gameRules ~= nil then
    for i = 1, #gameRules do
      local result = gameRules[i].mFriendlyName
      FlashMethod(movie, "OptionList.ListClass.AddItem", result, true)
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local hostSettings = profileSettings:GetHostSettings()
  hostSettings.gameModeId = index
  profileSettings:SetHostSettings(hostSettings)
  movie:GetParent():Execute("DisplayGameInfo", "")
  movie:Close()
end
function onKeyDown_MENU_CANCEL(movie)
  movie:Close()
end
