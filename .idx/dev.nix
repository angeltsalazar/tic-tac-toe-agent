# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.fastapi
    python311Packages.uvicorn
    python311Packages.websockets
    python311Packages.python-socketio
    python311Packages.numpy
    python311Packages.python-multipart
    python311Packages.pydantic
  ];

  # Sets environment variables in the workspace
  env = {
    PYTHONPATH = "./server";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      # "vscodevim.vim"
    ];

    # Enable previews
    previews = {
      enable = true;
      previews = {
        web = {
          # Example: run "npm run dev" with PORT set to IDX's defined port for previews,
          # and show it in IDX's web preview panel
          command = ["python3" "-m" "uvicorn" "server.server:app" "--reload" "--port" "$PORT"];
          manager = "web";
          env = {
            # Environment variables to set for your server
            # PORT = "$PORT";
          };
        };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        # Example: install JS dependencies from NPM
        # npm-install = "npm install";
      };
      # Runs when the workspace is (re)started
      onStart = {
        # Example: start a background task to watch and re-build backend code
        # watch-backend = "npm run watch-backend";
        # Example: start the server using uvicorn
        #start-server = "uvicorn server.server:app --reload"; 
      };
    };
  };
}
