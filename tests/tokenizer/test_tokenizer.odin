package test_tokenizer

import "core:strings"
import "core:testing"

import "../../tokenizer"

@test
test_advance_tokenizer :: proc(t: ^testing.T) {
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

	tests := [?]struct{
		expected_type: tokenizer.Token_Type,
		expected_literal: string,
		line: int,
		column: int,
	}{
		{tokenizer.Token_Type.Start_Identifier, "---", 1, 0},
		{tokenizer.Token_Type.Hyphen, "-", 3, 0},
		{tokenizer.Token_Type.Name, "name", 3, 2},
		{tokenizer.Token_Type.Colon, ":", 3, 6},
		{tokenizer.Token_Type.Identifier, "Install curl and wget", 3, 8},
		{tokenizer.Token_Type.Module, "ansible.builtin.apt", 4, 2},
		{tokenizer.Token_Type.Colon, ":", 4, 21},
		{tokenizer.Token_Type.Argument, "pkg", 5, 4},
		{tokenizer.Token_Type.Colon, ":", 5, 7},
		{tokenizer.Token_Type.Hyphen, "-", 6, 6},
		{tokenizer.Token_Type.Identifier, "curl", 6, 8},
		{tokenizer.Token_Type.Hyphen, "-", 7, 6},
		{tokenizer.Token_Type.Identifier, "wget", 7, 8},
		{tokenizer.Token_Type.When, "when", 8, 2},
		{tokenizer.Token_Type.Colon, ":", 8, 6},
		{tokenizer.Token_Type.Hyphen, "-", 9, 4},
		{tokenizer.Token_Type.Identifier, "install_curl", 9, 6},
		{tokenizer.Token_Type.Hyphen, "-", 10, 4},
		{tokenizer.Token_Type.Identifier, "install_wget", 10, 6},
		{tokenizer.Token_Type.End_Identifier, "...", 12, 0},
		{tokenizer.Token_Type.EOF, "", 13, 0}
	}


	toknzer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&toknzer, input)
	defer tokenizer.tokenizer_destroy(&toknzer)

	for test in tests {
		tok := tokenizer.advance_token(&toknzer)

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

		testing.expectf(
			t,
			tok.line == test.line,
			"Expected token %v (%v) to be on line %v instead got %v",
			tok.type,
			tok.literal,
			test.line,
			tok.line,
		)

		testing.expectf(
			t,
			tok.column == test.column,
			"Expected token %v (%v) line: %v) to be in column %v instead got %v",
			tok.type,
			tok.literal,
			tok.line,
			test.column,
			tok.column,
		)


		tokenizer.token_destroy(&tok)
	}
}

