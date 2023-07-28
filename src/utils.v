module main

import rand

const chars = "abcdefghijklmnopqrstuvwxyz0123456789_"

fn random_string(len int) string {
	return rand.string_from_set(chars, len)
}
