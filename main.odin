package main

import "core:fmt"
import "core:os"
import "core:testing"

import "lexer"
import "token"

@test
test_next_token :: proc(t: ^testing.T) {
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

	tests := [?]struct{
		expected_type: token.Token_Type,
		expected_literal: string
	}{
		{token.START_IDENTIFIER, "---"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.NAME, "name"},
		{token.COLON, ":"},
		{token.IDENTIFIER, "Install"},
		{token.MODULE_APT_FQCN, "ansible.builtin.apt"},
		{token.COLON, ":"},
		{token.ARG_PKG, "pkg"},
		{token.COLON, ":"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "curl"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "wget"},
		{token.WHEN, "when"},
		{token.COLON, ":"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "install_curl"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "install_wget"},
		{token.END_IDENTIFIER, "..."},
		{token.EOF, ""}
	}


	l: lexer.Lexer
	lexer.lexer_init(&l, input)
	defer lexer.lexer_destroy(&l)

	for test in tests {
		tok := lexer.next_token(&l)

		testing.expectf(
			t,
			tok.type == test.expected_type,
			"Expected %v instead got %v",
			test.expected_type,
			tok.type,
		)

		token.token_destroy(&tok)
	}
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

	tests := [?]struct{
		expected_type: token.Token_Type,
		expected_literal: string
	}{
		{token.START_IDENTIFIER, "---"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.NAME, "name"},
		{token.COLON, ":"},
		{token.IDENTIFIER, "Install"},
		{token.MODULE_APT_FQCN, "ansible.builtin.apt"},
		{token.COLON, ":"},
		{token.ARG_PKG, "pkg"},
		{token.COLON, ":"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "curl"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "wget"},
		{token.WHEN, "when"},
		{token.COLON, ":"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "install_curl"},
		{token.ITEM_IDENTIFIER, "-"},
		{token.IDENTIFIER, "install_wget"},
		{token.END_IDENTIFIER, "..."},
		{token.EOF, ""}
	}

	l: lexer.Lexer
	lexer.lexer_init(&l, input)
	defer lexer.lexer_destroy(&l)

	for test in tests {
		tok := lexer.next_token(&l)

		if tok.type == test.expected_type {
			continue
		}

		fmt.println("Expected literal", test.expected_literal, "got literal", tok.literal)
		fmt.println( "Expected", test.expected_type, "got", tok.type)
		fmt.println()

		token.token_destroy(&tok)
	}

}
