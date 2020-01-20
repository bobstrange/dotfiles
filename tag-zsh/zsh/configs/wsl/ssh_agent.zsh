SSH_AGENT_FILE="$HOME/.ssh/ssh_agent_wsl"

[ -f $SSH_AGENT_FILE ] && source $SSH_AGENT_FILE >& /dev/null

if ! ssh-add -l >& /dev/null; then
  ssh-agent > $SSH_AGENT_FILE
  source $SSH_AGENT_FILE
  find $HOME/.ssh -name id_rsa | xargs ssh-add
fi
