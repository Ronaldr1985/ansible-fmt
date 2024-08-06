package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

import "tokenizer"

@test
test_next_tokenizer :: proc(t: ^testing.T) {
	input := `---

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

	tests := [?]struct{
		expected_type: tokenizer.Token_Type,
		expected_literal: string
	}{
		{tokenizer.START_IDENTIFIER, "---"},
		{tokenizer.ITEM_IDENTIFIER, "-"},
		{tokenizer.NAME, "name"},
		{tokenizer.COLON, ":"},
		{tokenizer.IDENTIFIER, "Install curl and wget"},
		{tokenizer.MODULE_APT_FQCN, "ansible.builtin.apt"},
		{tokenizer.COLON, ":"},
		{tokenizer.ARG_PKG, "pkg"},
		{tokenizer.COLON, ":"},
		{tokenizer.ITEM_IDENTIFIER, "-"},
		{tokenizer.IDENTIFIER, "curl"},
		{tokenizer.ITEM_IDENTIFIER, "-"},
		{tokenizer.IDENTIFIER, "wget"},
		{tokenizer.WHEN, "when"},
		{tokenizer.COLON, ":"},
		{tokenizer.ITEM_IDENTIFIER, "-"},
		{tokenizer.IDENTIFIER, "install_curl"},
		{tokenizer.ITEM_IDENTIFIER, "-"},
		{tokenizer.IDENTIFIER, "install_wget"},
		{tokenizer.END_IDENTIFIER, "..."},
		{tokenizer.EOF, ""}
	}


	toknzer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&toknzer, input)
	defer tokenizer.tokenizer_destroy(&toknzer)

	for test in tests {
		tok := tokenizer.next_token(&toknzer)

		testing.expectf(
			t,
			tok.type == test.expected_type,
			"Expected %v instead got %v",
			test.expected_type,
			tok.type,
		)

		testing.expectf(
			t,
			strings.compare(tok.literal, test.expected_literal) == 0,
			"Expected %v instead got %v",
			test.expected_literal,
			tok.literal,
		)

		tokenizer.token_destroy(&tok)
	}
}

format_string :: proc(input: string, allocator := context.allocator) -> (formatted_string: string) {
	t: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&t, input)
	defer tokenizer.tokenizer_destroy(&t)

	tokens := tokenizer.tokenize_string(input)
	defer delete(tokens)

	fmt.println(tokens)

	return
}

main :: proc() {
	input := `---

- name: Install
  ansible.builtin.apt:
    pkg:
      - curl
      - wget
  when:
    - install_curl
    - install_wget

...
`

}
