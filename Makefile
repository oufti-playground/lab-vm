
export BOX_VERSION ?= 1.4.0
export BOX_NAME ?= jenkins-lab-demo
export BOX_FILE ?= $(CURDIR)/jenkins-lab-demo.box
GIT_SUBPROJECT := alpine2docker
CUSTOMIZE_DIR := $(GIT_SUBPROJECT)/customize
TMP_LAB_DIR := ./tmp-lab
EXTERNAL_PORT ?= 443
TESTS_URL ?= https://localhost:$(EXTERNAL_PORT)
export DOCKER_USERNAME ?= dduportal

all: box lab

lab: clean-lab init-lab start-lab

clean: clean-lab clean-box

box: clean-box build-box test clean-box

docker:
	cd ./docker && docker-compose build

docker-deploy:
	cd ./docker && docker-compose push

build-box: $(BOX_FILE)

build-aws:
	packer build -only=aws $(CURDIR)/packer.json

deploy-aws:
	@cd deploy/aws; terraform apply

test:
	TESTS_URL=$(TESTS_URL) bats $(CURDIR)/tests/*.bats

$(BOX_FILE):
	cp -r ./docker/ ./$(CUSTOMIZE_DIR)
	cp ./vagrantfile-box.tpl ./$(GIT_SUBPROJECT)/
	cd $(GIT_SUBPROJECT) && make all

init-lab:
	vagrant box add --force $(BOX_NAME)-lab $(BOX_FILE)
	mkdir -p $(TMP_LAB_DIR)
	cd $(TMP_LAB_DIR) && vagrant init -m -f $(BOX_NAME)-lab

start-lab:
	cd $(TMP_LAB_DIR) && vagrant up

suspend-lab:
	cd $(TMP_LAB_DIR) && vagrant suspend

clean-lab:
	cd $(TMP_LAB_DIR) && vagrant destroy -f || true
	rm -rf $(TMP_LAB_DIR)
	vagrant global-status --prune

clean-box:
	rm -rf $(BOX_FILE) $(CUSTOMIZE_DIR)
	cd $(GIT_SUBPROJECT) && git checkout .

.PHONY: all lab box clean build-box clean-box start-lab clean-lab \
	suspend-lab test docker docker-deploy
