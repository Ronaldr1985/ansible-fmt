package lexer

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:unicode"

import "../token"

is_letter :: proc(r: rune) -> bool {
	return unicode.is_letter(r) || r == '_' || r == '.'
}


lexer_init :: proc(l: ^Lexer, input: string) -> (err: runtime.Allocator_Error) {
	l.input, err = strings.clone(input)

	read_char(l)

	return err
}

lexer_destroy :: proc(l: ^Lexer) {
	delete(l.input)
}

read_char :: proc(l: ^Lexer) {
	if l.read_position >= len(l.input) {
		l.ch = 0
	} else {
		l.ch = rune(l.input[l.read_position])
	}
	l.position = l.read_position
	l.read_position += 1
}

next_token :: proc(l: ^Lexer) -> (tok: token.Token) {
	skip_whitespace :: proc(l: ^Lexer) {
		for l.ch == ' ' || l.ch == '\t' || l.ch == '\n' || l.ch == '\r' {
			read_char(l)
		}
	}

	skip_whitespace(l)

	switch l.ch {
	case '-':
		if l.input[l.read_position] == '-' && l.input[l.read_position+1] == '-' {
			tok.literal = strings.clone("---")
			tok.type = strings.clone(token.START_IDENTIFIER)
			l.position += 2
			l.read_position += 2
			l.ch = rune(l.input[l.read_position])
		} else {
			token.token_init(&tok, token.ITEM_IDENTIFIER, l.ch)
		}
	case ':':
		token.token_init(&tok, token.COLON, l.ch)
	case '(':
		token.token_init(&tok, token.LEFT_PARENTHESES, l.ch)
	case ')':
		token.token_init(&tok, token.RIGHT_PARENTHESES, l.ch)
	case ',':
		token.token_init(&tok, token.COMMA, l.ch)
	case '.':
		if l.input[l.read_position] == '.' && l.input[l.read_position+1] == '.' {
			tok.literal = strings.clone("...")
			tok.type = strings.clone(token.END_IDENTIFIER)
			l.position += 2
			l.read_position += 2
			l.ch = rune(l.input[l.read_position])
		} else {
			token.token_init(&tok, token.PERIOD, l.ch)
		}
	case ';':
		token.token_init(&tok, token.SEMICOLON, l.ch)
	case '+':
		token.token_init(&tok, token.PLUS, l.ch)
	case '{':
		token.token_init(&tok, token.LEFT_BRACE, l.ch)
	case '}':
		token.token_init(&tok, token.RIGHT_BRACE, l.ch)
	case 0:
		tok.literal = fmt.aprintf("")
		tok.type = strings.clone(token.EOF)
	case:
		if is_letter(l.ch) {
			tok.literal = strings.clone(read_identifier(l))
			upper := strings.to_upper(tok.literal)
			defer delete(upper)
			tok.type = strings.clone(token.lookup_identifier(tok.literal))
			return tok
		} else {
			token.token_init(&tok, token.ILLEGAL, l.ch)
		}
	}

	read_char(l)

	return
}

read_identifier :: proc(l: ^Lexer) -> string {
	position := l.position

	for is_letter(l.ch) {
		read_char(l)
	}

	return l.input[position:l.position]
}
