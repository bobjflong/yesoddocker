FROM heroku/cedar:14

# Install packages required to add users and install Nix
RUN apt-get update && apt-get install -y curl bzip2 adduser

# Add the user bob for security reasons and for Nix
RUN adduser --disabled-password --gecos '' bob

# Nix requires ownership of /nix.
RUN mkdir -m 0755 /nix && chown bob /nix

# Change docker user to bob
USER bob

# Set some environment variables for Docker and Nix
ENV USER bob

# Change our working directory to $HOME
WORKDIR /home/bob

# install Nix
RUN curl https://nixos.org/nix/install | sh

# update the nix channels
# Note: nix.sh sets some environment variables. Unfortunately in Docker
# environment variables don't persist across `RUN` commands
# without using Docker's own `ENV` command, so we need to prefix
# our nix commands with `. .nix-profile/etc/profile.d/nix.sh` to ensure
# nix manages our $PATH appropriately.
RUN . .nix-profile/etc/profile.d/nix.sh && nix-channel --update && nix-env -iA nixpkgs.haskellngPackages.cabal-install
RUN . .nix-profile/etc/profile.d/nix.sh && nix-env -iA nixpkgs.haskellngPackages.cabal2nix

ADD . ebs-example

WORKDIR ebs-example

USER root
RUN chown -R bob /home/bob/ebs-example
RUN chmod -R 777 /home/bob/ebs-example/dist

USER bob

EXPOSE 4567

RUN . ~/.nix-profile/etc/profile.d/nix.sh && cabal2nix --shell . > shell.nix
RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-shell --command 'cabal configure'
RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-shell --command 'cabal build'

CMD /home/bob/ebs-example/dist/ebs-example/ebs-example