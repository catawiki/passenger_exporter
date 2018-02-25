VERSION   := $(shell cat VERSION)
BIN       := passenger_exporter
CONTAINER := passenger_exporter
GOOS      ?= linux
GOARCH    ?= amd64

GOFLAGS   := -ldflags "-X main.Version=$(VERSION)" -a -installsuffix cgo
TAR       := $(BIN)-$(VERSION)-$(GOOS)-$(GOARCH).tar.gz
DST       ?= http://ent.int.s-cloud.net/iss/$(BIN)

PREFIX    ?= $(shell pwd)

GO           := GO15VENDOREXPERIMENT=1 go
FIRST_GOPATH := $(firstword $(subst :, ,$(shell $(GO) env GOPATH)))
PROMU        := $(FIRST_GOPATH)/bin/promu

default: $(BIN)

$(BIN):
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) $(PROMU) build --prefix $(PREFIX)

release: $(TAR)
	curl -XPOST --data-binary @$< $(DST)/$<

build-docker: $(BIN)
	docker build -t $(CONTAINER) .

$(TAR): $(BIN)
	tar czf $@ $<

