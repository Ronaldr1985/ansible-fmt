package test_tokenizer

import "core:strings"
import "core:testing"

import "../../tokenizer"

@test
test_advance_tokenizer :: proc(t: ^testing.T) {
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
		{tokenizer.Token_Type.Start_Identifier, "---"},
		{tokenizer.Token_Type.Hyphen, "-"},
		{tokenizer.Token_Type.Name, "name"},
		{tokenizer.Token_Type.Colon, ":"},
		{tokenizer.Token_Type.Identifier, "Install curl and wget"},
		{tokenizer.Token_Type.Module, "ansible.builtin.apt"},
		{tokenizer.Token_Type.Colon, ":"},
		{tokenizer.Token_Type.Argument, "pkg"},
		{tokenizer.Token_Type.Colon, ":"},
		{tokenizer.Token_Type.Hyphen, "-"},
		{tokenizer.Token_Type.Identifier, "curl"},
		{tokenizer.Token_Type.Hyphen, "-"},
		{tokenizer.Token_Type.Identifier, "wget"},
		{tokenizer.Token_Type.When, "when"},
		{tokenizer.Token_Type.Colon, ":"},
		{tokenizer.Token_Type.Hyphen, "-"},
		{tokenizer.Token_Type.Identifier, "install_curl"},
		{tokenizer.Token_Type.Hyphen, "-"},
		{tokenizer.Token_Type.Identifier, "install_wget"},
		{tokenizer.Token_Type.End_Identifier, "..."},
		{tokenizer.Token_Type.EOF, ""}
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

		tokenizer.token_destroy(&tok)
	}
}

