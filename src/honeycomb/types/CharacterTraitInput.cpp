#include "honeycomb/types/CharacterTraitInput.hpp"


namespace godot {
namespace honeycomb_resource {

void CharacterTraitInput::set_layer(const String& val) {
this->layer = val;
}

String CharacterTraitInput::get_layer() const {
return this->layer;
}

void CharacterTraitInput::set_name(const String& val) {
this->name = val;
}

String CharacterTraitInput::get_name() const {
return this->name;
}

void CharacterTraitInput::set_uri(const String& val) {
this->uri = val;
}

String CharacterTraitInput::get_uri() const {
return this->uri;
}

void CharacterTraitInput::_bind_methods() {
ClassDB::bind_method(D_METHOD("get_layer"), &CharacterTraitInput::get_layer);
ClassDB::bind_method(D_METHOD("set_layer", "value"), &CharacterTraitInput::set_layer);
ClassDB::add_property("CharacterTraitInput", PropertyInfo(Variant::Type::STRING, "layer"), "set_layer", "get_layer");
ClassDB::bind_method(D_METHOD("get_name"), &CharacterTraitInput::get_name);
ClassDB::bind_method(D_METHOD("set_name", "value"), &CharacterTraitInput::set_name);
ClassDB::add_property("CharacterTraitInput", PropertyInfo(Variant::Type::STRING, "name"), "set_name", "get_name");
ClassDB::bind_method(D_METHOD("get_uri"), &CharacterTraitInput::get_uri);
ClassDB::bind_method(D_METHOD("set_uri", "value"), &CharacterTraitInput::set_uri);
ClassDB::add_property("CharacterTraitInput", PropertyInfo(Variant::Type::STRING, "uri"), "set_uri", "get_uri");
ClassDB::bind_method(D_METHOD("to_dict"), &CharacterTraitInput::to_dict);
}
Dictionary CharacterTraitInput::to_dict() {
Dictionary res;
res["layer"] = layer;
res["name"] = name;
res["uri"] = uri;
return res;
}
} // namespace honeycomb_resource
} // namespace godot