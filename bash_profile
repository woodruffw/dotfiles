# bash_profile

# new commands and command tweaks
alias cc99='gcc -O3 -std=c99 -Wall -Wno-unused-parameter -Wextra'
alias cc89='gcc -O3 -std=c89 -Wall -Wno-unused-parameter -Wextra'
alias cls='clear'
alias brew='brew -v'
alias update='brew update ; brew upgrade ; brew cleanup -s'
alias df='df -kth'
alias ls='ls -h -G -F'
alias bashreload='source ~/.bash_profile'
alias profile='vim ~/.bash_profile'
alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
alias nginxreload='sudo nginx -s reload'
alias please='sudo !!'
alias vi='vim'
alias vmi='vim'
alias vimrc='vim ~/.vimrc'
alias htop='htop --sort-key PERCENT_CPU'
alias mkexec='chmod +x'
alias lg='ls | grep'
alias ll='ls | less'
alias del='rm -i'
alias rr='env rm -r'
alias ttyreset='echo -e \\033c'

source ~/.git-aliases # load all aliases in git-aliases

# environment variable settings
export PATH=/usr/local/bin:/usr/local/sbin:/Users/admin/scripts:/Users/admin/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/X11/bin
export PS1="\u@\h [\t] \W \[\033[0;31m\]\$(parse_git_branch)\033[0m$ " 
export EDITOR='vim'

# prints the length of the first argument
function strlen()
{
  echo $1 | awk '{print length}'
}

# wp - working project
# cd to the working project, or set it if -s is tripped
function wp()
{
  if [ "$1" = "-s" ] ; then
    echo $2 > ~/.wp
  else
    DIR=`cat ~/.wp`
    cd $DIR
  fi
}

# cd - cat grep
# pipes cat into grep
function cg()
{
  cat $1 | grep $2
}

# nc - nasm compile
# quickly generates a binary from an assembly file and disposes of its object file
function nc()
{
  FILE=$1
  BASE=${FILE%%.*}
  nasm -f macho $1
  ld $BASE.o -o $BASE
  rm $BASE.o
}

# qc - quick compile
# compiles with cc99 (see alias above) and outputs to a file with a "good" name
function qc()
{
  FILE=$1
  BASE=${FILE%%.*}
  cc99 $FILE -o $BASE
}

# man - colorize man pages
# overloads the existing man command and supplements it with colors
function man()
{
  env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  man "$@"
}

# mkhtml - make html file
# creates a html file based upon a template stored in ~/.html_template
function mkhtml()
{
  cp ~/.html_template $1.html
}

# parse_git_branch
# prints the current branch in the current repo, or returns
# used in PS1
function parse_git_branch()
{
  ref=$(git symbolic-ref HEAD 2>/dev/null) || return
  echo "["${ref#refs/heads/}"] "
}

# prj - cd to projects
# cds to the project folder or to a specified project
function prj()
{
  if [[ -z "$1" ]]
  then
    cd ~/Dropbox/Programming/
  else
    cd ~/Dropbox/Programming/$1
  fi
}
