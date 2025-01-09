# Using https://github.com/romkatv/powerlevel10k
# Enable Powerlevel10k instant prompt. Keep this close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

# platform-specific code
source ~/.zshrc-$( uname -s )

# zsh functions
ZDOTDIR=~/.zfunc
fpath+=$ZDOTDIR

# 'help' command
autoload -Uz run-help
unalias run-help 2>/dev/null
alias help=run-help

# Networking
listener() {  # what process is listening on port $1
  echo LSOF:   ; lsof -iTCP -sTCP:LISTEN -P -n | sed -ne   1p -e /:$1/p
  echo NETSTAT:; sudo netstat -tnlp            | sed -ne 1,2p -e /:$1/p
}
port_status() { nmap -sT -p $1 $2; }  # port 8200 $lab: open/closed (firewalled?)
tcp_port() {
  sudo tcpdump -i any -A -s 1024 port $1
}

export HISTSIZE=10000
export SAVEHIST=10000

setopt \
  always_to_end \
  auto_cd \
  auto_pushd \
  auto_param_keys \
  auto_param_slash \
  auto_remove_slash \
  auto_name_dirs \
  complete_aliases \
  complete_in_word \
  list_packed \
  list_types \
  extended_glob \
  case_glob \
  case_match \
  magic_equal_subst \
  numeric_glob_sort \
  rc_expand_param \
  extended_history \
  inc_append_history \
  hist_allow_clobber \
  hist_ignore_space \
  hist_ignore_dups \
  cdablevars \
  pushd_ignore_dups \
  noclobber \
  path_dirs \
  long_list_jobs \
  multios \
  pipe_fail \
  interactive_comments

# glob_star_short \

########## Basics

alias a=alias

alias e=echo
alias m=bat
alias v=hx

alias \?='noglob whence -vafsm'

alias fn='zed -f'
compctl -F fn

alias rmb='rm (|.)*~'
alias rmbr='rm **/(|.)*~'

alias dos2unix=fromdos

alias top=zenith

alias cx='chmod +x'

alias wsdiff='sdiff -w227'

alias nobuf='stdbuf -oL'  # actually, it's still buffered by line

setenv() { export $1="$2" }     # for compatibility with simple csh scripts

say+do() { echo "$@"; "$@" }            # say it, then do it
warn()   { echo "$@" 1>&2 }             # say to stderr

diskhogs() { du -ak | sed -n '/^[0-9]\{3\}/p' | sort -rn | $PAGER }
 cpuhogs() { ps -eo pcpu,pid,user,comm        | sort -rn | $PAGER }

psg () { ps -ef | egrep    "$*|UID" | grep -v 'grep .*UID' }
psgi() { ps -ef | egrep -i "$*|UID" | grep -v 'grep .*UID' }

# ripgrep with results through delta
rgd() { rg --json -C 2 "$1" | delta }

# sk (skim) is like fzf
# skr is skim by ripgrep
# e.g. skr -g "**/*.dart"
skr () { sk    --ansi -i -c "rg --color=always --line-number \"{}\" $*" }
skmr() { sk -m --ansi -i -c "rg --color=always --line-number \"{}\" $*" }

# echo a b c d | col 2   prints b
# col : 1 /etc/passwd    prints usernames
# overrides useless /usr/bin/col
col() {
  local n="$1"
  shift
  if [[ "$n" =~ ^[0-9]+$ ]]; then
    gawk "{ print \$$n }" "$@"
  else
    local delim="$n"
    n="$1"
    shift
    gawk -F"$delim" "{ print \$$n }" "$@"
  fi
}

########## .z* Files

alias  .z='source ~/.{zprofile,zshenv,zshrc}'
alias v.profile='v ~/.zprofile'
alias v.z='v ~/.zshrc'
alias v.env='v ~/.zshenv'

########## History stuff

alias h='history -iD'
alias gethistory='fc -RI'
alias -g ,m='$(eval `fc -ln -1`)'  # output of last cmd (which gets re-executed)

########## Line stuff

# Prints each arg on a separate line.
lines() { print -lr "$@"; }

# Prints lines w line nums.
alias num='nl -ba'

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
    num="$1"
    shift
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

# lns makes a symlink, removing an existing one.
lns() {
  rm "$2"
  ln -s "$1" "$2"
}

# nd names a directory; cnd cd's to a named directory (for completion).
nd () { export $1="${2:-$PWD}"; : ~$1 }
cnd() { cd "$1" }
compctl -n cnd

