hitListConversationDelay = 3
hitListNewSessionConversations = {
  Instance()
}
banterConversations = {
  Instance()
}
banterConversationDelay = 20
local _StartRandomConversation = function(convTable, delay)
  if #convTable < 1 then
    print("No hitlist conversations")
    return
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
function OnMainBranchEnded(object)
  _StartRandomConversation(banterConversations, banterConversationDelay)
end
function StartHitListNewSessionConversation()
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) and not gameRules:IsPlayingMPCampaign() and not gameRules:IsReturningFromMission() and not _T.hitListConvoPlayed then
    local c = _StartRandomConversation(hitListNewSessionConversations, hitListConversationDelay)
    if not IsNull(c) then
      ObjectPortHandler(c, "OnMainBranchEnded")
    end
    _T.hitListConvoPlayed = true
  end
end
