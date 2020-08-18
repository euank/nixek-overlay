.PHONY: synapse
synapse:
	nix-build -A nixek-images.synapse ./resolved.nix
	docker load -i ./result
