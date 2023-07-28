module main

import os
import net.http

// These fields are the file fields in multipart request methods
const file_fields = ["photo", "audio", "document", "video", "voice", "video_note", "sticker"]

// The Context struct represents a Telegram API client.
pub struct Context {
mut:
	username string
	last_update_id int
	token string
	endpoint string
}

// Creates a new Context instance.
pub fn Context.new(token string) Context {
	return Context {
		token: token,
		endpoint: "https://api.telegram.org",
		username: "",
		last_update_id: 0,
	}
}

pub fn (mut ctx Context) set_token(token string) {
	ctx.token = token
}

pub fn (mut ctx Context) set_endpoint(endpoint string) {
	ctx.endpoint = endpoint
}

pub fn (ctx Context) request(method string, body string) !string {
	url := os.join_path(ctx.endpoint, "bot${ctx.token}", method)
	resp := http.post_json(url, body)!
	if resp.status_code != 200 {
		return error("HTTP error: ${resp.status_code}")
	}
	return resp.body
}

pub fn (ctx Context) request_multipart(method string, form http.PostMultipartFormConfig) !string {
	url := os.join_path(ctx.endpoint, "bot${ctx.token}", method)
	resp := http.post_multipart_form(url, form)!
	if resp.status_code != 200 {
		return error("HTTP error: ${resp.status_code} - ${resp.body}")
	}
	return resp.body
}
