token = Symbol()
tokenName = String()
function AddToken()
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:AddToken(token, tokenName)
end
function SetToken()
end
function RemoveToken()
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:RemoveToken(token)
end
function RemoveQuestToken()
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:RemoveQuestToken(token)
end
