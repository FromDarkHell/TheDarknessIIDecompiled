phrase = String()
local FindPhraseId = function()
  local VOICEBOX_Phrase_MissionStarted = 37
  local VOICEBOX_Phrase_MissionComplete = 38
  local VOICEBOX_Phrase_MissionVoice_0 = 43
  local VOICEBOX_Phrase_MissionVoice_1 = 44
  local VOICEBOX_Phrase_MissionVoice_2 = 45
  local VOICEBOX_Phrase_MissionVoice_3 = 46
  local VOICEBOX_Phrase_MissionVoice_4 = 47
  local VOICEBOX_Phrase_MissionVoice_5 = 48
  local phraseUpper = string.upper(phrase)
  if phraseUpper == "MISSIONSTART" then
    return VOICEBOX_Phrase_MissionStarted
  elseif phraseUpper == "MISSIONEND" then
    return VOICEBOX_Phrase_MissionComplete
  elseif string.find(phraseUpper, "MISSIONVOICE") == 1 then
    local pos_ = string.find(phraseUpper, "_")
    local b = string.byte(phraseUpper, pos_ + 1)
    return VOICEBOX_Phrase_MissionVoice_0 + string.byte(phraseUpper, pos_ + 1) - 48
  else
    print("Invalid phrase ID specified " .. phrase)
    return -1
  end
end
function PlayPhraseOnInstigator(avatar)
  local phraseId = FindPhraseId()
  if phraseId < 0 then
    return
  end
  avatar:PlayPhrase(phraseId, avatar)
end
function PlayPhraseOnRandomPlayer()
  local phraseId = FindPhraseId()
  if phraseId < 0 then
    return
  end
  local humanPlayers = gRegion:GetHumanPlayers()
  if #humanPlayers == 0 then
    return
  end
  local playerIndex = Random(1, #humanPlayers)
  local player = humanPlayers[playerIndex]
  if not IsNull(player) then
    local avatar = player:GetAvatar()
    if not IsNull(avatar) then
      avatar:PlayPhrase(phraseId, avatar)
    end
  end
end
