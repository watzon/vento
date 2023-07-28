// Vento (wind in Portuguese) is a Telegram Bot API library for V, with a focus
// on simplicity and ease of use. Vento makes use of V's attributes for defining
// the bot's commands and handlers, and all types and methods are generated
// automatically from the official Telegram Bot API documentation.
module main

struct Bot {
pub:
	Context
}

fn main() {
	bot := &Bot {
		Context: Context.new("TOKEN"),
	}

	res := bot.send_photo(
		chat_id: i64(-1001282897912),
		photo:    "https://i.imgur.com/4M34hi2.jpg",
		caption: "Hello, world!",
	)!

	println(res)
}
