podman build -t yew_game_of_life:single -f Dockerfile.single
podman build -t yew_game_of_life:debug -f Dockerfile.debug
podman build -t yew_game_of_life:pyhttp -f Dockerfile.release.python
podman build -t yew_game_of_life:release -f Dockerfile.release
