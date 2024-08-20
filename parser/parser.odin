package parser

import "core:fmt"
import "core:strings"

import "../tokenizer"

/*
File {
	plays // slice
		play
			hosts
			bcome
			connection
			roles

	tasks
		task
}
*/

parser_from_string :: proc(input: string) -> (p: Parser) {
	tokenizer.tokenizer_init(&p.t, input)
	advance_token(&p)
	advance_token(&p)

	return
}

file_destroy :: proc(f: ^File) {
	if len(f.tasks) > 0 {
		for task in f.tasks {
			if task.name != "" do delete(task.name)
			if task.module != "" do delete(task.module)
		}
		delete(f.tasks)
	}
	if len(f.plays) > 0 do delete(f.plays)
}

parser_destroy :: proc(p: ^Parser) {
	tokenizer.token_destroy(&p.previous_token)
	tokenizer.token_destroy(&p.current_token)
	tokenizer.tokenizer_destroy(&p.t)
}

advance_token :: proc(p: ^Parser) {
	tokenizer.token_destroy(&p.previous_token)
	p.previous_token = p.current_token
	p.current_token = tokenizer.advance_token(&p.t)
}

expect_token :: proc(p: ^Parser, expected_type: tokenizer.Token_Type) -> Error {
	type := p.current_token.type
	if type == expected_type {
		return nil
	}
	return .Unexpected_Token
}

parse_task :: proc(p: ^Parser, input: string) -> (block: Block, err: Error) {
	err = expect_token(p, .Hyphen)
	if err != nil {
		return
	}
	task: Task
	have_name := false
	have_argument := false
	current_argument : Argument
	current_argument_name: string
	parse_loop: for (p.current_token.type != .EOF) {
		fmt.println("p.current_token.type:", p.current_token.type)
		// if p.current_token.type == .Hyphen && p.current_token.column == 0 || p.current_token.type == .EOF do break
		#partial switch p.current_token.type {
		case .Hyphen, .Name:
			advance_token(p)
		case .Colon:
			if p.previous_token.type == .Name {
				have_name = true
			}
			advance_token(p)
		case .Identifier:
			if have_name {
				task.name = strings.clone(p.current_token.literal)
				have_name = false
			} else if have_argument {
				append(&current_argument.values, strings.clone(p.current_token.literal))
			}
			advance_token(p)
		case .Module:
			task.module = strings.clone(p.current_token.literal)
			advance_token(p)
		case .Argument:
			have_argument = true
			current_argument.name = strings.clone(p.current_token.literal)
			advance_token(p)
		case .When:
			advance_token(p)
		case .Invalid:
			fmt.println("Literal:", p.current_token.literal)
			err = .Invalid_Token
			advance_token(p)
		case .End_Identifier:
			break parse_loop
		}
	}

	fmt.println("task:", task)
	return task, nil
}

parse_play :: proc(p: ^Parser, input: string) -> (block: Block, err: Error) {
	return
}

parse_block :: proc(p: ^Parser, input: string) -> (block: Block, err: Error) {
	err = .None
	for {
		#partial switch p.current_token.type {
		case .Invalid:
			err = .Invalid_Token
			return
		case .Hyphen:
			block, err = parse_task(p, input)
			return
		}
		advance_token(p)
	}
	return
}

parse_string :: proc(input: string) -> (f: File, err: Error) {
	tasks: [dynamic]Task
	plays: [dynamic]Play
	block: Block

	p := parser_from_string(input)
	defer parser_destroy(&p)

	block, err = parse_block(&p, input)
	if err != nil {
		return
	}

	#partial switch b in block {
	case Task:
		append(&tasks, block.(Task))
	}

	f.tasks = tasks[:]

	return
}
