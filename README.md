# FuncTelegramSender for Microtic
I found this script on the [forummikrotik.ru](https://forummikrotik.ru/viewtopic.php?p=81457#p81457). Where it was published by Sertik. Therefore, I do not own any intellectual rights to it. However, to make this function work at the time I found it, a small code correction was needed, and I also have the desire to describe its usage in more detail and possibly support its functionality in the future.

# Usage
## Plain message to telegram group
```
$FuncTelegramSender "Dull and boring test message" -apitoken <YOUR_BOT_APITOKEN> -chatid <YOUR_GROUP_CHATID>
```

## Use of apitoken and chatid stored in global vireables FuncTelegramSenderApitoken and FuncTelegramSenderChatID
```
:global FuncTelegramSenderApitoken "<YOUR_BOT_APITOKEN>"
:global FuncTelegramSenderChatID "YOUR_GROUP_CHATID"
$FuncTelegramSender "testing with global variables" useGlobalVariables=yes
```

## Use of emojies
```
$FuncTelegramSender "sunrise %F0%9F%8C%85" and a sunset %F0%9F%8C%87 emojies"  useGlobalVariables=yes
```

## Markdown format of message
```
$FuncTelegramSender "```powershell Get-Help``` probably most usefull cmdlet. %F0%9F%98%8E" -style=html useGlobalVariables=yes
```

## Html format of message
```
$FuncTelegramSender ("<b>" . "Ros version " . "$[/system resource get version]" . "</b>" . "%0A" . "RouterOS version " . "$[/system resource get version]") style=html useGlobalVariables=yes
```
Default style is html, so style=html could be omitted.

# Tips
## About Cyrillic characters
FuncTelegramSender could be used with cyrillic characters in scripts. 
In winbox termianal however cyrillic characters cannot be entered from the keyboard, and when pasted they become replaced with ??? signs.

## About emojies convertion
If you need convert emoji to URL-encoded format you could use https://www.urlencoder.org/