# Using https://github.com/bhilburn/powerlevel9k

ZDOTDIR=~/.zsh
fpath=( ~/.zsh $fpath )

# 'help' command
autoload -Uz run-help
unalias run-help 2>/dev/null
alias help=run-help

export RUST_SRC_PATH="/Users/ns/.rustup/toolchains/nightly-x86_64-apple-darwin stable-x86_64-apple-darwin"

# Networking
nuc=192.168.1.118
lab=10.1.124.5
vpn() {
  sudo openconnect --no-cert-check --juniper https://pulse.playground.global/anjuna.io
}
listener() {  # what process is listening on port $1
  echo LSOF:
  lsof -iTCP -sTCP:LISTEN -P -n | sed -ne   1p -e /:$1/p
  echo NETSTAT:
  sudo netstat -tnlp            | sed -ne 1,2p -e /:$1/p
}
lab() { ssh nico@$lab_ip; }
fwd_port_to_lab() {
  ssh -nNT -L${1}:localhost:${1} nico@$lab  # no shell
}
lab_vault() { ssh -L8200:localhost:8200 nico@$lab; }  # the common case
nuc() { ssh ns@$nuc_ip; }
port_status() { nmap -sT -p $1 $2; }  # port 8200 $lab_ip: open/closed (firewalled?)

# Searches are on shared history, as are CTRL-up/down,
# but plain up/down are on local history. (?)
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N          up-line-or-local-history
zle -N        down-line-or-local-history
bindkey "OA"   up-line-or-local-history
bindkey "OB" down-line-or-local-history
bindkey "^[[1;5A"   up-line-or-history  # [CTRL] + Cursor up
bindkey "^[[1;5B" down-line-or-history  # [CTRL] + Cursor down

# This bit causes the RPROMPT to be rewritten with the time at which
# the command was issued.  If you want to preserve that time (because
# it is the time at which the previous command ended), just hit return
# (empty cmd leaves the time stamp as it was).
num_empty_cmds=0
function my-accept-line {
  prev_status=$?
  if [[ -z "$BUFFER" ]]; then
    if [[ $prev_status -ne 0 ]]; then
      BUFFER=' true    ### implicit ###'
    else
      if (( num_empty_cmds++ > 2 )) {
        BUFFER=' line'
        num_empty_cmds=0
      }
    fi
  else
    zle reset-prompt
    num_empty_cmds=0
  fi
  zle .accept-line
}
zle -N accept-line my-accept-line

setopt \
  auto_param_keys \
  auto_param_slash \
  auto_remove_slash \
  auto_pushd \
  auto_cd \
  complete_aliases \
  list_packed \
  case_glob \
  case_match \
  magic_equal_subst \
  numeric_glob_sort \
  rc_expand_param \
  extended_history \
  hist_allow_clobber \
  hist_ignore_space \
  cdablevars \
  interactive_comments

########## Basics

alias a=alias

a e=echo
a m=less

a \?='noglob whence -vafsm'

a fn='zed -f'
compctl -F fn

a rmb='rm (|.)*~'
a rmbr='rm **/(|.)*~'

a dos2unix=fromdos

a cx='chmod a+x'

a wsdiff='sdiff -w195'

a nobuf='stdbuf -oL'  # actually, it's still buffered by line

setenv() { export $1="$2" }     # for compatibility with simple csh scripts

say+do() { echo "$@"; "$@" }            # say it, then do it
warn()   { echo "$@" 1>&2 }             # say to stderr

diskhogs() { du -ak | sed -n '/^[0-9]\{3\}/p' | sort -rn | $PAGER }
 cpuhogs() { ps -eo pcpu,pid,user,comm        | sort -rn | $PAGER }

psg() { ps -ef | egrep  "$*|UID" | grep -v grep }

a col='cut -d\  -f'  # overrides useless /usr/bin/col

########## .z* Files

a  .z='. ~/.{zprofile,zshenv,zshrc}'
a e.z='e ~/.{zprofile,zshenv,zshrc}'
a e.p='e ~/.zprofile'
a e.c='e ~/.zshrc'
a e.v='e ~/.zshenv'

