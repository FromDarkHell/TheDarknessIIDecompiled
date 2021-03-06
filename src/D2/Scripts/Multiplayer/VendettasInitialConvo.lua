conversation = Instance()
delay = 0
vinnieSpawnPoint = Instance()
function StartConversation()
  if delay > 0 then
    Sleep(delay)
  end
  if IsNull(conversation) then
    print("VendettasInitialConvo.lua: conversation instance was nil! This conversation will never, ever start. Ever.")
    return
  end
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(playerProfile) then
    local profileData = playerProfile:GetGameSpecificData()
    if not IsNull(profileData) then
      local curMission = profileData:GetCampaignMissionNum()
      if curMission == 0 then
        conversation:FirePort("Enable")
        if not IsNull(vinnieSpawnPoint) then
          vinnieSpawnPoint:FirePort("Start Script")
        end
      end
    end
  end
end
