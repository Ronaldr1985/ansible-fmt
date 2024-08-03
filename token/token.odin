package token

import "base:runtime"
import "core:fmt"
import "core:strings"

// TODO: Add allocator paramter to allow for custom allocation
// TODO: Maybe error handling?  strings.clone can fail ^
token_init :: proc(tok: ^Token, type: Token_Type, ch: rune) {
	tok.type = strings.clone(type)
	tok.literal = fmt.aprintf("%s", ch)
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
