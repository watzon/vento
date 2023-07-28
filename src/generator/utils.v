module main

import strings

pub const multipart_methods = [
	"send_audio",
	"send_document",
	"send_photo",
	"send_video",
	"send_animation",
	"send_voice",
	"send_video_note",
	"send_media_group"
]

pub const overridden_types = [
	"InputFile",
]

pub const defaults = {
	"InlineQueryResultArticle": {
		"@type": "'article'",
	},
	"InlineQueryResultPhoto": {
		"@type": "'photo'",
	},
	"InlineQueryResultGif": {
		"@type": "'gif'",
	},
	"InlineQueryResultMpeg4Gif": {
		"@type": "'mpeg4_gif'",
	},
	"InlineQueryResultVideo": {
		"@type": "'video'",
	},
	"InlineQueryResultAudio": {
		"@type": "'audio'",
	},
	"InlineQueryResultVoice": {
		"@type": "'voice'",
	},
	"InlineQueryResultDocument": {
		"@type": "'document'",
	},
	"InlineQueryResultLocation": {
		"@type": "'location'",
	},
	"InlineQueryResultVenue": {
		"@type": "'venue'",
	},
	"InlineQueryResultContact": {
		"@type": "'contact'",
	},
	"InlineQueryResultGame": {
		"@type": "'game'",
	},
	"InlineQueryResultCachedPhoto": {
		"@type": "'photo'",
	},
	"InlineQueryResultCachedGif": {
		"@type": "'gif'",
	},
	"InlineQueryResultCachedMpeg4Gif": {
		"@type": "'mpeg4_gif'",
	},
	"InlineQueryResultCachedSticker": {
		"@type": "'sticker'",
	},
	"InlineQueryResultCachedDocument": {
		"@type": "'document'",
	},
	"InlineQueryResultCachedVideo": {
		"@type": "'video'",
	},
	"InlineQueryResultCachedVoice": {
		"@type": "'voice'",
	},
	"InlineQueryResultCachedAudio": {
		"@type": "'audio'",
	},
	"InputMediaPhoto": {
		"@type": "'photo'",
	},
	"InputMediaVideo": {
		"@type": "'video'",
	},
	"InputMediaAnimation": {
		"@type": "'animation'",
	},
	"InputMediaAudio": {
		"@type": "'audio'",
	},
	"InputMediaDocument": {
		"@type": "'document'",
	},
	"InputMediaVideoNote": {
		"@type": "'video_note'",
	},
	"InputMediaInvoice": {
		"@type": "'invoice'",
	},
	"InputMediaPoll": {
		"@type": "'poll'",
	},
	"InputMediaDice": {
		"@type": "'dice'",
	},
}

pub const keywords = [
	"as",
	"asm",
	"assert",
	"atomic",
	"break",
	"const",
	"continue",
	"defer",
	"else",
	"enum",
	"false",
	"fn",
	"for",
	"go",
	"goto",
	"if",
	"import",
	"in",
	"interface",
	"is",
	"isreftype",
	"lock",
	"match",
	"module",
	"mut",
	"none",
	"or",
	"pub",
	"return",
	"rlock",
	"select",
	"shared",
	"sizeof",
	"spawn",
	"static",
	"struct",
	"true",
	"type",
	"typeof",
	"union",
	"unsafe",
	"volatile",
	"__global",
	"__offsetof",
]

// Returns a new string with the first letter of the original string capitalized
pub fn capitalize_first_letter(s string) string {
	if s.len == 1 {
		return s.to_upper()
	}

	return s[0].ascii_str().to_upper() + s[1..]
}

// Returns a new string in snake_case
pub fn to_snake_case(s string) string {
	mut b := strings.new_builder(s.len + 5)
	l := s.len
	for i, v in s {
		// A is 65, a is 97
		if (v >= `a` && v <= `z`) || (v >= `0` && v <= `9`)  {
			b.write_byte(v)
			continue
		}

		// v is a capital letter here
		// disregard the first letter
		// add an underscore if the last letter is a capital
		// add an underscore if the previous letter is lowercase
		// add an underscore if the next letter is lowercase
		if (i != 0 || i == l - 1) && ( // head and tail
			(i > 0 && s[i - 1] >= `a`) || // pre
				(i < l - 1 && s[i + 1] >= `a`)) { // next
			b.write_rune(`_`)
		}

		if v >= `A` && v <= `Z` {
			b.write_byte(v + 32)
		}
	}

	return b.str()
}

// Returns a new string in camelCase. If upper is true, the first letter will be capitalized.
pub fn to_camel_case(s string, upper bool) string {
	mut b := strings.new_builder(s.len)
	mut next_upper := upper
	for i, v in s {
		if v == `_` {
			next_upper = true
			continue
		}

		if next_upper {
			b.write_byte(v - 32)
			next_upper = false
			continue
		}

		if i == 0 {
			b.write_byte(v)
			continue
		}

		b.write_byte(v)
	}

	return b.str()
}

fn normalize_description(description []string) []string {
	if description.len == 0 || description[0].len == 0 {
		return []string{}
	}

	mut b := []string{}
	mut last_line := ""

	for line in description {
		// Split the description into words.
		words := line.split(" ")

		// Start writing words, keeping track of the current line length.
		min_line_length := 35
		mut max_line_length := 120
		for word in words {
			// If the word is too long to fit on the current line, start a new line.
			if last_line.len + word.len + 1 > max_line_length {
				b << last_line.trim_space()
				max_line_length = if last_line.len < min_line_length { 120 } else { last_line.len }
				last_line = ""
			}

			// Write the word.
			last_line += word + " "
		}

		b << last_line.trim_space()
		last_line = ""
	}

	return b
}

// Convert a name (typically camelCase) to a valid V ident (typically snake_case).
pub fn name_to_v(name string) string {
	new_name := to_snake_case(name)
	if new_name in keywords {
		return "@" + new_name
	} else {
		return new_name
	}
}

// Convert a type name to a valid V type name.
pub fn type_to_v(typ string) string {
	if typ.starts_with("Array of ") {
		return "[]" + type_to_v(typ[9..])
	}

	return match typ {
		"String" { "string" }
		"Float" { "f64" }
		"Integer" { "i64" }
		"Boolean" { "bool" }
		"True" { "bool" }
		else { typ }
	}
}
