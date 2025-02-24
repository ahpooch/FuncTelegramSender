#-------------------------------------------------------------------------------------------------------#
#        Function for transcoding and sending messages in telegram messager.                            #
#        Supports emojies, english and russian languages.                                               #
#            Initially created by Sertik.                                                               #
#            "Forked" to GitHub by @ahpooch.                                                            #
#            "Forked" from version 19.09.2021 at https://forummikrotik.ru/viewtopic.php?p=81457#p81457  #
#            Updated: 24.02.2025                                                                        #
#            Latest version here: https://github.com/ahpooch/FuncTelegramSender                         #
#-------------------------------------------------------------------------------------------------------#

### Usage
# - Plain message to telegram group
#$FuncTelegramSender "Dull and boring test message" -apitoken <YOUR_BOT_APITOKEN> -chatid <YOUR_GROUP_CHATID>

# - Use of apitoken and chatid stored in global vireables FuncTelegramSenderApitoken and FuncTelegramSenderChatID
#:global FuncTelegramSenderApitoken "<YOUR_BOT_APITOKEN>"
#:global FuncTelegramSenderChatID "YOUR_GROUP_CHATID"
# $FuncTelegramSender "testing with global variables" useGlobalVariables=yes

# - Use of emojies
# $FuncTelegramSender "sunrise %F0%9F%8C%85" and a sunset %F0%9F%8C%87 emojies"  useGlobalVariables=yes

# - Markdown format of message
# $FuncTelegramSender "```powershell Get-Help``` probably most usefull cmdlet. %F0%9F%98%8E" -style=html useGlobalVariables=yes

# - Html format of message
# $FuncTelegramSender ("<b>" . "Ros version " . "$[/system resource get version]" . "</b>" . "%0A" . "RouterOS version " . "$[/system resource get version]") style=html useGlobalVariables=yes
# Default style is html, so style=html could be omitted.

### Tips
# - About Cyrillic characters
# FuncTelegramSender could be used with cyrillic characters in scripts. 
# In winbox termianal however cyrillic characters cannot be entered from the keyboard, and when pasted they become replaced with ??? signs.

# - About emojies convertion
# If you need convert emoji to URL-encoded format you could use https://www.urlencoder.org/

:global FuncTelegramSender do={
  # named parameters that can be passed to function on call :
  # apitoken
  # chatid
  # style
  # useGlobalVariables
  
  :local telegramApitoken
  :local telegramChatID
  :local telegramMessage
  :if ([:len $1] > 0) do={
    :local telegramMessage $1
  }
  :if ([:len $useGlobalVariables] = 0) do={
    :set $useGlobalVariables "no"
    :if (([:len $apitoken] > 0)&&([:len $chatid] > 0)) do={
        :set $telegramApitoken $apitoken
        :set $telegramChatID $chatid
      } else={
        :local returnMessage "Parameters \"apitoken\" and \"chatid\" should be specified if \"\$useGlobalVariables=yes\" not provided."
        :log error $returnMessage
        :return $returnMessage
      }
  } else={
    :if ($useGlobalVariables = "yes") do={
      :global FuncTelegramSenderApitoken
      :global FuncTelegramSenderChatID
      :if (([:len $FuncTelegramSenderApitoken]=0)||([:len $FuncTelegramSenderChatID]=0)) do={
        :local returnMessage "Global variables \"FuncTelegramSenderApitoken\" and \"FuncTelegramSenderChatID\" should be set if you want to use \"useGlobalVariables=yes\"."
        :log error ($0 . ":" . $returnMessage)
        :return ($0 . ":" . $returnMessage)
      } else={
        :set $telegramApitoken $FuncTelegramSenderApitoken
        :set $telegramChatID $FuncTelegramSenderChatID
      }
    } else={
      :if ($useGlobalVariables = "no") do={
        :set $telegramApitoken $apitoken
        :set $telegramChatID $chatid
      } else={
        :local returnMessage "Parameters useGlobalVariables should be \"yes\" or \"no\"."
        :log error $returnMessage
        :return $returnMessage
      }
    }
  }

  # Main function 
  :if ([:len $0] > 0) do={
    :if ([:len $style] = 0) do={
      :set $telegramStyle "html"
    } else={
      :set $telegramStyle $style
    }
    :if (($telegramStyle="html")||($telegramStyle="markdown")) do={
      :local messageString
      :set $messageString $1
      # Table of codes for Russian letters UTF8
      :local rsimv [:toarray {
        "А"="D090"; "Б"="D091"; "В"="D092"; "Г"="D093"; "Д"="D094"; /
        "Е"="D095"; "Ё"="D001"; "Ж"="D096"; "З"="D097"; "И"="D098"; /
        "Й"="D099"; "К"="D09A"; "Л"="D09B"; "М"="D09C"; "Н"="D09D"; /
        "О"="D09E"; "П"="D09F"; "Р"="D0A0"; "С"="D0A1"; "Т"="D0A2"; /
        "У"="D0A3"; "Ф"="D0A4"; "Х"="D0A5"; "Ц"="D0A6"; "Ч"="D0A7"; /
        "Ш"="D0A8"; "Щ"="D0A9"; "Ъ"="D0AA"; "Ы"="D0AB"; "Ь"="D0AC"; /
        "Э"="D0AD"; "Ю"="D0AE"; "Я"="D0AF"; /
        "а"="D0B0"; "б"="D0B1"; "в"="D0B2"; "г"="D0B3"; "д"="D0B4"; /
        "е"="D0B5"; "ё"="D191"; "ж"="D0B6"; "з"="D0B7"; "и"="D0B8"; /
        "й"="D0B9"; "к"="D0BA"; "л"="D0BB"; "м"="D0BC"; "н"="D0BD"; /
        "о"="D0BE"; "п"="D0BF"; "р"="D180"; "с"="D181"; "т"="D182"; /
        "у"="D183"; "ф"="D184"; "х"="D185"; "ц"="D186"; "ч"="D187"; /
        "ш"="D188"; "щ"="D189"; "ъ"="D18A"; "ы"="D18B"; "ь"="D18C"; /
        "э"="D18D"; "ю"="D18E"; "я"="D18F"; /
        "№"="0023"; " "="0020"; "&"="0026"; "^"="005E"
      }]
      # Encoding of symbols and assembly line
      :local messageStringEncoded ""
      :local code ""
      :for i from=0 to=([:len $messageString]-1) do={
        :local keys [:pick $messageString $i (1+$i)]
        :local key ($rsimv->$keys)
        :if ([:len $key]!=0) do={
          :set $code ("%" . "$[:pick ($rsimv->$keys) 0 2]" . "%" . "$[:pick ($rsimv->$keys) 2 4]")
          :if ([:pick $code 0 3] ="%00") do={
            :set $code [:pick $code 3 6]
          }
        } else={
          :set $code $keys
        }
        :set $messageStringEncoded ("$messageStringEncoded" . "$code")
      }

      do {
        :local telegramUrl ("https://api.telegram.org/bot" . $telegramApitoken . "/sendmessage?chat_id=" . $telegramChatID . "&parse_mode=" . $telegramStyle . "&text=" . $messageStringEncoded)
        /tool fetch url=$telegramUrl keep-result=no
        :return "Done"
      } on-error={
        :local returnMessage "Error while sending message."
        :log error ($0 . ":" . $returnMessage)
        :return ($0 . ":" . $returnMessage)
      }
    } else={
      :local returnMessage "Parameter style should be \"html\" or \"markdown\"."
      :log error ($0 . ":" . $returnMessage)
      :return ($0 . ":" . $returnMessage)
    }
  }
}