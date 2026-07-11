[![Repo on gitgud](https://img.shields.io/badge/repo-gitgud-3D76C2.svg)](https://gitgud.io/ZwerOxotnik/denver)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-6C488A.svg)](https://github.com/ZwerOxotnik/denver)

---

# denver

denver is a simple library to help you play custom waveforms with
[LÖVE](http://love2d.org).\
It currently supports several waveforms:\
sinus, sawtooth, square, triangle, whitenoise, pinknoise, brownnoise.

Notations for [LuaLS](https://github.com/LuaLS/lua-language-server) and [Love api](https://marketplace.visualstudio.com/items?itemName=pixelbyte-studios.pixelbyte-love2d) has been added.

## Installation

Download the repository as a submodule with [git](https://git-scm.com/)
```sh
git submodule add --depth 3 https://gitgud.io/ZwerOxotnik/denver src/lib/denver
```
or
```sh
git submodule add --depth 3 https://github.com/ZwerOxotnik/denver src/lib/denver
```

Then require it in your project like so:
```lua
local denver = require("src.lib.denver.denver")
```

## How it works

```lua
local denver = require("src.lib.denver.denver")

-- play a sinus of 1sec at 440Hz
local sine = denver.get({waveform='sinus', frequency=440, length=1})
love.audio.play(sine)

-- play a F#2 (available os)
local square = denver.get({waveform='square', frequency='F#2', length=1})
love.audio.play(square)

-- to loop the wave, don't specify a length (generates one period-sample)
local saw = denver.get({waveform='sawtooth', frequency=440})
saw:setLooping(true)
love.audio.play(saw)

-- play noise
local noise = denver.get({waveform='whitenoise', length=6})
love.audio.play(noise)
```

## History

* Initially it was created by Nicolas Allemand (repository: https://github.com/superzazu/denver.lua)
* And forked version from https://github.com/gretchycat/denver.lua

## Notes

* Please, read this if you want to be involved in development: https://zweroxotnik.github.io/development/message/
* Examples has been moved and improved: https://gitgud.io/ZwerOxotnik/denver-examples

## Disclaimer

THE WORK IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE WORK OR THE USE OR OTHER DEALINGS IN THE
WORK.

## License

Licensed under the [MIT licence](/LICENSE).
