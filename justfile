# show available recipes
default:
    just -l

# dump the justfile structure
dump FORMAT:
    just --dump-format {{ FORMAT }} --dump | jq > just.json

say_hello:
    say hello

alias s := say_hello

dep:
    echo "is dep"
    say hello

has_dep: dep
    echo "has dep"
    say world