# ls stuff
alias  l='eza -F -bh'
alias la='eza -F -bha'
#alias ll='ls -C -FbhlA'
alias ll='eza -F -bhla'
lfbt() {  # files under ${2:-.} larger than $1 Mbytes, largest-first
  ll -S ${2:-.}/**/*(Lm+$1)
}
lt() {
  eza --tree -lF --git --ignore-glob='target|.git|.idea' --sort=age "$@"
}
alias lt2='lt -L2'
alias lt3='lt -L3'
alias lt4='lt -L4'

# TREE stuff
alias td='tree -d'         # just the dirs
alias tf='tree -FC'        # all file types
alias tm='noglob tf -P'    # ..     matching this pattern
alias tn='noglob tf -I'    # .. not matching this pattern

# Yazi file manager
function f() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Edit a var.
vv() {
  # I'd like to be able to edit arrays with each element
  # on a separate line, but ${(t)$1} doesn't work.
  #if [ ${(t)${1}} = array ]; then
  #  local _var=$( ${(P)${1}} )
  #  vared _var
  #  $1=( "${=_var}" )
  #else
  #  vared ${1}
  #fi
  vared ${1}
}
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
    local lpath=$( path )
    vared lpath
    path=( "${=lpath}" )
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

gnotes() {
  cat <<EOF
  gd br1..br2     br2 - br1
  gd br1...br2    br2 - common_ancestor(br1,br2)
  Add "-- file" to restrict the diff to a file
  gll br1..br2     commits
EOF
}

alias gd='git diff'             # unstaged
alias gds='git diff --staged'   #   staged
alias gdh='git diff HEAD'       # all

alias gs='git status'
alias gt='git switch'       # Git To
alias gk='git checkout'
alias gnb='git checkout -b' # Git New Branch
alias gp='git pull'
alias ga='git add'
alias gm='git commit -m'
alias gma='git commit -am'
alias gpa='git push --all'

gmp() { git commit -m "$@" && git push }

gll() {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "$@"
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

alias ports="lsof -i"

# Strips out #-based comments and blank lines.
strip\# () {
  sed -e 's/#.*//' -e '/^[ 	]*$/d' "$@"
}

alias cstyle='indent -kr -i4 -nut -l120'

trace() {
  strace -f -s 10000 -y -yy -o ~/strace.out "$@"
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
alias cu-yaml=" noglob cu-yaml_ "
alias cu-csv="  noglob cu-csv_  "
alias cu-text=" noglob cu-text_ "
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
alias calc='noglob calc_'
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
alias      ,='calc'
alias      0='calc 0.0'
alias      1='calc 1.0'
alias      2='calc 2.0'
alias -- '+'='calc z +'
alias -- '-'='calc z -'
alias -- '*'='calc z *'
alias -- '/'='calc z /'
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

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# .... => ../../..   https://github.com/knu/zsh-manydots-magic
autoload -Uz manydots-magic
manydots-magic

# Misc
alias nr='npm run'
alias nra='nr buildn && nr build-local'
alias nrr='RUST_BACKTRACE=1 nr runel'

# I don't know why this was here; do we need it?
#export PATH="$HOME/.rbenv/bin:$PATH"
#eval "$(rbenv init -)"
#export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
#

# Set up prompt.  https://starship.rs
# eval "$(starship init zsh)"

a git_syms='open https://github.com/romkatv/powerlevel10k#what-do-different-symbols-in-git-status-mean'

# Bazel
bb() {
  if [ $# = 0 ]; then
    say+do bazel build '...'
  else
    say+do bazel build "$@"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.zfunc/.p10k.zsh.
[[ ! -f ~/.zfunc/.p10k.zsh ]] || source ~/.zfunc/.p10k.zsh

# For Virdio, change the file that gets plotted.
plotting() {
  ll tracker.txt
  rm -f tracker.txt.old
  mv tracker.txt tracker.txt.old
  lns "$1" tracker.txt
  ll tracker.txt
}

curl-ext() {
  curl "$2" | sed -n 's/.*[ "]\(.*\.'"$1"'\)[ "].*/\1/p'
}

curl-into() {
  curl --remote-name --output-dir "$1" "$2"
}

# broot; largely replaced by yazi
# source /Users/ns/.config/broot/launcher/bash/br

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export MODULAR_HOME="/Users/ns/.modular"
export PATH="/Users/ns/.modular/pkg/packages.modular.com_max/bin:$PATH"

# atuin does our history
# zoxide is our cd, but as d

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

eval "$(zoxide init zsh)"
