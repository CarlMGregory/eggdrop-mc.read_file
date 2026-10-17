##
# Read File v1.5 by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
##

##
# This will enable the bot to read the contents of a file to any user
# that triggers a setable trigger (pub/msg).
##

##
# History
##
# v1.5 (11.14.01)
#  MC_8 - Updated SVS from v1.2 to v2.0.
#  MC_8 - Fixed flood proc.
#  MC_8 - Joe_Astor - Fixed '[00:36] TCL error [mc:rf:telllist:pubm]: list
#                     element in quotes followed by "?" instead of space'.
#  MC_8 - Cleaned up the coding, made it faster/ more effecent.
#  MC_8 - Added mc_rf(private) and mc_rf(ctcp).
#  MC_8 - Removed mc_rf(speed), not needed.  Eggdrop has an internal que'n
#         system to keep the bot from flooding it's self offline.
#
# v1.4.1 (03.05.01)
#  MC_8 - Upgraded SVS from v1.1 to v1.2.
#  MC_8 - SoulMaster - Removed debug outputs (opps, this should of been gone
#                      already).
#
# v1.4 (11.19.00)
#  MC_8 - Benito - Wasn't processing public requests.
#  MC_8 - Added SVS option.
#  MC_8 - everyone - Added `mc_rf(public:read)' veriable.  If read is triggered
#                    in public, do you want it to read the file to the public?
#
# v1.3 (09.19.00)
#  MC_8 - Added ability to have the commands public as well as /msg.
#  MC_8 - Added flood prevention.
#
# v1.2 (08.14.00)
#  MC_8 - Removed dependency of moretools.
#  MC_8 - MATSATI - Added mc_rf(speed).
#
# v1.1a-Win32 (01-20-00)
#  MC_8 - MATSATI - Now works for wineggs.
#
# v1.1a (10-07-99)
#  MC_8 - Bug fix, was eating EVERY msg... not letting msg's get
#         through to other procs.
#
# v1.1  (10-06-99)
#  MC_8 - Took the debug bs off.
#  MC_8 - Fixed bind, msg => msgm
#
# v1.0 (xx-xx-99)
#  MC_8 - Inital release.
##

# Set this to the command and file you want to be read?
# Syntax:
#  set mc_rfc(<command>) <file.txt or /path/to/file.txt>
# You may add as many as you would like, examples below.
set mc_rfc(mp3help) mp3help.txt
set mc_rfc(!help) mp3help.txt

# [0=no/1=yes] Do you want these commands avilable  via 
# private message (/msg bot <command>)?
set mc_rf(private) 1

# [0=no/1=yes] Do you want these commands avilable via CTCP
# (/ctcp bot <command>)?
set mc_rf(ctcp) 1

# [0=no/1=yes] Do you want these commands avilable publicly
# (/msg #channel <command>?
set mc_rf(public) 1

# If above, public, is 1; what channels should the commands
# be active on?  Set to "" for all channels. Seperate each 
# channel with a space.
set mc_rf(channels) "#mp34free #abc123"

# If triggered in public, do you want it to read the file in
# publicly or via private message?
#  0 = private message
#  1 = publicly
set mc_rf(public:read) 1

# Per person, how many commands in how many min.s do you want
# to allow before condidering it a flood from this 1 user?
# <times>:<min.s>
set mc_rf(user:access) 1:1

# For everyone, how many commands in how many min.s do you want
# to allow before considering it a mass flood?
# <times>:<min.s>
set mc_rf(over:access) 6:1

# If the a flood is detected, how long (in seconds) do you want 
# to keep the user on ignore?
set mc_rf(flood:sec) 10


## MC SVS (Script Version Service) v2.0 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_rf(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_rf(svs:check) 0   ;#This is at Midnight
#  set mc_rf(svs:check) 5   ;#This is at 5am
#  set mc_rf(svs:check) 13  ;#This is at 1pm
#  set mc_rf(svs:check) 23  ;#This is at 11pm
set mc_rf(svs:check) 3

# Upon finding a newer version of this script, who do you want this script
# to send a note to telling them of this newer version?
# If more than 1 user is to be notified, seperate each user with a
# ' ' (space).
set mc_rf(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_rf(svs:stableonly) 0



##
# TCL Coding below, do not edit past here
# unless you know what your doing.
##

set mc_rf(script)      "Read File"
set mc_rf(version)     "v1.5"
set mc_rf(svs:script)  "readfile"
set mc_rf(svs:version) "001005000000"
set mc_rf(svs:server)  "mc.purehype.net"
set mc_rf(svs:port)    "81"
set mc_rf(svs:get)     "/"
set mc_rf(svs:query)   "svs=$mc_rf(svs:script)&version=$mc_rf(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_rf(script) $mc_rf(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_rf(script) $mc_rf(version)  will not work with eggdrop $version."
 putlog "$mc_rf(script) $mc_rf(version)  not loaded."
 return 1
}


