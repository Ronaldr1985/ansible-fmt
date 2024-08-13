package tokenizer

import "core:strings"

Token_Type :: enum {
	Invalid,
	EOF,

	Start_Identifier,
	End_Identifier,

	Identifier,

	Hyphen,
	Comma,
	Colon,
	Plus,
	Period,
	Semicolon,
	Left_Parentheses,
	Right_Parentheses,
	Left_Brace,
	Right_Brace,

	Int,
	Bool,

	Name,
	Loop,
	Until,
	Notify,
	When,
	Any_errors_fatal,
	Become,
	Become_exe,
	Become_flags,
	Become_method,
	Become_user,
	Check_mode,
	Collections,
	Connection,
	Debugger,
	Diff,
	Environment,

	Module,
	Argument,
}

Position :: struct {
	indentation: int,
	line:        int,
	column:      int,
}

Token :: struct {
	position:    Position,
	type:        Token_Type,
	literal:     string,
	indentation: int,
}

Keywords := map[string]Token_Type {
	"NAME"                = .Name,
	"LOOP"                = .Loop,
	"UNTIL"               = .Until,
	"WHEN"                = .When,
	"ANY_ERRORS_FATAL"    = .Any_errors_fatal,
	"BECOME"              = .Become,
	"BECOME_EXE"          = .Become_exe,
	"BECOME_FLAGS"        = .Become_flags,
	"BECOME_METHOD"       = .Become_method,
	"BECOME_USER"         = .Become_user,
	"CHECK_MODE"          = .Check_mode,
	"COLLECTIONS"         = .Collections,
	"CONNECTION"          = .Connection,
	"DEBUGGER"            = .Debugger,
	"DIFF"                = .Diff,
	"ENVIRONMENT"         = .Environment,
	"APT"                 = .Module,
	"ANSIBLE.BUILTIN.APT" = .Module,
	"PKG"                 = .Argument,
}

Tokenizer :: struct {
	input:         string,

	ch:            rune, // current rune

	position:      int, // current position in input, points to current char
	read_position: int, // current reading position in input, after current char
}


