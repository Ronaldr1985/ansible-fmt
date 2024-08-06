package tokenizer

import "core:strings"

ILLEGAL            :: "ILLEGAL"
START_IDENTIFIER   :: "---"
END_IDENTIFIER     :: "..."
EOF                :: "EOF"
IDENTIFIER         :: "IDENTIFIER"
ITEM_IDENTIFIER    :: "-"
// Key words
NAME               :: "NAME"
LOOP               :: "LOOP"
UNTIL              :: "UNTIL"
NOTIFY             :: "NOTIFY"
WHEN               :: "WHEN"
ANY_ERRORS_FATAL   :: "ANY_ERRORS_FATAL"
BECOME             :: "BECOME"
BECOME_EXE         :: "BECOME_EXEC"
BECOME_FLAGS       :: "BECOME_FLAGS"
BECOME_METHOD      :: "BECOME_METHOD"
BECOME_USER        :: "BECOME_USER"
CHECK_MODE         :: "CHECK_MODE"
COLLECTIONS        :: "COLLECTIONS"
CONNECTION         :: "CONNECTION"
DEBUGGER           :: "DEBUGGER"
DIFF               :: "DIFF"
ENVIRONMENT        :: "ENVIRONMENT"
// Types
INT                :: "INT"
BOOL               :: "BOOL"
// CHARACTERS
COLON              :: ":"
PLUS               :: "+"
COMMA              :: ","
PERIOD             :: "."
SEMICOLON          :: ";"
LEFT_PARENTHESES   :: "("
RIGHT_PARENTHESES  :: ")"
LEFT_BRACE         :: "{"
RIGHT_BRACE        :: "}"
// MODULES
// FQCNs
MODULE_APT_FQCN    :: "ansible.builtin.apt"
MODULE_APT         :: "apt"
ARG_PKG            :: "pkg"

Token_Type :: string

Token :: struct {
	type: Token_Type,
	literal: string,
}

Keywords := map[string]Token_Type {
	"NAME"                = NAME,
	"LOOP"                = LOOP,
	"UNTIL"               = UNTIL,
	"WHEN"                = WHEN,
	"ANY_ERRORS_FATAL"    = ANY_ERRORS_FATAL,
	"BECOME"              = BECOME,
	"BECOME_EXE"          = BECOME_EXE,
	"BECOME_FLAGS"        = BECOME_FLAGS,
	"BECOME_METHOD"       = BECOME_METHOD,
	"BECOME_USER"         = BECOME_USER,
	"CHECK_MODE"          = CHECK_MODE,
	"COLLECTIONS"         = COLLECTIONS,
	"CONNECTION"          = CONNECTION,
	"DEBUGGER"            = DEBUGGER,
	"DIFF"                = DIFF,
	"ENVIRONMENT"         = ENVIRONMENT,
	"ANSIBLE.BUILTIN.APT" = MODULE_APT_FQCN,
	"PKG"                 = ARG_PKG
}

Tokenizer :: struct {
	input: string,

	position: int, // current position in input, points to current char
	read_position: int, // current reading position in input, after current char
	ch: rune,
}


