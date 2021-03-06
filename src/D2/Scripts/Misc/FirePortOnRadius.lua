origin = Instance()
radius = 5
object = Instance()
objectPortName = String()
function Start()
  if not IsNull(object) then
    local playerAvatar = gRegion:GetPlayerAvatar()
    local d = Distance(playerAvatar:GetPosition(), origin:GetPosition())
    while d > radius do
      d = Distance(playerAvatar:GetPosition(), origin:GetPosition())
      Sleep(0)
    end
    object:FirePort(objectPortName)
  end
end
