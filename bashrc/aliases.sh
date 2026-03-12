alias ll='ls -lah --color=auto'       # detailed listing with human sizes + colors
alias cls='clear'                      # quick screen clear
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias df='df -hT'                      # human-readable disk usage + filesystem type
alias free='free -h'                   # human-readable memory
alias du='du -sh * | sort -h'          # summarize folder sizes, sorted
alias now='date +"%Y-%m-%d %H:%M:%S"'  # quick timestamp
alias ports='ss -tulnp'                # listening ports + processes (better than netstat)
alias myip='curl -s ifconfig.me'       # external IP address
alias ipinfo='curl -s ipinfo.io'       # detailed IP info