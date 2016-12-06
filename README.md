## gTranslate for Hammerspoon

The magic of Google Cloud Translation while you're typing. Anywhere.

![](http://imgur.com/v7Yuu63.gif)


### Installation

gTranslate is an extension for [Hammerspoon](http://hammerspoon.org/). Once Hammerspoon is installed (see [install Hammerspoon](#install-hammerspoon) below) you can run the following script to install Autocomplete.

    $ curl -sSL https://raw.githubusercontent.com/pasiaj/gTranslate-for-Hammerspoon/master/install.sh | bash

[install.sh](https://raw.githubusercontent.com/pasiaj/gTranslate-for-Hammerspoon/master/install.sh) just clones this repository into `~/.hammerspoon`, loads it into Hammerspoon and sets `⌃⌥⌘T` as the default keybinding.

#### Manual installation

    $ git clone https://github.com/pasiaj/gTranslate-for-Hammerspoon ~/.hammerspoon/gtranslate

To initialize, add to `~/.hammerspoon/init.lua` (creating it if it does not exist):

    local gtranslate = require "gtranslate/gtranslate"
    gtranslate.init("YOUR_APIKEY")

Alternatively, copy `gtranslate.lua` from this repository to whereever
you keep other Hammerspoon modules and load it appropriately.

Reload the Hammerspoon config.

#### Install Hammerspoon

Hammerspoon can be installed using [homebrew/caskroom](https://caskroom.github.io/).

    $ brew tap caskroom/cask
    $ brew cask install hammerspoon
    $ open -a /Applications/Hammerspoon.app

### Usage

Trigger with the hotkey `⌃⌥⌘T`. Once you start typing, suggestions will populate.
They can be choosen with `⌘1-9` or by pressing the arrow keys and Enter.
Pressing `⌘C` copies the selected item to the clipboard.

The source and target languages and the hotkey can be changed by passing in arguments to
`init` call (in your `~/.hammerspoon/init.lua` file)
such as:

    gtranslate.init("YOUR_APIKEY", "fi", "en", {"cmd", "ctrl"}, 'L')


### Credits

This work is almost fully based on the [Anycomplete codebase](https://github.com/nathancahill/Anycomplete) by [Nathan Cahill](https://nathancahill.com/).