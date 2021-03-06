darklingAvatarType = Type()
sounds = {
  Resource()
}
delayBeforeSound = {0}
playSoundOnDarkling = {false}
local soundLocation, darklingAvatar, darklingAgent
local function FindDarkling()
  while IsNull(darklingAvatar) do
    darklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
    Sleep(0)
  end
  darklingAgent = darklingAvatar:GetAgent()
end
function DarklingJackieConvo()
  FindDarkling()
  darklingAgent:SetBlockVoiceBarks(true, Engine.BLOCK_SOLO)
  for i = 1, #sounds do
    Sleep(delayBeforeSound[i])
    if playSoundOnDarkling[i] == true then
      FindDarkling()
      soundLocation = darklingAvatar:GetAgent()
    else
      soundLocation = gRegion:GetPlayerAvatar()
    end
    if not IsNull(sounds[i]) then
      soundLocation:PlaySpeech(sounds[i], true)
    end
  end
  darklingAgent:SetBlockVoiceBarks(false, Engine.BLOCK_SOLO)
end
