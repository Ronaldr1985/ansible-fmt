package tokenizer

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:unicode"

// TODO: Add allocator paramter to allow for custom allocation
// TODO: Maybe error handling?  strings.clone can fail ^
token_init :: proc(tok: ^Token, type: Token_Type, ch: rune, line, column: int) {
	tok.type    = type
	tok.literal = fmt.aprintf("%v", ch)
	tok.line = line
	tok.column = column
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
	if t.input[t.offset] == '\n' || t.input[t.offset] == '\r' {
		t.line += 1
		t.column = 0
	} else {
		t.column += 1
	}
	t.offset += 1

	if t.offset >= len(t.input)-1 {
		t.ch = 0
		t.column = 0
	} else {
		t.ch = rune(t.input[t.offset])
	}
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
		prev_offset := t.offset

		for is_letter(t.ch) {
			read_char(t)
		}

		return t.input[prev_offset:t.offset]
	}

	skip_whitespace(t)

	switch t.ch {
	case '-':
		if t.input[t.offset+1] == '-' && t.input[t.offset+2] == '-' {
			tok.literal = strings.clone("---")
			tok.type = .Start_Identifier
			t.ch = rune(t.input[t.offset])
			tok.line = t.line
			tok.column = t.column
			t.offset += 2
		} else {
			token_init(&tok, .Hyphen, t.ch, t.line, t.column)
		}
	case ':':
		token_init(&tok, .Colon, t.ch, t.line, t.column)
	case '(':
		token_init(&tok, .Left_Parentheses, t.ch, t.line, t.column)
	case ')':
		token_init(&tok, .Right_Parentheses, t.ch, t.line, t.column)
	case ',':
		token_init(&tok, .Comma, t.ch, t.line, t.column)
	case '.':
		if t.input[t.offset+1] == '.' && t.input[t.offset+2] == '.' {
			tok.literal = strings.clone("...")
			tok.type = .End_Identifier
			t.offset += 2
			t.ch = rune(t.input[t.offset])
			tok.line = t.line
			tok.column = t.column
		} else {
			token_init(&tok, .Period, t.ch, t.line, t.column)
		}
	case ';':
		token_init(&tok, .Semicolon, t.ch, t.line, t.column)
	case '+':
		token_init(&tok, .Plus, t.ch, t.line, t.column)
	case '{':
		token_init(&tok, .Left_Brace, t.ch, t.line, t.column)
	case '}':
		token_init(&tok, .Right_Brace, t.ch, t.line, t.column)
	case 0:
		tok.literal = fmt.aprintf("")
		tok.type = .EOF
		tok.line = t.line
		tok.column = t.column
	case:
		if is_letter(t.ch) {
			tok.column = t.column - len(tok.literal)
			tok.literal = strings.clone(read_identifier(t))
			upper := strings.to_upper(tok.literal)
			defer delete(upper)
			tok.type = lookup_identifier(tok.literal)
			tok.line = t.line
			return tok
		} else {
			token_init(&tok, .Invalid, t.ch, t.line, t.column)
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
