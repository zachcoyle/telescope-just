# show available recipes
default:
    just -l

# dump the justfile structure
dump FORMAT:
    just --dump-format {{ FORMAT }} --dump | jq > just.json

say_hello:
    say hello
