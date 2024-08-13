package tokenizer

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:unicode"

// TODO: Add allocator paramter to allow for custom allocation
// TODO: Maybe error handling?  strings.clone can fail ^
token_init :: proc(tok: ^Token, type: Token_Type, ch: rune) {
	tok.type    = type
	tok.literal = fmt.aprintf("%v", ch)
}

token_destroy :: proc(tok: ^Token) {
	delete(tok.literal)
}

lookup_identifier :: proc(identifier: string) -> Token_Type {
	upper := strings.to_upper(identifier)
	defer delete(upper)
	if token_type, ok := Keywords[upper]; ok {
		return token_type
	}

	return .Identifier
}

tokenizer_init :: proc(t: ^Tokenizer, input: string) -> (err: runtime.Allocator_Error) {
	t.input, err = strings.clone(input)
	if err != nil {
		return
	}

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

advance_token :: proc(t: ^Tokenizer) -> (tok: Token) {
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
			tok.type = .Start_Identifier
			t.position += 2
			t.read_position += 2
			t.ch = rune(t.input[t.read_position])
		} else {
			token_init(&tok, .Hyphen, t.ch)
		}
	case ':':
		token_init(&tok, .Colon, t.ch)
	case '(':
		token_init(&tok, .Left_Parentheses, t.ch)
	case ')':
		token_init(&tok, .Right_Parentheses, t.ch)
	case ',':
		token_init(&tok, .Comma, t.ch)
	case '.':
		if t.input[t.read_position] == '.' && t.input[t.read_position+1] == '.' {
			tok.literal = strings.clone("...")
			tok.type = .End_Identifier
			t.position += 2
			t.read_position += 2
			t.ch = rune(t.input[t.read_position])
		} else {
			token_init(&tok, .Period, t.ch)
		}
	case ';':
		token_init(&tok, .Semicolon, t.ch)
	case '+':
		token_init(&tok, .Plus, t.ch)
	case '{':
		token_init(&tok, .Left_Brace, t.ch)
	case '}':
		token_init(&tok, .Right_Brace, t.ch)
	case 0:
		tok.literal = fmt.aprintf("")
		tok.type = .EOF
	case:
		if is_letter(t.ch) {
			tok.literal = strings.clone(read_identifier(t))
			upper := strings.to_upper(tok.literal)
			defer delete(upper)
			tok.type = lookup_identifier(tok.literal)
			return tok
		} else {
			token_init(&tok, .Invalid, t.ch)
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
		tok = advance_token(&t)

		append(&tokens, tok)

		if tok.type == .EOF {
			break
		}
	}

	return tokens[:]
}
