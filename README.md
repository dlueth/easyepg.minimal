# easyepg.minimal
A minimal docker container for running easyepg

## Setup
Checkout this repo via `git clone` and run `make setup` afterwards. From within the containers console run `/entrypoint.sh` and follow easyepg's instructions to get up and running.

After finishing the setup utilize `make run` whenever you want to have your EPG xml files updated.

The container will store easyepg and its configuration in the directory `volume` of the cloned repo and keep it up to date on every invocation.  
