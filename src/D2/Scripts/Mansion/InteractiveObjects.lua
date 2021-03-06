jukeBox = Instance()
jukeBoxSwitchTrackSound = Resource()
jukeBoxTracks = {
  Resource()
}
radios = {
  Instance()
}
radioMusic = Resource()
radioTracks = {
  Resource()
}
newscastAudio = Resource()
radioGain = 3
muteGain = -47
newscastFrequency = 300
triggers = {
  Instance()
}
delay = 0
startOff = true
function JukeBoxNextTrack()
  if _T.gJukeBoxTrackNum + 1 > #jukeBoxTracks then
    _T.gJukeBoxTrackNum = 1
  else
    _T.gJukeBoxTrackNum = _T.gJukeBoxTrackNum + 1
  end
end
function JukeBoxLoop()
  local currentTrack
  local currentTrackNum = 0
  _T.gJukeBoxEnabled = true
  _T.gJukeBoxTrackNum = 1
  currentTrackNum = _T.gJukeBoxTrackNum
  while _T.gJukeBoxEnabled do
    if IsNull(currentTrack) then
      currentTrack = jukeBox:PlaySound(jukeBoxTracks[_T.gJukeBoxTrackNum], false)
    end
    if IsNull(currentTrack) then
      print("PlaySound failed")
      _T.gJukeBoxEnabled = false
    end
    while not IsNull(currentTrack) and currentTrackNum == _T.gJukeBoxTrackNum and _T.gJukeBoxEnabled do
      Sleep(0)
    end
    if not IsNull(currentTrack) then
      currentTrack:Stop(true)
      currentTrack = nil
    end
    if not IsNull(jukeBoxSwitchTrackSound) and _T.gJukeBoxEnabled then
      jukeBox:PlaySound(jukeBoxSwitchTrackSound, true)
    end
    if currentTrackNum ~= _T.gJukeBoxTrackNum then
      currentTrackNum = _T.gJukeBoxTrackNum
    end
    Sleep(0)
  end
end
function DisableJukeBox()
  _T.gJukeBoxEnabled = false
end
local PlayNewscast = function()
  local temp
  Sleep(delay)
  for i = 1, #radios do
    _T.gNewsCast[radios[i]:GetFullName()] = radios[i]:PlaySound(newscastAudio, false)
    if not _T.gRadiosEnabled[radios[i]:GetFullName()] then
      _T.gNewsCast[radios[i]:GetFullName()]:SetGain(muteGain)
    else
      _T.gNewsCast[radios[i]:GetFullName()]:SetGain(radioGain)
      if not IsNull(_T.gSoundInstances[radios[i]:GetFullName()]) then
        _T.gSoundInstances[radios[i]:GetFullName()]:SetGain(muteGain)
      end
    end
  end
  while not IsNull(_T.gNewsCast[radios[1]:GetFullName()]) do
    Sleep(0.5)
  end
  for i = 1, #radios do
    if _T.gRadiosEnabled[radios[i]:GetFullName()] and not IsNull(_T.gSoundInstances[radios[i]:GetFullName()]) then
      _T.gSoundInstances[radios[i]:GetFullName()]:SetGain(radioGain)
    end
  end
end
function RadioLoop()
  _T.gRadiosEnabled = {}
  _T.gSoundInstances = {}
  _T.gNewsCast = {}
  _T.gRadioLoopEnabled = true
  local timeLeft = 5
  local currentTrack = 1
  local newscastPlaying = false
  for i = 1, #radios do
    _T.gSoundInstances[radios[i]:GetFullName()] = radios[i]:PlaySound(radioTracks[currentTrack], false)
    _T.gRadiosEnabled[radios[i]:GetFullName()] = not startOff
    _T.gNewsCast[radios[i]:GetFullName()] = nil
    if startOff then
      _T.gSoundInstances[radios[i]:GetFullName()]:SetGain(muteGain)
    end
  end
  while _T.gRadioLoopEnabled do
    if IsNull(_T.gSoundInstances[radios[1]:GetFullName()]) then
      currentTrack = currentTrack + 1
      if currentTrack > #radioTracks then
        currentTrack = 1
      end
      for i = 1, #radios do
        _T.gSoundInstances[radios[i]:GetFullName()] = radios[i]:PlaySound(radioTracks[currentTrack], false)
        if not _T.gRadiosEnabled[radios[i]:GetFullName()] or newscastPlaying then
          _T.gSoundInstances[radios[i]:GetFullName()]:SetGain(muteGain)
        else
          _T.gSoundInstances[radios[i]:GetFullName()]:SetGain(radioGain)
        end
      end
    end
    Sleep(1)
    timeLeft = timeLeft - 1
    if timeLeft <= 0 and _T.gRadioWasEnabled and not IsNull(newscastAudio) then
      newscastPlaying = true
      timeLeft = newscastFrequency
      PlayNewscast()
      newscastPlaying = false
    elseif timeLeft < 0 then
      timeLeft = 1
    end
  end
end
function DisableRadios()
  _T.gRadioLoopEnabled = false
end
function ToggleRadio()
  local index = radios[1]:GetFullName()
  local sound = _T.gSoundInstances[index]
  local newscast = _T.gNewsCast[index]
  if 1 <= #_T.gNewsCast then
    local newscast = _T.gNewsCast[index]
  end
  _T.gRadiosEnabled[index] = not _T.gRadiosEnabled[index]
  _T.gRadioWasEnabled = _T.gRadiosEnabled[index]
  if not _T.gRadiosEnabled[index] then
    if IsNull(newscast) then
      if not IsNull(sound) then
        sound:SetGain(muteGain)
      end
    else
      newscast:SetGain(muteGain)
    end
  elseif IsNull(newscast) then
    if not IsNull(sound) then
      sound:SetGain(radioGain)
    end
  else
    newscast:SetGain(radioGain)
  end
end
