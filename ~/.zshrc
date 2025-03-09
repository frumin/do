# Start SSH agent and add key if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check if ssh-agent is already running
   eval "$(ssh-agent -s)" > /dev/null
   ssh-add -q ~/.ssh/id_rsa 2>/dev/null
fi 