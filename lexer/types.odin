package lexer

Lexer :: struct {
	input: string,

	position: int, // current position in input, points to current char
	read_position: int, // current reading position in input, after current char
	ch: rune,
}

