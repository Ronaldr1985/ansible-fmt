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
	Argument_Parameter,
}

Position :: struct {
	offset: int,
	line:   int,
	column: int,
}

Token :: struct {
	using position: Position,
	type:           Token_Type,
	literal:        string,
	indentation:    int,
}

Tokenizer :: struct {
	using position: Position,
	input:          string,
	ch:             rune, // current rune
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


