rumbleDuration = 1
rumbleStrength = 5
function Start()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  player:PlayForceFeedback(rumbleStrength, rumbleStrength, rumbleDuration)
end
