.PHONY: main

NAME 	   	:= Agents
VERSION		:= 1.5
DEVELOPER	:= Ariel Plasencia Díaz
COPYRIGHT  	:= Copyright © 2022: $(DEVELOPER)

main: ## Compiling the project :)
	@echo "Compiling the project :)"

run: ## Run the project ;)
	runhaskell Main.hs

info: ## Display project description
	@echo "$(NAME) v$(VERSION)"
	@echo "$(COPYRIGHT)"

version: ## Show the project version
	@echo "$(NAME) v$(VERSION)"

install: ## Install the project dependencies
	sudo apt-get -y install libghc-mtl-dev
	sudo apt-get -y install libghc-random-dev

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
