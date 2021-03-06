challengeUnlockedLights = {
  Instance()
}
challengeUnlockedLightColor = Color()
materialOverrideTint = Resource()
lightBulbDeco = Instance()
delay = 0
campaignIntroConversation = Instance()
campaignFinaleConversation = Instance()
campaignFinaleMission = 15
campaignVinnieConvo = Instance()
campaignStartPortCounter = Instance()
campaignMissionPortCounter = Instance()
darknessVoiceTrigger = Instance()
darknessVoiceDelay = 3.5
hitListConversationDelay = 3
hitListMissionSuccessConversations = {
  Instance()
}
hitListMissionFailureConversations = {
  Instance()
}
hitListNewSessionConversations = {
  Instance()
}
banterConversations = {
  Instance()
}
banterConversationDelay = 20
local banterConvoPlayed = false
local _StartRandomConversation = function(convTable, delay, needAvatar)
  if #convTable < 1 then
    print("No hitlist conversations")
    return
  end
  if needAvatar then
    local avatar = gRegion:GetLocalPlayer()
    while IsNull(avatar) do
      Sleep(0.1)
      avatar = gRegion:GetLocalPlayer()
    end
  end
  if 0 < delay then
    Sleep(delay)
  end
  local convIndex = RandomInt(1, #convTable)
  local conversation = convTable[convIndex]
  if not IsNull(conversation) then
    conversation:FirePort("Enable")
  end
  return conversation
end
local _StartScriptTrigger = function(delay, scriptTrigger)
  if 0 < delay then
    Sleep(delay)
  end
  if not IsNull(scriptTrigger) then
    scriptTrigger:FirePort("Execute")
  end
end
function OnMainBranchEnded(object)
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) and gameRules:IsPlayingMPCampaign() then
    _StartScriptTrigger(darknessVoiceDelay, darknessVoiceTrigger)
  end
  if banterConvoPlayed then
    return
  end
  banterConvoPlayed = true
  _StartRandomConversation(banterConversations, banterConversationDelay)
end
function Initialize()
  if delay > 0 then
    Sleep(delay)
  end
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) and gameRules:IsChallengeModeUnlocked() then
    for i = 1, #challengeUnlockedLights do
      local light = challengeUnlockedLights[i]
    end
    if not IsNull(lightBulbDeco) then
    end
  end
  if not IsNull(gameRules) and not gameRules:IsPlayingMPCampaign() and gameRules:IsReturningFromMission() then
    local c
    if gameRules:WasLastMissionSuccess() then
      c = _StartRandomConversation(hitListMissionSuccessConversations, hitListConversationDelay, true)
    else
      c = _StartRandomConversation(hitListMissionFailureConversations, hitListConversationDelay, true)
    end
    if not IsNull(c) then
      ObjectPortHandler(c, "OnMainBranchEnded")
    end
  end
  if not IsNull(gameRules) and gameRules:IsPlayingMPCampaign() then
    local isHost = false
    if Engine.GetMatchingService():IsHost() == true then
      isHost = true
    end
    local isOffline = false
    if IsNull(Engine.GetMatchingService():GetSession()) then
      isOffline = true
    end
    if isHost or isOffline then
      gameRules:SetCanBeginMission(true)
      local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
      if not IsNull(playerProfile) then
        local profileData = playerProfile:GetGameSpecificData()
        if not IsNull(profileData) then
          local curMission = profileData:GetCampaignMissionNum()
          if not IsNull(campaignMissionPortCounter) then
            campaignMissionPortCounter:SetCurrentValue(curMission + 1)
          end
          gameRules:SetCanBeginMission(false)
          gameRules:SetCanInviteFriends(curMission < campaignFinaleMission)
          while not IsNull(campaignStartPortCounter) and 1 > campaignStartPortCounter:GetCurrentValue() do
            Sleep(2)
          end
          if curMission == 0 then
            Sleep(3)
            campaignIntroConversation:FirePort("Enable")
            ObjectPortHandler(campaignIntroConversation, "OnMainBranchEnded")
          end
          if curMission == campaignFinaleMission then
            Sleep(3)
            campaignFinaleConversation:FirePort("Enable")
          end
        end
      end
    else
      while not IsNull(campaignMissionPortCounter) and 1 > campaignMissionPortCounter:GetCurrentValue() do
        Sleep(2)
      end
      local curMission = campaignMissionPortCounter:GetCurrentValue() - 1
      gameRules:SetCanInviteFriends(curMission < campaignFinaleMission)
      while not IsNull(campaignStartPortCounter) and 1 > campaignStartPortCounter:GetCurrentValue() do
        Sleep(2)
      end
      if curMission == 0 then
        Sleep(3)
        campaignIntroConversation:FirePort("Enable")
        ObjectPortHandler(campaignIntroConversation, "OnMainBranchEnded")
      end
      if curMission == campaignFinaleMission then
        Sleep(3)
        campaignFinaleConversation:FirePort("Enable")
      end
    end
  end
  if IsNull(gameRules) then
    _StartRandomConversation(banterConversations, banterConversationDelay)
    _StartScriptTrigger(darknessVoiceDelay, darknessVoiceTrigger)
  end
end
