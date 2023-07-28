module main

import json

// JsonSpec represents the raw JSON specification of the API, taken from
// the generated JSON from PaulSonOfLars. This will be transformed
// into the `Api` struct before being used.
pub struct JsonSpec {
pub mut:
	version string
	release_date string
	changelog string
	methods map[string]TypeDef
	types map[string]TypeDef
}

pub struct TypeDef {
pub mut:
	name string
	href string
	description []string
	returns []string
	fields []FieldDef
	subtypes []TypeDef
	subtype_of []string
}

pub struct FieldDef {
pub mut:
	name string
	types []string
	required bool
	description string
}

pub fn JsonSpec.from_json(raw string) JsonSpec {
	spec := json.decode(JsonSpec, raw) or { panic(err) }
	return spec
}
