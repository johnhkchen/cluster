{
  description = "Reproducible Kubernetes development environment with kind, k3s, FluxCD, and Ansible";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Custom kubectl aliases and helpers
        kubectlAliases = pkgs.writeShellScriptBin "kubectl-aliases" ''
          # Common kubectl aliases
          alias k='kubectl'
          alias kg='kubectl get'
          alias kd='kubectl describe'
          alias ka='kubectl apply'
          alias kdel='kubectl delete'
          alias kl='kubectl logs'
          alias kx='kubectl exec -it'
          alias kns='kubectl config set-context --current --namespace'
          
          # Kind-specific aliases
          alias kind-create='kind create cluster --config'
          alias kind-load='kind load docker-image'
          alias kind-delete='kind delete cluster'
          
          # Flux aliases
          alias fl='flux'
          alias flr='flux reconcile'
          alias fls='flux get sources all'
          alias flk='flux get kustomizations'
          alias flh='flux get helmreleases'
          
          echo "Kubernetes development environment loaded!"
          echo "Available tools: kubectl, kind, k3s, flux, ansible, docker, helm"
          echo "Use 'kubectl-help' for common aliases"
        '';

        kubectlHelp = pkgs.writeShellScriptBin "kubectl-help" ''
          echo "=== Kubernetes Development Aliases ==="
          echo "k          = kubectl"
          echo "kg         = kubectl get"
          echo "kd         = kubectl describe"  
          echo "ka         = kubectl apply"
          echo "kdel       = kubectl delete"
          echo "kl         = kubectl logs"
          echo "kx         = kubectl exec -it"
          echo "kns        = kubectl config set-context --current --namespace"
          echo ""
          echo "=== Kind Aliases ==="
          echo "kind-create = kind create cluster --config"
          echo "kind-load   = kind load docker-image"
          echo "kind-delete = kind delete cluster"
          echo ""
          echo "=== Flux Aliases ==="
          echo "fl         = flux"
          echo "flr        = flux reconcile"
          echo "fls        = flux get sources all"
          echo "flk        = flux get kustomizations"
          echo "flh        = flux get helmreleases"
        '';

        # Environment setup script
        envSetup = pkgs.writeShellScriptBin "setup-k8s-env" ''
          # Create common directories
          mkdir -p ~/.kube
          mkdir -p ~/.ansible
          mkdir -p ./clusters
          mkdir -p ./manifests
          
          # Set up kind config directory
          mkdir -p ./kind-configs
          
          # Create basic kind config if it doesn't exist
          if [ ! -f "./kind-configs/basic.yaml" ]; then
            cat > ./kind-configs/basic.yaml << 'EOF'
          kind: Cluster
          apiVersion: kind.x-k8s.io/v1alpha4
          nodes:
          - role: control-plane
            extraPortMappings:
            - containerPort: 80
              hostPort: 8080
              protocol: TCP
            - containerPort: 443
              hostPort: 8443
              protocol: TCP
          - role: worker
          - role: worker
          EOF
            echo "Created basic kind config at ./kind-configs/basic.yaml"
          fi
          
          # Create ansible.cfg if it doesn't exist
          if [ ! -f "./ansible.cfg" ]; then
            cat > ./ansible.cfg << 'EOF'
          [defaults]
          host_key_checking = False
          inventory = ./inventory
          remote_user = root
          private_key_file = ~/.ssh/id_rsa
          
          [inventory]
          enable_plugins = host_list, script, auto, yaml, ini, toml
          EOF
            echo "Created ansible.cfg"
          fi
          
          echo "Environment setup complete!"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core Kubernetes tools
            kubectl
            kubernetes-helm
            kind
            k3s
            fluxcd
            kustomize
            
            # Infrastructure automation
            ansible
            ansible-lint
            
            # Container tools
            docker
            docker-compose
            podman
            
            # Development tools
            git
            jq
            yq-go
            curl
            wget
            
            # Text editors and utilities
            vim
            nano
            tree
            bat
            
            # Network tools
            nettools
            tcpdump
            
            # Custom scripts
            kubectlAliases
            kubectlHelp
            envSetup
          ];

          shellHook = ''
            # Source kubectl aliases
            source ${kubectlAliases}/bin/kubectl-aliases
            
            # Set up environment variables
            export KUBECONFIG="$HOME/.kube/config"
            export ANSIBLE_CONFIG="./ansible.cfg"
            export KIND_CLUSTER_NAME="dev-cluster"
            
            # Docker environment (if using Docker Desktop or similar)
            export DOCKER_HOST="unix:///var/run/docker.sock"
            
            # Flux environment
            export FLUX_FORWARD_NAMESPACE="flux-system"
            
            # Colors for better terminal experience
            export TERM="xterm-256color"
            
            # Add current directory bins to PATH for local scripts
            export PATH="./bin:$PATH"
            
            # Initialize environment
            setup-k8s-env
            
            echo "=== Kubernetes Development Environment ==="
            echo "Tools available:"
            echo "  kubectl $(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)"
            echo "  kind $(kind version 2>/dev/null)"
            echo "  k3s $(k3s --version 2>/dev/null | head -1 | cut -d' ' -f3)"
            echo "  flux $(flux version --client 2>/dev/null | grep 'flux version' | cut -d' ' -f3)"
            echo "  ansible $(ansible --version 2>/dev/null | head -1 | cut -d' ' -f2)"
            echo "  helm $(helm version --short 2>/dev/null)"
            echo ""
            echo "Run 'kubectl-help' for available aliases"
            echo "Run 'setup-k8s-env' to reinitialize project structure"
          '';
        };

        # Additional shells for specific use cases
        devShells.minimal = pkgs.mkShell {
          buildInputs = with pkgs; [
            kubectl
            kind
            fluxcd
            git
            jq
          ];
          shellHook = ''
            echo "=== Minimal Kubernetes Environment ==="
            echo "Available: kubectl, kind, flux, git, jq"
          '';
        };

        devShells.ansible = pkgs.mkShell {
          buildInputs = with pkgs; [
            ansible
            ansible-lint
            kubectl
            k3s
            git
            jq
            yq-go
          ];
          shellHook = ''
            echo "=== Ansible + Kubernetes Environment ==="
            echo "Available: ansible, kubectl, k3s, git, jq, yq"
            export ANSIBLE_CONFIG="./ansible.cfg"
          '';
        };

        # Packages that can be built
        packages = {
          kubectl-aliases = kubectlAliases;
          kubectl-help = kubectlHelp;
          setup-env = envSetup;
        };

        # Default package
        packages.default = envSetup;
      });
}
