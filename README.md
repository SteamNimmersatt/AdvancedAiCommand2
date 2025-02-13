# Advanced Ai Command 2 for Arma3

https://steamcommunity.com/sharedfiles/filedetails/?id=3250858334

---

# Development

## Initial setup
* Download [hemtt]([https://www.google.com](https://github.com/BrettMayson/HEMTT/releases)) and place it in the root directory of the git repository.
* Subscribe to the development mods listed in file "hemtt/launch.toml", section "workshop".

## Building the mod
* Run "hemtt dev" (Windows: "hemtt.exe dev") to create a dev build.
* Run "hemtt release" to create a signed release build.
* See the [full hemtt documentation](https://hemtt.dev/) for more information.


## Editing code while Arma3 is running
* Run the game via "hemtt launch" (Windows: "hemtt.exe launch")
  * This will create a symbolic link in the Arma3 game directory to the source code of the git repository.
  * It will build the mod and run the game as defined in "hemtt/launch.toml".
* After a code change you need to restart the mission to see the change.
  * You need to restart the game if you've added any files. You will also need to restart in some other special cases like new addon settings.

---

The MIT License (MIT)

Copyright (c) 2016 Seth Duda

Copyright (c) 2024 Nimmersatt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
