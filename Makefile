.PHONY: help
help:
	echo "Read makefile for targets"

.PHONY: synapse
synapse:
	nix build '.#nixek-images.synapse'
	docker load -i ./result

.PHONY: syncplay-server
syncplay-server:
	nix build '.#nixek-images.syncplay-server'
	docker load -i ./result
