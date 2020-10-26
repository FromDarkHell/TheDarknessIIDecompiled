loadToWhite = true
function SetLoadingScreenColor()
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData
  if playerProfile ~= nil and not IsNull(playerProfile) then
    profileData = playerProfile:GetGameSpecificData()
    if profileData ~= nil and not IsNull(profileData) then
      if loadToWhite == true then
        profileData:SetLoadingScreenTint(16777215)
      else
        profileData:SetLoadingScreenTint(0)
      end
    end
  end
end
