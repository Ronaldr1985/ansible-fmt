package tokenizer

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:unicode"

// TODO: Add allocator paramter to allow for custom allocation
// TODO: Maybe error handling?  strings.clone can fail ^
token_init :: proc(tok: ^Token, type: Token_Type, ch: rune) {
	tok.type = strings.clone(type)
	tok.literal = fmt.aprintf("%v", ch)
}

token_destroy :: proc(tok: ^Token) {
	delete(tok.type)
	delete(tok.literal)
}

lookup_identifier :: proc(identifier: string) -> Token_Type {
	upper := strings.to_upper(identifier)
	defer delete(upper)
	if token_type, ok := Keywords[upper]; ok {
		return token_type
	}

	return IDENTIFIER
}

tokenizer_init :: proc(t: ^Tokenizer, input: string) -> (err: runtime.Allocator_Error) {
	t.input, err = strings.clone(input)

	read_char(t)

	return err
}

tokenizer_destroy :: proc(t: ^Tokenizer) {
	delete(t.input)
}

read_char :: proc(t: ^Tokenizer) {
	if t.read_position >= len(t.input) {
		t.ch = 0
	} else {
		t.ch = rune(t.input[t.read_position])
	}
	t.position = t.read_position
	t.read_position += 1
}

next_token :: proc(t: ^Tokenizer) -> (tok: Token) {
	skip_whitespace :: proc(t: ^Tokenizer) {
		for t.ch == ' ' || t.ch == '\t' || t.ch == '\n' || t.ch == '\r' {
			read_char(t)
		}
	}

	is_letter :: proc(r: rune) -> bool {
		return unicode.is_letter(r) || r == '_' || r == '.' || r == ' '
	}

	read_identifier :: proc(t: ^Tokenizer) -> string {
		position := t.position

		for is_letter(t.ch) {
			read_char(t)
		}

		return t.input[position:t.position]
	}

	skip_whitespace(t)

	switch t.ch {
	case '-':
		if t.input[t.read_position] == '-' && t.input[t.read_position+1] == '-' {
			tok.literal = strings.clone("---")
			tok.type = strings.clone(START_IDENTIFIER)
			t.position += 2
			t.read_position += 2
			t.ch = rune(t.input[t.read_position])
		} else {
			token_init(&tok, ITEM_IDENTIFIER, t.ch)
		}
	case ':':
		token_init(&tok, COLON, t.ch)
	case '(':
		token_init(&tok, LEFT_PARENTHESES, t.ch)
	case ')':
		token_init(&tok, RIGHT_PARENTHESES, t.ch)
	case ',':
		token_init(&tok, COMMA, t.ch)
	case '.':
		if t.input[t.read_position] == '.' && t.input[t.read_position+1] == '.' {
			tok.literal = strings.clone("...")
			tok.type = strings.clone(END_IDENTIFIER)
			t.position += 2
			t.read_position += 2
			t.ch = rune(t.input[t.read_position])
		} else {
			token_init(&tok, PERIOD, t.ch)
		}
	case ';':
		token_init(&tok, SEMICOLON, t.ch)
	case '+':
		token_init(&tok, PLUS, t.ch)
	case '{':
		token_init(&tok, LEFT_BRACE, t.ch)
	case '}':
		token_init(&tok, RIGHT_BRACE, t.ch)
	case 0:
		tok.literal = fmt.aprintf("")
		tok.type = strings.clone(EOF)
	case:
		if is_letter(t.ch) {
			tok.literal = strings.clone(read_identifier(t))
			upper := strings.to_upper(tok.literal)
			defer delete(upper)
			tok.type = strings.clone(lookup_identifier(tok.literal))
			return tok
		} else {
			token_init(&tok, ILLEGAL, t.ch)
		}
	}

	read_char(t)

	return
}

@(require_results)
tokenize_string :: proc(input: string) -> ([]Token) {
	t: Tokenizer
	tokenizer_init(&t, input)
	defer tokenizer_destroy(&t)

	tokens: [dynamic]Token

	tok: Token
	for {
		tok = next_token(&t)

		append(&tokens, tok)

		if tok.type == EOF {
			break
		}
	}

	return tokens[:]
}
