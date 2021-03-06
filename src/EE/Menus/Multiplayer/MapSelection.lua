local multiplayerLevels
function Initialize(movie)
  FlashMethod(movie, "InitScreen", "/EE_Menus/MapSelection_Title")
  multiplayerLevels = gGameConfig:GetMultiplayerLevels()
  if multiplayerLevels ~= nil then
    for i = 1, #multiplayerLevels do
      local curLevel = multiplayerLevels[i]
      local result = movie:GetLocalized(curLevel:GetResourceName())
      FlashMethod(movie, "OptionList.ListClass.AddItem", result, true)
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetTitle", "/EE_Menus/MapSelection_ListTitle")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local hostSettings = profileSettings:GetHostSettings()
  local selectedMapName = multiplayerLevels[index]:GetResourceName()
  hostSettings:SetMap(selectedMapName)
  profileSettings:SetHostSettings(hostSettings)
  movie:GetParent():Execute("DisplayGameInfo", "")
  movie:Close()
end
function onKeyDown_MENU_CANCEL(movie)
  movie:Close()
end
