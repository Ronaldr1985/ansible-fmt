package parser

import "../tokenizer"

Error :: enum {
	None,
	Illegal_Character,
	Invalid_Token,
	Unexpected_Token,
	Allocator_Error,
}

Parser :: struct {
	t:              tokenizer.Tokenizer,
	previous_token: tokenizer.Token,
	current_token:  tokenizer.Token,
	parse_booleans: bool,
}

Identifier :: struct {
	token: tokenizer.Token,
	value: string
}

Statement_Type :: enum {
	When,
	Changed_When,
}

Statement :: struct {
	type: Statement_Type,
	data: string,
}

Block :: union {
	Task,
	Play,
}

Become :: struct {
	value:  bool,
	user:   string,
	method: string,
	exe:    string,
	flags:  string,
}

Argument :: struct {
	name:   string,
	values: [dynamic]string,
}

Task :: struct {
	name:             string,
	module:           string,
	arguments:        [dynamic]Argument,
	any_errors_fatal: bool,
	async:            bool,
	become:           Become,
	changed_when:     []Statement,
	failed_when:      []Statement,
	When:             []Statement,
}

Play :: struct {
	name:       string,
	hosts:      string,
	become:     Become,
	connection: string,
	vars:       map[string]string,
	vars_files: []string,
	pre_tasks:  []Task,
	tasks:      []Task,
	post_tasks: []Task,
	roles:      []string,
}

File :: struct {
	plays: []Play,
	tasks: []Task,
	// TODO: Add details to have the ability to parse meta files
}
