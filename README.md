# wow-instant-messenger
WIM (WoW Instant Messenger) is a World of Warcraft addon which brings an instant messenger feel to communication in game.

## Features
* Whispers in their own windows.
* Chat in their own windows.
* Tabbed windows
* Highly configurable.
* History
* Copy and paste as:
  * Raw Text
  * BBCode
  * Advanced, intellectual window behaviors & animations.
  * Skins
  * Emoticons
  * Clickable web URLS for easy viewing. No more retyping a long url a friend sends you.
  * Customizable sound options.
  * Expose - great way to clear your screen of windows when you are in combat.

## Known Issues
* Addons can not process messages while chat is in lock down. To get around this, WIM logs all events and then rebuilds and processes them once you have excited lock down. During this time, chat is routed as normal to the default chat frame so you don't miss anything. Unfortunately, /r and similar keybindings to reply during this time will NOT work. Allowing the default chat frame to handle these events cause severe tainting issues and breaks everything.
* Community Chat is now supported. It comes with limitations though because the sender name and message are protected and can not be read by addons or saved.
	* No filtering
	* No History

## Addon Compatibility: (Always make sure you are running the latest versions.)
* Prat
* DBM
