music_path="${HOME}/Dropbox/Radio"
alias af_pause="pgrep afplay | xargs kill -STOP"
alias af_resume="pgrep afplay | xargs kill -CONT"
alias af_stop="pkill afplay"
alias af_playing="ps axu|grep [a]fplay|awk '{print $12}'"
