module main

// The Api struct is a modified version of the `JsonSpec` struct,
// formatted in such a way to make codegen for V easier.
pub struct Api {
mut:
	version string
	release_date string
	changelog string
	sum_types map[string]ApiSumType
	interfaces map[string]ApiInterface
	structs []ApiStruct
	functions []ApiFunction
}

struct ApiInterface {
mut:
	name string
	link string
	description []string
	structs []string
}

struct ApiStruct {
mut:
	name string
	link string
	description []string
	fields []ApiField
	implements ?string
}

struct ApiFunction {
mut:
	name string
	method string
	link string
	description []string
	params []ApiField
	returns string
}

struct ApiField {
mut:
	name string
	@type string
	required bool
	description []string
}

pub fn (field ApiField) is_primitive() bool {
	return !field.@type[0].is_capital()
}

struct ApiSumType {
mut:
	name string
	value string
	array_of bool
}

pub fn Api.from_spec(spec JsonSpec) &Api {
	mut api := &Api{
		version: spec.version,
		release_date: spec.release_date,
		changelog: spec.changelog,
		sum_types: map[string]ApiSumType{},
		interfaces: map[string]ApiInterface{},
		structs: []ApiStruct{},
		functions: []ApiFunction{},
	}

	// Find all the interfaces first. They don't create or rely on sum types, but sum types
	// can rely on them.
	for tname, @type in spec.types {
		if @type.subtypes.len > 0 {
			// This is an interface
			iface := ApiInterface{
				name: tname,
				link: @type.href,
				description: normalize_description(@type.description),
				structs: []string{}, // These will be filled in when the structs are created
			}

			api.interfaces[tname] = iface
		}
	}

	// Now find all the structs.
	for tname, @type in spec.types {
		if @type.subtypes.len == 0 {
			// This is a struct
			mut obj := ApiStruct{
				name: tname,
				link: @type.href,
				description: normalize_description(@type.description),
				fields: []ApiField{},
			}

			// Fields will be handled after all structs are created.
			for field in @type.fields {
				obj.fields << ApiField{
					name: name_to_v(field.name),
					required: field.required,
					description: normalize_description([field.description]),
					@type: types_to_v(mut api, field.types),
				}
			}

			if @type.subtype_of.len > 0 {
				iface_name := @type.subtype_of[0]
				api.interfaces[iface_name].structs << obj.name
				obj.implements = api.interfaces[iface_name].name
			}

			api.structs << obj
		}
	}

	for mname, method in spec.methods {
		mut func := ApiFunction{
			name: to_snake_case(mname),
			method: mname,
			link: method.href,
			description: normalize_description(method.description),
			params: []ApiField{},
			returns: types_to_v(mut api, method.returns),
		}

		for field in method.fields {
			func.params << ApiField{
				name: name_to_v(field.name),
				required: field.required,
				description: normalize_description([field.description]),
				@type: types_to_v(mut api, field.types),
			}
		}

		api.functions << func
	}

	return api
}

// Convert an array of types into a sum type. V doesn't allow for inline sum types,
// so in all cases where a type can be a or b, we need to create a new type that
// combines them. To make things even harder, we have to take into account arrays.
//
// - If all types are arrays, we need to create a sum type for a combination of each type sans array.
//   For example, rather than `[]string | []int`, we need to create `[]StringOrInt`.
// - If not all types are arrays then we can just create a sum type that combines them.
//   For example, `string | []int` becomes `StringOrIntArray`.
fn types_to_sumtype(types []string) (string, ApiSumType) {
	all_arrays := types.all(fn (t string) bool { return t.starts_with('Array of') })
	mut sum_name := ""
	mut sum_value := ""
	mut key_parts := []string{}

	for name in types {
		mut typ := type_to_v(name)
		key_parts << typ

		is_array := typ.starts_with("[]")

		if is_array && all_arrays {
			typ = typ[2..]
		}

		if sum_name.len > 0 {
			sum_name += "Or"
		}

		sum_name += name.replace("Array of ", "")

		if is_array && !all_arrays {
			sum_name += "Array"
		}

		if sum_value.len > 0 {
			sum_value += " | "
		}

		sum_value += typ
	}

	sum := ApiSumType{
		name: sum_name,
		value: sum_value,
		array_of: all_arrays,
	}

	return key_parts.join(" | "), sum
}

fn types_to_v(mut api Api, types []string) string {
	if types.len == 1 {
		return type_to_v(types[0])
	}

	_, sum := types_to_sumtype(types)
	api.sum_types[sum.name] = sum

	if sum.array_of {
		return "[]"+sum.name
	} else {
		return sum.name
	}
}
