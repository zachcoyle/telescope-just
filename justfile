# show available recipes
default:
    just -l

# dump the justfile structure
dump FORMAT:
    just --dump-format {{ FORMAT }} --dump | jq > just.json

say THIS THAT:
    sleep 2; say {{ THIS }}; sleep 2; say {{ THAT }}

say_hello:
    just say hello world;

alias s := say_hello

dep:
    echo "is dep"
    say hello

has_dep: dep
    echo "has dep"
    say world
