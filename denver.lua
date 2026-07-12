---@class denver
local denver = {
    _VERSION         = 'denver v1.0.7',
    _DESCRIPTION    = 'An audio generation module for LÖVE2D',
    _URL            = 'http://github.com/superzazu/denver.lua',
    _LICENSE        = [[
Copyright (c) 2014-2016 Nicolas Allemand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
}

denver.rate = 44100
denver.bits = 16
denver.channel = 1
denver.base_freq = 440 -- A4 = 440


---@alias denver.waveforms "sinus"|"sawtooth"|"square"|"triangle"|"whitenoise"|"pinknoise"|"brownnoise"
---@alias denver.notes "C"|"D"|"E"|"F"|"G"|"A"|"B"

---@class denver.args
---@field frequency string|integer? # 440 by default
---@field waveform denver.waveforms? # "sinus" by default
---@field volume number?
---@field length number?


local pi = math.pi
local sin = math.sin
local floor = math.floor
local random = math.random


local oscillators = {}


-- Returns a LOVE2D audio source with a waveform
--
-- Examples:
-- ```lua
--    s = denver.get({waveform='sinus', frequency=440, length=1})
--    s = denver.get{waveform='square', frequency='E#3'}
-- ```
-- Note: creates one period-sample by default; that allows user to loop the
--       sample (and to have a minimum of RAM used)
---@param args denver.args
---@param ... any
---@return love.Source, love.SoundData
function denver.get(args, ...)
    local waveform  = args.waveform or 'sinus'
    local frequency = args.frequency
    frequency = denver.noteToFrequency(frequency)
                      or frequency or 440
    local length = args.length or (1 / frequency)

    local rate = denver.rate
    local channel = denver.channel

    -- creating an empty sample
    local sound_data = love.sound.newSoundData(length * rate,
                                              rate,
                                              denver.bits,
                                              channel)

    -- setting up the oscillator
    if not oscillators[waveform] then
        error('waveform "'.. waveform ..'"" is not supported.', 2)
    end

    -- filling the sample with values
    local amplitude = args.volume or 0.2
    local osc = oscillators[waveform](frequency, ...)
    for i = 0, length * rate - 1 do
        local sample = osc() * amplitude
        sound_data:setSample(i, sample)
    end

    return love.audio.newSource(sound_data), sound_data
end

-- Adds your own wave
---@param wave_type string
---@param osc fun(): number
function denver.set(wave_type, osc)
    oscillators[wave_type] = osc
end

local NOTE_SEMITONES = {C=-9, D=-7, E=-5, F=-4, G=-2, A=0, B=2}
-- Takes a note in parameter and returns a frequency
---@param note_str string|number?
function denver.noteToFrequency(note_str)
    if not note_str or type(note_str) ~= 'string' then
        return
    end

    local semitones = NOTE_SEMITONES[note_str:sub(1, 1)]
    local octave = 4
    -- local alteration = 0

    if #note_str == 2 then
        ---@diagnostic disable-next-line: cast-local-type
        octave = tonumber(note_str:sub(2, 2))
    elseif #note_str == 3 then -- # or flat
        local step_symbol = note_str:sub(2, 2)
        if step_symbol == '#' then
            semitones = semitones + 1
        elseif step_symbol == 'b' then
            semitones = semitones - 1
        end
        ---@diagnostic disable-next-line: cast-local-type
        octave = tonumber(note_str:sub(3, 3))
    end

    semitones = semitones + 12 * (octave - 4)

    return denver.base_freq * (2^(1 / 12))^semitones
    -- frequency = root * (2^(1/12))^steps (steps(=semitones) can be negative)
end

-- OSCILLATORS
---@param f number
---@return fun(): number
function oscillators.sinus(f)
    local phase = 0
    return function()
        phase = phase + 2 * pi / denver.rate
        if phase >= 2 * pi then
            phase = phase - 2 * pi
        end
        return sin(f * phase)
    end
end

-- thanks https://github.com/zevv/worp/blob/master/lib/Dsp/Saw.lua
---@param f number
---@return fun(): number
function oscillators.sawtooth(f)
    local dv = 2 * f / denver.rate
    local v = 0
    return function()
        v = v + dv
        if v > 1 then v = v - 2 end
        return v
    end
end

---@param f number
---@param pwm number? # must be between 0 and 1 (0 by default)
---@return fun(): number
function oscillators.square(f, pwm)
    pwm = pwm or 0
    if pwm >= 1 or pwm < 0 then
        error('PWM must be between 0 and 1 (0 <= PWM < 1)', 2)
    end
    local saw = oscillators.sawtooth(f)
    return function()
        return saw() < pwm and -1 or 1
    end
end

---@param f number
---@return fun(): number
function oscillators.triangle(f)
    local dv = 1 / denver.rate
    local v = 0
    local a = 1 -- up or down
    return function()
        v = v + a * dv * 4 * f
        if v > 1 or v < -1 then
            a = a * -1
            v = floor(v+.5)
        end
        return v
    end
end

function oscillators.whitenoise()
    return function()
        return random() * 2 - 1
    end
end

-- https://web.archive.org/web/20170812122914/http://www.musicdsp.org/files/pink.txt
function oscillators.pinknoise()
    local b0, b1, b2, b3, b4, b5, b6 = 0, 0, 0, 0, 0, 0, 0
    return function()
        local white = random() * 2 - 1
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        local pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
        b6 = white * 0.115926;
        return pink * 0.11 -- (roughly) compensate for gain
    end
end

-- thanks http://noisehack.com/generate-noise-web-audio-api/
function oscillators.brownnoise()
    local lastOut = 0
    return function()
        local white = random() * 2 - 1
        local out = (lastOut + (0.02 * white)) / 1.02
        lastOut = out
        return out * 3.5 -- (roughly) compensate for gain
    end
end



-- Denver, the last dinosaur
-- He's my friend and a whole lot more
-- Denver, the last dinosaur
-- Shows me a world I never saw before

-- Everywhere we go we don't really care
-- If people stop and stare at our pal dino.
-- Creating history thru the rock n' roll spotlight
-- We've got a friend who helps us, we can do alright

-- That's Denver, the last dinosaur
-- He's my friend and a whole lot more
-- Denver, the last dinosaur
-- Shows me a world I never saw before.

return denver
