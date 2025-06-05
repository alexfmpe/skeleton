repl = cabal repl lib:skeleton all

define ghcid
  ghcid                                       \
    -c '$(repl)'                              \
    --warnings                                \
    --restart 'skeleton/skeleton.cabal'
endef

all: build

.PHONY: hoogle
hoogle:
	hoogle server --local -p 8080

.PHONY: build
build:
	cabal build all

.PHONY: repl
repl:
	$(repl)

.PHONY: watch
watch:
	$(ghcid)

.PHONY: run
run:
	$(ghcid)                           \
	--test 'Skeleton.Main.main'
