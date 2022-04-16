.PHONY: run

run-ubuntu:
	ansible-playbook ansible/main.yml \
		-i ansible/hosts.ini \
		-l local_ubuntu \
		--ask-become-pass \
		-vvv
