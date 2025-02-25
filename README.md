# FuncTelegramSender
Mikrotik RouterOS script for transcoding and sending Telegram messages.  
- Supports emojies, english and cyrillic characters.  
- Could use defined global variables or named arguments to provide Telegram Apitoken and ChatID.  
- Resolves the problem with Mikrotik `/tool fetch` unable to send emojies or cyrillic characters.

### Disclamer and expression of gratitude
This script is a "forked" version of script created by Sertik and published on [forummikrotik.ru](https://forummikrotik.ru/viewtopic.php?p=81457#p81457).  
This version of script contains some improvements that I see handy.  
For example code is reformatted for better reading, named variables now passing to script in contrast to position arguments, use of global virables now optional and so on...

# Installation
## Uploading FuncTelegramSender.rsc to Mikrotik
Use `Files -> Upload...` in winbox menu and select FuncTelegramSender.rsc to be uploaded to Mikrotik.  
Or fetch file directly from GitHub:
```
/tool fetch url="https://raw.githubusercontent.com/ahpooch/FuncTelegramSender/refs/heads/main/FuncTelegramSender.rsc" mode=https dst-path="FuncTelegramSender.rsc"
```
Use `dst-path=YOUR_PATH\FuncTelegramSender.rsc` to specify your preferred path if you like.
## Importing FuncTelegramSender
```
:import FuncTelegramSender.rsc
```
Use `YOUR_PATH\FuncTelegramSender.rsc` if you placed the script in your preferred path.  

### Importing FuncTelegramSender at startup
You could set a scheduler to import FuncTelegramSender at startup:
```
/system scheduler add name=FuncTelegramSenderImport start-time=startup interval=0 comment="FuncTelegramSender scheduled task to import itself on startup." on-event={ :import FuncTelegramSender.rsc }
```
Use `YOUR_PATH\FuncTelegramSender.rsc` if you placed the script in your preferred path.

# Usage
## Plain message to telegram group
```
$FuncTelegramSender "Dull and boring test message" apitoken="<YOUR_BOT_APITOKEN>" chatid="<YOUR_GROUP_CHATID>"
```

## Use of apitoken and chatid stored in global vireables
Variable names FuncTelegramSenderApitoken and FuncTelegramSenderChatID are predefined.
```
:global FuncTelegramSenderApitoken "<YOUR_BOT_APITOKEN>"
:global FuncTelegramSenderChatID "YOUR_GROUP_CHATID"
$FuncTelegramSender "Test sending with global variables" useGlobalVariables=yes
```
Global variables are cleared on reboot, so you could use scheduled task to restore them at startup:
```
/system scheduler add name=FuncTelegramSenderRestore start-time=startup interval=0 comment="FuncTelegramSender scheduled task to restore global variables FuncTelegramSenderApitoken and FuncTelegramSenderChatID on startup." on-event={ :global FuncTelegramSenderApitoken "<YOUR_BOT_APITOKEN>"; :global FuncTelegramSenderChatID "YOUR_GROUP_CHATID" }
```

## Use of emojies
```
$FuncTelegramSender "Sunrise %F0%9F%8C%85 and a sunset %F0%9F%8C%87 emojies." useGlobalVariables=yes
```

## Markdown format of message
```
$FuncTelegramSender "```powershell Get-Help``` probably most usefull Powershel cmdlet. %F0%9F%98%8E" -style=html useGlobalVariables=yes
```

## Html format of message
```
$FuncTelegramSender ("<b>" . "Ros version " . "$[/system resource get version]" . "</b>" . "%0A" . "RouterOS version " . "$[/system resource get version]") style=html useGlobalVariables=yes
```
The default style is `html`, so `style=html` could be omitted or left in for clarity.

# Tips
## About Cyrillic characters
FuncTelegramSender can be used with Cyrillic characters in scripts.  
In Winbox termianal however Cyrillic characters cannot be entered from the keyboard, and when pasted, they are replaced with ??? signs.

## About emojies convertion
If you need to convert emojis to a URL-encoded format, you can use one of online converters like [urlencoder.org](https://www.urlencoder.org/).
