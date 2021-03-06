function __path_prompt__() { # カレントディレクトリのpathを画面の横幅に応じて短縮する。
  local -r pwd=$(pwd | sed "s@${HOME}@~@")
  local num
  # 表示するディレクトリ名の文字数を決める
  let num=$(expr $(tput cols) - 55 | xargs -I{} sh -c 'test 1 -gt {} && echo 1 || echo {}')/$(echo ${pwd} | grep -o '[~/]' | wc -l)
  [[ 0 -eq ${num} ]] && num=1

  stylish_prompt="%{${fg[blue]}${bg[black]}%}%n %{${fg[black]}${bg[blue]}%}%{${fg[black]}${bg[blue]}%} $(echo ${pwd} | sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g") %{${reset_color}${fg[blue]}%} "

  [[ ${OSTYPE} == 'linux-gnu' && -n ${WINDOWID} && $(ps hco cmd ${PPID}) != 'nvim' ]] \
    && PROMPT=${stylish_prompt} && return
  [[ ${OSTYPE} =~ 'darwin' && $(ps co comm ${PPID} | tail -1) != 'nvim' ]] \
    && PROMPT=${stylish_prompt} && return
  PROMPT="%n ${fg[blue]}$(sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g" <<< ${pwd})${reset_color} "
}
add-zsh-hook precmd __path_prompt__

function __git_prompt__() {
  RPROMPT=''
  [[ -z ${commands[git]} ]] && return 1
  git status &> /dev/null || return 1
  local -ar git_info=("${(f)$(git status --porcelain --branch)}")
  local -r icon=''
  local branch="${icon} $(sed 's/## \([^\.]*\).*/\1/' <<< ${git_info[1]})"

  if [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[ahead .*]' ]]; then
    branch="%{${fg_bold[blue]}%}${branch}%{${reset_color}%}"
  elif [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[behind .*]' ]]; then
    branch="%{${fg_bold[red]}%}${branch}%{${reset_color}%}"
  else
    branch="%{${fg_bold[green]}%}${branch}%{${reset_color}%}"
  fi

  local file uncommited=0 unadded=0 untracked=0
  for file in ${git_info[2,-1]}; do
    if [[ $(cut -c1-2 <<< ${file}) == '??' ]]; then
      (( untracked++ ))
    elif [[ $(cut -c1-2 <<< ${file}) =~ '( |M|A|R|U)(M|D|U)' ]]; then
      (( unadded++ ))
    elif [[ $(cut -c1-2 <<< ${file}) =~ '(M|A|R|D) ' ]]; then
      (( uncommited++ ))
    fi
  done

  function format_status() {
    [[ 0 -ne ${1} ]] \
      && echo "%{${fg[${2}]}%}${3}${1}%{${reset_color}%} "
  }

  RPROMPT="${branch} $(format_status ${uncommited} 'yellow' '!')$(format_status ${unadded} 'red' '+')$(format_status ${untracked} 'green' '?')"
}
add-zsh-hook precmd __git_prompt__

# コマンド実行後にRPROMPTを非表示
setopt transient_rprompt
