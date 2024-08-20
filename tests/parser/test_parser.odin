package test_parser

import "core:testing"

import "../../tokenizer"
import "../../parser"

@test
test_parse_play :: proc(t: ^testing.T) {
	input := `
  - name: Gitea setup
    hosts: gitea
    become: true
    become_method: ansible.builtin.sudo
    connection: ssh
    vars_files:
      - vars/gitea_vars.yml
    roles:
      - install_packages
      - install_gitea
      - nginx
      - certbot
      - cron
      - services

	`

	file, err := parser.parse_string(input)
	defer parser.file_destroy(&file)

	testing.expectf(t, err == nil, "Expected err to be nil, instead got %v", err)


	num_plays := len(file.plays)
	testing.expectf(t, num_plays == 1, "Expected number of plays to be 1 instead got %v", num_plays)

	expected_plays := [?]parser.Play {
		parser.Play{
			name = "Gitea setup",
			hosts = "gitea",
			become = parser.Become{
				value = true,
				method = "ansible.builtin.sudo",
			},
			connection = "ssh",
			vars_files = []string{
				"vars/gitea_vars.yml",
			},
			roles = []string{
				"install_packages",
				"install_gitea",
				"nginx",
				"certbot",
				"cron",
				"services",
			}
		}
	}

	for play, i in expected_plays {
		testing.expectf(
			t,
			play.name == file.plays[i].name,
			"Expected play name to be %v but got %v",
			play.name, file.plays[i].name,
		)
	}
}