########## History stuff

a h='history -iD'
a gethistory='fc -RI'
a -g ,o='$(eval `fc -ln -1`)'  # output of last cmd (which gets re-executed)

########## Line stuff

# Prints each arg on a separate line.
a lines='print -lr'

# Prints lines w line nums.
a num='nl -ba'

# Shows just the specified (by number) line.
line() {
  if [ $# = 0 ]; then
    local int n=$COLUMNS
    print
    while (( n-- > 0 )) { print -n =; }
    print
    print
  else
    local num
    num=$1 shift
    sed -ne "${num}p" "$@"
  fi
}

# Grab selections to make a doc.
got=$HOME/got
grab() {
  local x
  echo "Output in \$got:  l = add horizontal line,  q = quit,  g = add X selection, whatever = add whatever"
  while :; do
    read x
    case "$x" in
      l) >&1 >&3 echo '================================================================================';;
      g) >&1 >&3 xsel;;
      q) break;;
      *) >&3 echo "$x";;
    esac
  done 3>$got
}

########## Directory stuff

# cd to a directory, creating it if it doesn't exist.
md () { mkdir "$1"            }
md.() { mkdir "$1" && cd "$1" }

# nd names a directory; cnd cd's to a named directory (for completion).
nd () { export $1="${2:-$PWD}"; : ~$1 }
cnd() { cd "$1" }
compctl -n cnd

# ls stuff
a  l='ls -CFbh'
a la='ls -CFbhA'
a ll='ls -CFbhlA'

# TREE stuff
a td='tree -d'         # just the dirs
a tf='tree -FC'        # all file types
a tm='noglob tf -P'    # ..     matching this pattern
a tn='noglob tf -I'    # .. not matching this pattern

# Edit a var.
v() { vared ${1:-path} }
compctl -v v

# List previous directories and let me pick one.
pd() {
  dirs -v
  echo -n ' # '
  local num
  read -k num
  echo ''
  [ "$num" = $'\n' ] && num=1
  [ "$num" = 0 ] || pushd +$num
}

# Warp to a similar directory -- one path component replaced, e.g.
# ~/ws/proj1/src/main/scala/com/khaylo/tracking $ wd main test
# ~/ws/proj1/src/test/scala/com/khaylo/tracking $
wd() { cd "$1" "$2" }
wd_completions1() { reply=(`echo $PWD | sed 's:/: :g'`); }
wd_completions2() {
	local cmd arg1 rest
	read -c cmd arg1 rest
#	echo arg1 $arg1 >/dev/console
	prefix="${PWD%%${arg1}*}"
	reply=(`ls -d "$prefix"*(-/) | sed -e 's:/$::' -e 's:.*/::'`)
}
compctl -x 'p[1]' -K wd_completions1 - 'p[2]' -K wd_completions2 -- wd

