c7:
    claude mcp add context7 -- npx -y @upstash/context7-mcp

flux_reconcile:
    flux reconcile kustomization demo-hello --with-source

get_pods:
    kubectl get pods -n flux-system
