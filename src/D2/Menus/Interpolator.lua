module((...), package.seeall)
return {
  LINEAR = 1,
  EASE_IN = 2,
  EASE_OUT = 3,
  EASE_IN_ELASTIC = 4,
  EASE_OUT_ELASTIC = 5,
  EASE_IN_BACK = 6,
  EASE_OUT_BACK = 7,
  Update = function(this, movie, delta)
    if IsNull(this.clips) then
      return
    end
    local newValue
    local tDelta = 0
    local proportion = 0
    local howManyClips = #this.clips
    local deleteClip = false
    local callbacks = {}
    local c = 0
    while howManyClips > c do
      c = c + 1
      if this.clips[c].movie == movie then
        if 0 >= this.clips[c].delay then
          deleteClip = false
          tDelta = this.clips[c].delta + delta
          if tDelta >= this.clips[c].duration then
            tDelta = this.clips[c].duration
            deleteClip = true
          end
          this.clips[c].delta = tDelta
          if this.clips[c].duration == 0 then
            proportion = 1
          else
            proportion = this.clips[c].delta / this.clips[c].duration
          end
          if this.clips[c].effect == this.EASE_IN then
            proportion = Pow(proportion, 2)
          elseif this.clips[c].effect == this.EASE_OUT then
            proportion = Pow(proportion, 0.5)
          elseif this.clips[c].effect == this.EASE_IN_ELASTIC then
            proportion = this:EaseInElastic(this.clips[c].delta, this.clips[c].duration)
          elseif this.clips[c].effect == this.EASE_OUT_ELASTIC then
            proportion = this:EaseOutElastic(this.clips[c].delta, this.clips[c].duration)
          elseif this.clips[c].effect == this.EASE_IN_BACK then
            proportion = this:EaseInBack(this.clips[c].delta, this.clips[c].duration)
          elseif this.clips[c].effect == this.EASE_OUT_BACK then
            proportion = this:EaseOutBack(this.clips[c].delta, this.clips[c].duration)
          end
          for a = 1, #this.clips[c].attributes do
            if deleteClip then
              newValue = this.clips[c].newValues[a]
            else
              newValue = Lerp(this.clips[c].oldValues[a], this.clips[c].newValues[a], proportion)
              if this.clips[c].dontRound ~= false then
                newValue = math.floor(newValue)
              end
            end
            this.clips[c].movie:SetVariable(this.clips[c].clip .. "." .. this.clips[c].attributes[a], newValue)
          end
          if deleteClip then
            if not IsNull(this.clips[c].callback) then
              table.insert(callbacks, this.clips[c].callback)
            end
            table.remove(this.clips, c)
            c = c - 1
            howManyClips = howManyClips - 1
          end
        else
          this.clips[c].delay = this.clips[c].delay - delta
        end
      end
    end
    for i, c in pairs(callbacks) do
      c()
    end
  end,
  ClearInterpolations = function(this, movie, clip)
    if IsNull(this.clips) then
      return
    end
    for c = 1, #this.clips do
      if this.clips[c].movie == movie and this.clips[c].clip == clip then
        table.remove(this.clips, c)
        return
      end
    end
  end,
  Interpolate = function(this, movie, clip, effect, attributes, newValues, duration, delay, callback, dontRound)
    if IsNull(this.clips) then
      this.clips = {}
    end
    assert(not IsNull(movie))
    local instance = movie:GetVariable(clip)
    if IsNull(instance) or tostring(instance) == "undefined" then
      print("ERROR: The clip (" .. clip .. ") you tried to interpolate does not exist")
      return
    end
    this:ClearInterpolations(movie, clip)
    local newClip = {}
    newClip.movie = movie
    newClip.clip = clip
    newClip.effect = effect
    newClip.attributes = attributes
    newClip.newValues = newValues
    newClip.dontRound = dontRound
    local oldValues = {}
    local value
    for i, v in pairs(newClip.attributes) do
      value = tonumber(movie:GetVariable(clip .. "." .. v))
      table.insert(oldValues, value)
    end
    newClip.oldValues = oldValues
    newClip.delta = 0
    newClip.duration = duration
    if IsNull(delay) then
      delay = 0
    end
    newClip.delay = delay
    newClip.callback = callback
    table.insert(this.clips, newClip)
  end,
  EaseInElastic = function(this, time, duration)
    local PI = 3.1416
    if time == 0 then
      return 0
    end
    time = Clamp(time / duration, 0, 1)
    if time == 1 then
      return 1
    end
    local period = duration * 0.3
    local s = period / 4
    local amplitude = 1
    return -(amplitude * math.pow(2, 10 * (time - 1)) * math.sin((time - 1) * duration - s) * (2 * PI) / period)
  end,
  EaseOutElastic = function(this, time, duration)
    local PI = 3.1416
    if time == 0 then
      return 0
    end
    time = Clamp(time / duration, 0, 1)
    if time == 1 then
      return 1
    end
    local period = duration * 0.5
    local s = period / 4
    local amplitude = 1
    return amplitude * math.pow(2, -10 * time) * math.sin((time * duration - s) * (2 * PI) / period) + amplitude
  end,
  EaseInBack = function(this, time, duration)
    local s = 1.70158
    time = Clamp(time / duration, 0, 1)
    return time * time * ((s + 1) * time - s)
  end,
  EaseOutBack = function(this, time, duration)
    local s = 1.70158
    time = Clamp(time / duration, 0, 1)
    return (time - 1) * time * ((s + 1) * time + s) + 1
  end
}
