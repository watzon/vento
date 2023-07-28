// ApiResponse is a generic response from the Telegram API. If `ok` is false, the
// error is explained in the `description` field.
pub struct ApiResponse[T] {
	ok bool
	result T
	description string
}
