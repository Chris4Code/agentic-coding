# Makefile for the Agentic Coding book (mdBook)
#
# Common targets:
#   make install   install mdbook + preprocessors into ~/.local/bin
#   make build     render the book into book/
#   make serve     serve the book locally with live reload
#   make help      list all targets

# ---- Configuration ---------------------------------------------------------

PREFIX      ?= $(HOME)/.local
BIN_DIR     := $(PREFIX)/bin
SERVE_HOST  ?= localhost
SERVE_PORT  ?= 3000
BOOK_DIR    := book
SRC_DIR     := src

# GitHub repos for the prebuilt Linux binaries (see README.md).
MDBOOK_REPO     := rust-lang/mdBook
MERMAID_REPO    := badboy/mdbook-mermaid
LINKCHECK_REPO  := marxin/mdbook-linkcheck2

# Pick an available downloader.
DL := $(shell command -v wget >/dev/null 2>&1 && echo "wget -qO-" || echo "curl -fsSL")

.DEFAULT_GOAL := help

# ---- Help ----------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@echo "Agentic Coding book - available targets:"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Variables: PREFIX=$(PREFIX)  SERVE_HOST=$(SERVE_HOST)  SERVE_PORT=$(SERVE_PORT)"

# ---- Install -----------------------------------------------------------

.PHONY: install
install: $(BIN_DIR)/mdbook $(BIN_DIR)/mdbook-mermaid $(BIN_DIR)/mdbook-linkcheck2 ## Install mdbook + preprocessors into ~/.local/bin
	@echo
	@echo "Installed into $(BIN_DIR). Ensure it is on your PATH."
	@$(MAKE) --no-print-directory versions

# Download the latest release tarball for a repo and extract one binary from it.
# $(1) = binary name, $(2) = GitHub repo
define install_gh_binary
	@echo ">> installing $(1) from $(2)"
	@mkdir -p $(BIN_DIR)
	@tmp=$$(mktemp -d) && \
	url=$$($(DL) https://api.github.com/repos/$(2)/releases/latest \
		| grep -o 'https://[^"]*x86_64-unknown-linux-gnu\.tar\.gz' | head -n1) && \
	if [ -z "$$url" ]; then echo "could not resolve release URL for $(2)" >&2; exit 1; fi && \
	echo "   $$url" && \
	$(DL) "$$url" > "$$tmp/dl.tar.gz" && \
	tar xzf "$$tmp/dl.tar.gz" -C "$$tmp" && \
	install -m 0755 "$$tmp/$(1)" "$(BIN_DIR)/$(1)" && \
	rm -rf "$$tmp"
endef

$(BIN_DIR)/mdbook:
	$(call install_gh_binary,mdbook,$(MDBOOK_REPO))

$(BIN_DIR)/mdbook-mermaid:
	$(call install_gh_binary,mdbook-mermaid,$(MERMAID_REPO))

$(BIN_DIR)/mdbook-linkcheck2:
	$(call install_gh_binary,mdbook-linkcheck2,$(LINKCHECK_REPO))

.PHONY: mermaid-assets
mermaid-assets: ## Regenerate mermaid JS/CSS assets referenced by book.toml
	mdbook-mermaid install .

.PHONY: versions
versions: ## Print versions of the installed toolchain
	@mdbook --version 2>/dev/null            || echo "mdbook: not found"
	@mdbook-mermaid --version 2>/dev/null    || echo "mdbook-mermaid: not found"
	@mdbook-linkcheck2 --version 2>/dev/null || echo "mdbook-linkcheck2: not found"

# ---- Build / serve -------------------------------------------------------

.PHONY: build
build: ## Render the book into book/
	mdbook build

.PHONY: serve
serve: ## Serve the book locally with live reload (SERVE_HOST/SERVE_PORT)
	mdbook serve --hostname $(SERVE_HOST) --port $(SERVE_PORT)

.PHONY: watch
watch: ## Rebuild the book on every source change (no server)
	mdbook watch

.PHONY: clean
clean: ## Remove the build output
	mdbook clean || rm -rf $(BOOK_DIR)
