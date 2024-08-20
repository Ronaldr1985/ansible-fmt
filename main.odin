package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"

import "tokenizer"
import "parser"

format_string :: proc(input: string, allocator := context.allocator) -> (formatted_string: string) {
	t: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&t, input)
	defer tokenizer.tokenizer_destroy(&t)

	tokens := tokenizer.tokenize_string(input)
	defer delete(tokens)

	fmt.println(tokens)

	return
}

_main :: proc() {
	input := `
---

- name: Install curl and wget
  ansible.builtin.apt:
    pkg:
      - curl
      - wget
  when:
    - install_curl
    - install_wget

...

`

	file, err := parser.parse_string(input)
	defer parser.file_destroy(&file)
	if err != nil {
		fmt.eprintln("Failed to parse")
		return
	}
	num_plays := len(file.plays)
	fmt.println(file)

}

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	_main()

	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}

