questToken = Symbol()
function GiveTokenIfNotEnglish()
  local playerAvatar = gRegion:GetPlayerAvatar()
  if not IsEnglish() then
    playerAvatar:SetQuestTokenState(questToken, Engine.QTS_COMPLETE)
  end
end
