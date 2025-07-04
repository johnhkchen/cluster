c7:
    claude mcp add context7 -- npx -y @upstash/context7-mcp

fluxcd:
    flux bootstrap github --owner=johnhkchen --repository=cluster --branch=main --path=./clusters/dev --personal
get_pods:
    kubectl get pods -n flux-system