bind pubm - * mc:rf:pubm
proc mc:rf:pubm {nick uhost hand chan arg} {
 global mc_rf
 if {(!$mc_rf(public)) || (($mc_rf(channels) != "") &&
     ([lsearch -exact [string tolower $mc_rf(channels)] [string tolower $chan]] == "-1"))} {
  return 0
 }; mc:rf:rf $nick $uhost $hand $arg channel $chan
}

bind msgm - * mc:rf:msgm
proc mc:rf:msgm {nick uhost hand arg} {
 global mc_rf
 if {$mc_rf(private)} {mc:rf:rf $nick $uhost $hand $arg privmsg}
}

proc mc:rf:ctcp {from key arg} {
 global mc_rf botnick
 scan "$arg\015" "%s :%\[^\015\]" dest arg
 if {(![regexp -- "^\001(.*)\001\$" $arg a text]) ||
     ([string tolower $dest] != [string tolower $botnick]) ||
     (!$mc_rf(ctcp))} {return 0}
 scan "$text\015" "%s %\[^\015\]" key text
 scan $from {%[^!]!%[^@]@%s} nick ident host
 if {[join $text] != ""} {append key " $text"}
 mc:rf:rf $nick $ident@$host [nick2hand $nick] $key ctcp
}

proc mc:rf:rf {nick uhost hand arg method {chan {}}} {
 global mc_rfc mc_rf
 scan $uhost {%[^@]@%s} ident host
 set larg [string tolower $arg]
 if {(![info exists mc_rfc($larg)]) ||
     ([info exists mc_rf(!ignore:$host)]) ||
     ([info exists mc_rf(!ignore:all)])} {return 0}
 if {[mc:rf:userlimit $host]} {
  putlog "$mc_rf(script):  Flood detected from $nick ($uhost), ignoring."
  return 1
 }
 if {[mc:rf:userlimit all]} {
  putlog "$mc_rf(script):  Flood detected, ignoring everyone."
  return 1
 }
 if {![file exists $mc_rfc($larg)]} {
  putlog "$mc_rf(script):  Error for trigger '$arg', $mc_rfc($larg) doesn't exist."
  return 0
 }
 if {($method == "channel") && ($mc_rf(public:read))} {set nick $chan}
 set io [open $mc_rfc($larg) r]
 while {![eof $io]} {puthelp "PRIVMSG $nick :[gets $io]"}; close $io
 return 1
}

proc mc:rf:userlimit {host} {
 global mc_rf
 set host [string tolower $host]
 if {$host == "all"} {set array "over"} else {set array "user"}
 scan $mc_rf(${array}:access) {%[^:]:%s} a b
 if {(!$a) || (!$b)} {return 0}
 if {[info exists mc_rf(!$host)]} {
  if {$mc_rf(!$host) >= $a} {
   set mc_rf(!ignore:$host) 1
   utimer $mc_rf(flood:sec) [list unset mc_rf(!ignore:$host)]
   return 1
  }; incr mc_rf(!$host) 1
 } else {set mc_rf(!$host) 1}
 utimer $b [list incr mc_rf(!$host) -1]; return 0
}

## SVS v2.0
if {(![info exists mc_rf(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_rf(svs:enabled)])} {set mc_rf(svs:enabled) 0}
if {(![info exists mc_rf(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_rf(svs:check)])} {set mc_rf(svs:check) 0}
if {![info exists mc_rf(svs:notify)]} {set mc_rf(svs:notify) $owner}
if {(![info exists mc_rf(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_rf(svs:stableonly)])} {set mc_rf(svs:stableonly) 0}
foreach bind [binds mc:rf:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:rf:svs:time] {rename $command ""}
if {$mc_rf(svs:enabled)} {
 if {($mc_rf(svs:check) > "23") || ($mc_rf(svs:check) < "0")} {set mc_rf(svs:check) 00}
 if {[string length $mc_rf(svs:check)] == "1"} {set mc_rf(svs:check) 0$mc_rf(svs:check)}
 bind time - "00 $mc_rf(svs:check) *" mc:rf:svs:time
 proc mc:rf:svs:time {{args ""}} {
  global mc_rf
  if {[catch {socket -async $mc_rf(svs:server) $mc_rf(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_rf(svs:script)/$mc_rf(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:rf:svs:interface $sid timeout"]
  fileevent $sid readable "mc:rf:svs:interface $sid $tout"
  puts $sid "GET $mc_rf(svs:get)?$mc_rf(svs:query) HTTP/1.0\
           \nHost: $mc_rf(svs:server)\n"
  flush $sid
 }
}
proc mc:rf:svs:interface {sid tout} {
 global mc_rf
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_rf(svs:script)/$mc_rf(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_rf(svs:script)} {
     putlog "SVS Error\[$mc_rf(svs:script)/$mc_rf(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break   
    }
    if {$mc_rf(svs:stableonly)} {
     set temp [string range $mc_rf(svs:version) 0 8]999
    } else {set temp [string range $mc_rf(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_rf(version) note
     foreach to [split $mc_rf(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_rf(svs:script)/$mc_rf(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_rf(svs:script)/$mc_rf(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_rf(script) $mc_rf(version) by MC_8 loaded."