# . with args sources them all.  With no args, you edit PWD.
. () {
  if [ $# = 0 ]; then
    vared PWD
    cd "$PWD"
  else
    local f
    for f; builtin . "$f"
  fi
}

# Path display/manipulation.  See also 'v path'
path() { lines $path }
+path() { PATH="$1:$PATH" }
path+() { PATH="$PATH:$1" }

# Interactive rename: you edit the path.
mvi() {
  local src dst
  for src; do
    [[ -e $src ]] || { print -u2 "$src does not exist"; continue }
    dst=$src
    vared dst
    [[ $src != $dst ]] && mkdir -p $dst:h && mv -n $src $dst
  done
}

########## Git

a gd='git diff'             # unstaged
a gds='git diff --staged'   #   staged
a gdh='git diff HEAD'       # all

a gs='git status'
a gk='git checkout'
a gp='git pull'
a gm='git merge'
a gh='git help'
a ga='git add'
a gt='git commit -m'

gtp() { git commit -m "$@" && git push }

gll() {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

########## JIRA

JIRA_CODE=JIRA_CODE   # Change this!

# Commit staged changes with the JIRA magic to close an issue.
function gjc {   # e.g. gjc 219 Blah blah blah
  local nnn=$1
  shift
  say+do git commit -m "USM-$nnn #resolve $*"
}

# Commit staged and unstaged changes with the JIRA magic to close an issue.
function gjca {   # e.g. gjca 219 Blah blah blah
  local nnn=$1
  shift
  say+do git commit -am "USM-$nnn #resolve $*"
}

########## Interactive tools

# Ask a y/n question and succeed if y.
# e.g.   ask Delete $file && rm $file
#        ask -n Delete $file && rm $file  # defaults to n
ask() {
  local default
  local response
  [ "$1" = -y ] && default=y && shift
  [ "$1" = -n ] && default=n && shift
  echo ""
  while :; do
    echo -n "$@"'? '
    [ "$default" ] && echo -n "($default) "
    read -q yn
    echo ""
    [ "$yn" = $'\n' ] && yn="$default"
    [ "$yn" = y ] && return 0
    [ "$yn" = n ] && return 1
    echo "Please enter y or n"
  done
}

########## Time stuff

 dateInSecs() { date +%s }
 secsToDate() {      date -d @$1                            '+%Y-%m-%d %H:%M:%S' }
msecsToDate() { d=$( date -d @$( echo $1 | sed 's/...$//' ) '+%Y-%m-%d %H:%M:%S' ); echo $d.$( echo $1 | sed 's/.*\(...\)/\1/' ) }

########## Archive stuff

function grepJars {
  what=`echo "$1" | sed s:\\\\.:/:g`
  for jar in ${2:-**/*.jar}; do
    output=`jar tf $jar | grep "$what"` && echo "  *** $jar ***\\n$output"
  done
}

########## Misc

# Generate some lines of test data.
tst() {
  local i
  for i in {1..${1:-5}}; echo $i{0..9}
}

a ports="lsof -i"

# Strips out #-based comments and blank lines.
strip\# () {
  sed -e 's/#.*//' -e '/^[ 	]*$/d' "$@"
}


########## Curl stuff; this should probably be moved out of here

# curl with cookie jar; put/post @file or string
export CU_URL=http://localhost:8080
export CU_JAR=~/.cookie_jar
cu-to  () { export CU_URL=http://${1-localhost}:8080; export CU_JAR=${2-~/.cookie_jar}; }
cu-url () { CU_URL="$1"; }
cu-jar () { CU_JAR="$1"; }
cu-put () { local x="$1"; shift; cu_ "$@" -X PUT -d "$x"; }
cu-post() { local x="$1"; shift; cu_ "$@"        -d "$x"; }
cu-del () {                      cu_ "$@" -X DELETE     ; }
cu-yaml_ () {
    local url="$CU_URL/$1"
    shift
    curl -b "$CU_JAR" \
         -H 'Content-Type: application/yaml' \
         -H       'Accept: application/yaml' \
         "$url" "$@"
}
cu-csv_ () {
    local url="$CU_URL/$1"
    shift
    curl -b "$CU_JAR" \
         -H       'Accept: application/csv' \
         "$url" "$@"
}
cu-text_ () {
    local url="$CU_URL/$1"
    shift
    curl -b "$CU_JAR" \
         -H       'Accept: text/plain' \
         "$url" "$@"
}
cu_() {
    local url="$CU_URL/$1"
    shift
    curl -b "$CU_JAR" "$url" "$@"
}
a cu-yaml=" noglob cu-yaml_ "
a cu-csv="  noglob cu-csv_  "
a cu-text=" noglob cu-text_ "
cu-help() {
<<EOF cat
CU_URL = $CU_URL
CU_JAR = $CU_JAR
cu-to lmyun2 /tmp/cookiejar
cu-yaml Path/vm1?depth=3
cu-put 'status: RUNNING' Path/vm1
cu-post "{ name: iie, type: Container }" Path/
cu-del Path/vm1
cu-csv Metrics/Vm?begin=2011-03-01
You can use @file instead of literal data.
EOF
}

########## Calculator

# e.g.
#     , 3.5 * 8
#     / 7
#     z / ( z + 1 )
#     -
# For trig, rand, more:  zmodload zsh/mathfunc

typeset -F z=0.0
a calc='noglob calc_'
calc_() {
    if [ $# = 2 ]; then
      [ "$2" = \+ ] && set -- "$1" \+ "$1"   #  3 +  =>    3 + 3
      [ "$2" = \- ] && set -- 0.0  \- "$1"   #  3 -  =>  0.0 - 3
      [ "$2" = \* ] && set -- "$1" \* "$1"   #  3 *  =>    3 * 3
      [ "$2" = \/ ] && set -- 1.0  \/ "$1"   #  3 /  =>  1.0 / 3
    fi
    (( z = $* ))
    echo $z | sed -e 's/0*$//' -e 's/\.$//'
}
a      ,='calc'
a      z='calc z'
a      0='calc 0.0'
a      1='calc 1.0'
a      2='calc 2.0'
a -- '+'='calc z +'
a -- '-'='calc z -'
a -- '*'='calc z *'
a -- '/'='calc z /'
int() {    # z = $1 (or $z) converted to an integer
  local int
  declare -i 10 int
  int=${1-z}
  calc $int
}
round() {    # z = $1 (or $z) rounded to nearest integer
  local int
  declare -i 10 int
  (( int = ${1-z} + .5 ))
  calc $int
}
16() {    # print $1 (or $z) in hex
  local int
  declare -i 16 int
  int=${1-$z}
  echo $int
}
  
########## Key bindings

bindkey -e  # emacs mode; having problems with vi mode

# Binds a key to emacs and both vi modes.
bind_all() {
  local map
  for map in viins vicmd emacs; bindkey -M $map $1 $2
}

bind_all '' push-input
bind_all '' describe-key-briefly
bind_all '^H' run-help
bind_all '^U' vi-kill-line
bind_all '^N' accept-and-infer-next-history

bind_all '^O' accept-and-menu-complete

keys() { <<EOF
Some interesting keys:
  ^\  stashes input, letting you type another command first
  ^_  describes next key
  ^H  shows help for this command
  ^W  erase previous word (in insert mode)
  ^O  accept item and continue completion (during menu completion with ^I)
  ^N  execute and infer next history (for repeating a sequence of commands)
  ^U  delete line left
See also:
  bindkey
  man zshzle
EOF
}

autoload zed

path+ /usr/local/sbin

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Cool prompt
source  ~/powerlevel9k/powerlevel9k.zsh-theme
zprompt_theme='powerlevel9k'

# .... = ../../..   https://github.com/knu/zsh-manydots-magic
autoload -Uz manydots-magic
manydots-magic

nd gi ~/ws/graphene-import

# Vault GET: vg path
vg() {
    say+do curl -v -H "X-Vault-Token: `cat ~/.vault-token`" "$VAULT_ADDR/v1/$1"
}

# Vault POST: vp path data
vp() {
    local path="$1"
    say+do curl -v -H "X-Vault-Token: `cat ~/.vault-token`" -d "$2" "$VAULT_ADDR/v1/$path" 
}

# Vault I/O: v op path other ...
v() {
    local op="$1"
    local path="$2"
    shift 2
    say+do curl -v -H "X-Vault-Token: `cat ~/.vault-token`" -X "$op" "$VAULT_ADDR/v1/$path" "$@"
}


export SGX_SIGNER_KEY=~/.enclave-key.pem

+path /usr/lib/ccache  # faster compiles
+path ~/vault/bin

source /home/ns/anjuna/anjuna-runtime-0.13.0029/env.sh
source /home/ns/ws/linux-sgx/linux/installer/bin/sgxsdk/environment
export VAULT_ADDR='http://127.0.0.1:8200'

# I don't have a ~/go yet, but this is straight from the testvault README.
export GOPATH="$HOME/go"
export PATH="/usr/lib/go-1.10/bin:$PATH:$GOPATH/bin"
