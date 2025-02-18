#------------------------------------------------------------------------------------------------------------
#        Функция перекодировки и пересылки сообщений на 
#    русском и английском языках в мессенджер Телеграмм
#                                    by Sertik  версия 19.09.2021 
#-----------------------------------------------------------------------------------------------------------

#
# usage [$FuncTelegramSender "text message" "style"]
# style ="html" or "markdown" or nothing
#
# Examles:
#
# [$FuncTelegramSender ("$[/system resource get version]"."%0A"."Ros version")]
# [$FuncTelegramSender ("<b>"."$[/system resource get version]"."</b>"."%0A"."Ros version") "html"]
# <b> жирный </b>
# <i> курсив </i>
# <u> подчеркивание </u>
# <s> зачеркнутый </s>
# [$FuncTelegramSender ("*"."$[/system resource get version]"."*"."%0A"."Ros version") "markdown"]
# [$FuncTelegramSender "`text message`" "markdown"] - monospased text


:global FuncTelegramSender do={
:if ([:len $0]!=0) do={
:global botID "you botID" ;
:global myChatID "you chat number";
:local Tstyle
:if ([:len $2]=0) do={} else={:set $Tstyle $2} 
:if (($2="html") or ($2="markdown") or ([:len $2]=0)) do={

:local string; :set $string $1;

#  table of the codes of Russian letters UTF8
:local rsimv [:toarray {"А"="D090"; "Б"="D091"; "В"="D092"; "Г"="D093"; "Д"="D094"; "Е"="D095"; "Ж"="D096"; "З"="D097"; "И"="D098"; "Й"="D099"; "К"="D09A"; "Л"="D09B"; "М"="D09C"; "Н"="D09D"; "О"="D09E"; "П"="D09F"; "Р"="D0A0"; "С"="D0A1"; "Т"="D0A2"; "У"="D0A3"; "Ф"="D0A4"; "Х"="D0A5"; "Ц"="D0A6"; "Ч"="D0A7"; "Ш"="D0A8"; "Щ"="D0A9"; "Ъ"="D0AA"; "Ы"="D0AB"; "Ь"="D0AC"; "Э"="D0AD"; "Ю"="D0AE"; "Я"="D0AF"; "а"="D0B0"; "б"="D0B1"; "в"="D0B2"; "г"="D0B3"; "д"="D0B4"; "е"="D0B5"; "ж"="D0B6"; "з"="D0B7"; "и"="D0B8"; "й"="D0B9"; "к"="D0BA"; "л"="D0BB"; "м"="D0BC"; "н"="D0BD"; "о"="D0BE"; "п"="D0BF"; "р"="D180"; "с"="D181"; "т"="D182"; "у"="D183"; "ф"="D184"; "х"="D185"; "ц"="D186"; "ч"="D187"; "ш"="D188"; "щ"="D189"; "ъ"="D18A"; "ы"="D18B"; "ь"="D18C"; "э"="D18D"; "ю"="D18E"; "я"="D18F"; "Ё"="D001"; "ё"="D191"; "№"="0023"; " "="0020"; "&"="0026"; "^"="005E"}]

# encoding of the symbols and аssembly line
:local StrTele ""; :local code "";
:for i from=0 to=([:len $string]-1) do={:local keys [:pick $string $i (1+$i)]; :local key ($rsimv->$keys); if ([:len $key]!=0) do={:set $code ("%"."$[:pick ($rsimv->$keys) 0 2]"."%"."$[:pick ($rsimv->$keys) 2 4]");:if ([pick $code 0 3] ="%00") do={:set $code [:pick $code 3 6]}} else={:set $code $keys}; :set $StrTele ("$StrTele"."$code")}

do {
/tool fetch url="https://api.telegram.org/$botID/sendmessage\?chat_id=$myChatID&parse_mode=$Tstyle&text=$StrTele" keep-result=no; :return "Done"
} on-error={:log info; :log error "Error function $0 fetch"; :log info ""; :return "Error fetch"}
    } else={:log info; log error "Parametrs function $0 mismatch"; :log info ""; :return "Error parametrs mismatch"}
  }
}

# [$FuncTelegramSender "`text message текст сообщения`" "markdown"]
# [$FuncTelegramSender ("<b>"."Ros version "."$[/system resource get version]"."</b>"."%0A"."версия РоутерОС "."$[/system resource get version]") "html"]
# [$FuncTelegramSender ("пиктограмма восхода солнца %F0%9F%8C%85"." и его заката %F0%9F%8C%87 ")]