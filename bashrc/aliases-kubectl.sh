
# kubeswitch https://github.com/danielfoehrKn/kubeswitch
if command -v switcher &>/dev/null; then
  source <(switcher init bash)
  alias s=switch
  complete -o default -F _switcher s
fi

# kubectx https://github.com/ahmetb/kubectx
if command -v kubectx &>/dev/null; then
  alias kctx='kubectx'
fi

# kubens https://github.com/ahmetb/kubectx
if command -v kubens &>/dev/null; then
  alias kns='kubens'
fi

alias k='kubectl'

alias klogs='kubectl logs $1'
alias kdel='kubectl delete'
alias krr='kubectl rollout restart'

alias kbash='kubectl exec -it $1 -- /bin/bash'
alias ksh='kubectl exec -it $1 -- /bin/sh'

alias kd='kubectl describe'
alias kdpo='kubectl describe po'
alias kdsvc='kubectl describe svc'
alias kddeploy='kubectl describe deploy'
alias kdnodes='kubectl describe nodes'
alias kdnso='kubectl describe ns'

alias kg='kubectl get'
alias kgall='kubectl get all'
alias kgpods='kubectl get pods'
alias kgsvc='kubectl get svc'
alias kgdeploy='kubectl get deploy'
alias kgnodes='kubectl get nodes'
alias kgns='kubectl get ns'
alias kgpo='kubectl get po'
alias kgpoall='kubectl get po --all-namespaces'
alias kgpoo='kubectl get po -o wide'
alias kgsvc='kubectl get svc'
alias kgsvco='kubectl get svc -o wide'
alias kgdeploy='kubectl get deploy'
alias kgdeployo='kubectl get deploy -o wide'
alias kgnodes='kubectl get nodes'
alias kgnodeso='kubectl get nodes -o wide'
alias kgnso='kubectl get ns -o wide'
alias kgpoall='kubectl get po --all-namespaces'
alias kgpoallo='kubectl get po --all-namespaces -o wide'