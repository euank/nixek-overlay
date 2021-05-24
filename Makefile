.PHONY: synapse
synapse:
	nix build '.#nixek-images.synapse'
	docker load -i ./result
