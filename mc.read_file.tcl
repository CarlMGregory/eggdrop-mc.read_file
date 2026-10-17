##
# ReadFile v1.4.1
#  by Carl M. Gregory - MC_8 <gregory@worldinter.net> (feel free to report bugs)
#  This file, along with many others are best found at http://bseen.tclslave.net/
##

##
# This will enable the bot to read the contents of a file to any user
# that triggers a setable trigger (pub/msg).
##

##
# History
##
# v1.4.1 (03.05.01)
#  MC_8 - Upgraded SVS to v1.2
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

# Set the next line as the command you want to initiate the lister
# and set the file, confusing? here is an example
# set listmc(<lowercased command>) <file.txt or /path/to/file.txt>
# command has to be lower cased or it will not work
# file.txt is case sensative, should be exact to the real filename.
# you may add as many as you would like
set listmc(mp3help) mp3help.txt
set listmc(!help) mp3help.txt

# Do you also want these commands avilable public too?
# 0 = no
# 1 = yes
set mc_rf(public) 1

# If triggered in public, do you want it to read the file in public insted
# of privmsg to the user?
# 0 = no
# 1 = yes
set mc_rf(public:read) 1

# If above public is 1 (yes), what channels do you want them on exactly?
# Set to "" for all channels.
set mc_rf(channels) "#mp34free #abc123"

# To slow the post speed down a bit, how many seconds do you want to
# space out each post?  (Seconds per Line)
# example:  2 will post 1 line every 2 seconds
set mc_rf(speed) 1

# How many times in how many min.s can the user access a command?
set mc_rf(user:access) 1:1

# Overall, how many commands:min can be accessed before considering
# a possible flood and disable all commands?
set mc_rf(over:access) 6:1

# If the flood is detected, how long do you want to keep the commands
# disabled?  (in seconds)
set mc_rf(flood:sec) 10

## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_rf(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_rf(svs:check) 0  ;#This is at Midnight
#  set mc_rf(svs:check) 5  ;#This is at 5am
#  set mc_rf(svs:check) 13  ;#This is at 1pm
#  set mc_rf(svs:check) 23  ;#This is at 11pm
set mc_rf(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_rf(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_rf(svs:stableonly) 0




## Do not venture past here, TCL Coding below.

set mc_rf(version) v1.4.1
set mc_rf(svs:script) "readfile 001004001000"
set mc_rf(svs:server) "mc.purehype.net 8085"

bind pubm - * mc:rf:telllist:pubm

proc mc:rf:telllist:pubm {nick uhost hand chan args} {
 global mc_rf
 if {!$mc_rf(public)} {return}
 if {$mc_rf(channels) == ""} {set channels [string tolower [channels]]} {
  set channels [string tolower $mc_rf(channels)]
 }
 if {![string match "* [string tolower $chan] *" " $channels "]} {return 0}
 mc:rf:telllist $nick $uhost $hand [join $args] $chan
}

bind msgm - * mc:rf:telllist:msgm
proc mc:rf:telllist:msgm {nick uhost hand args} {
 global mc_rf ; mc:rf:telllist $nick $uhost $hand [join $args] msg
}

proc mc:rf:telllist {nick uhost hand args method} {
 global listmc listmcg mc_rf ; set args [join $args]
 if {[info exists listmc([string tolower $args])]} {
  set temp $args:[string range $uhost [expr [string first @ $uhost]+1] e]
  set access [lindex [split $mc_rf(user:access) :] 0]
  if {[info exists mc_rf(user:$temp)]} {
   if {$mc_rf(user:$temp) > $access} {
    if {![string match "*catch {incr mc_rf(user:$temp) -1}*" [timers]]} {
     unset mc_rf(user:$temp) ; utimer 1 mc:rf:telllist $nick $uhost $hand $args $method
    } {putlog "ReadFile:  Ignoring $nick!$uhost's request of $args.  (Detected from from $nick)"}
    return 0
   } {
    incr mc_rf(user:$temp) 1
    timer [lindex [split $mc_rf(user:access) :] 1] "catch {incr mc_rf(user:$temp) -1}"
   }
  } {
   set mc_rf(user:$temp) 1
   timer [lindex [split $mc_rf(user:access) :] 1] "catch {incr mc_rf(user:$temp) -1}"
  }
  set access [lindex [split $mc_rf(over:access) :] 0]
  if {[info exists mc_rf(over:flood)]} {
   if {$mc_rf(over:flood) > $access} {
    if {![string match "catch {incr mc_rf(over:flood) -1}" [timers]]} {
     unset mc_rf(over:flood) ; utimer 1 mc:rf:tellist $nick $uhost $hand $args $method
    } {
     set mc_rf(over:flood:ignore) 1
     utimer $mc_rf(flood:sec) "catch {unset mc_rf(over:flood:ignore)}"
     putlog "ReadFile:  Ignoring $nick!$uhost's request of $args.  (Detected overall flood)"
    } ; return 0
   } {
    incr mc_rf(over:flood) 1
    timer [lindex [split $mc_rf(over:access) :] 1] "catch {incr mc_rf(over:flood) -1}"
   }
  } {
   set mc_rf(over:flood) 1
   timer [lindex [split $mc_rf(over:access) :] 1] "catch {incr mc_rf(over:flood) -1}"
  } ; if [info exists mc_rf(over:flood:ignore)] {return 0}
  if {$mc_rf(public:read) && ($method != "msg")} {set nick $method}
  if {![file exists $listmc([string tolower $args])]} {
   puthelp "PRIVMSG $nick :ReadFile: error, $listmc([string tolower $args]) doesn't exist."
  } { 
   # reading info...
   set file [open $listmc([string tolower $args]) r]
   if {!$mc_rf(speed)} {
    while {![eof $file]} {
     set get [gets $file]
     puthelp "PRIVMSG $nick :$gets"
    }
   } {
    set i 1
    while {![eof $file]} {
     set get [gets $file]
     utimer $i "puthelp {PRIVMSG $nick :$get}"
     incr i $mc_rf(speed)
    }
   } ; close $file
   # End Of File
  }
 } ; return 1
}

if {$mc_rf(svs:enabled)} {
 if {($mc_rf(svs:check) > "23") || ($mc_rf(svs:check) < "0")} {set mc_rf(svs:check) 00}
 if {[string length $mc_rf(svs:check)] == "1"} {set mc_rf(svs:check) 0$mc_rf(svs:check)}
 if {$mc_rf(svs:stableonly)} {
  set mc_rf(svs:script) [string range $mc_rf(svs:script) 0 [expr [string length $mc_rf(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_rf(svs:oldcheck) * * *" mc:rf:svs:time}
 set mc_rf(svs:oldcheck) $mc_rf(svs:check)
 bind time - "00 $mc_rf(svs:check) * * *" mc:rf:svs:time
 proc mc:rf:svs:time {min hour day month year} {
  global mc_rf
  catch {control [connect [lindex $mc_rf(svs:server) 0] [lindex $mc_rf(svs:server) 1]] mc:rf:svs:interface}
 }
}
proc mc:rf:svs:interface {idx args} {
 global mc_rf;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_rf(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_rf(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_rf(svs:script) 1]} {
    set note [mc:rf:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:rf:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:rf:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_rf(version)}"]
    set note [mc:rf:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:rf:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:rf:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:rf:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_rf(svs:notify) ",;"]] {
     set outnote [mc:rf:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_rf(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_rf(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:rf:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "ReadFile $mc_rf(version) by MC_8 loaded."