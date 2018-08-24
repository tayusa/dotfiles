typeset -gr node_funcs=(
  'nvm'
  'node'
  'npm'
  'ng'
  'create-react-app'
)

function init_nvm() { # nvm(Node.jsのversion管理)の初期設定を読み込む
  unset -f $@
  local nvm_dir='/usr/share/nvm'
  [[ -e "${nvm_dir}/nvm.sh" ]] && source "${nvm_dir}/nvm.sh"
  # zshの自作補完関数が全て開放される。防ぐ方法がわからない。
  # [[ -e "${nvm_dir}/bash_completion" ]] && source "${nvm_dir}/bash_completion"
}

for func in ${node_funcs}; do
  function ${func} {
    init_nvm ${node_funcs}
    $0 $@
  }
done
