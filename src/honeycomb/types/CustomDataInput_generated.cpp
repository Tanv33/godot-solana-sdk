#include "honeycomb/types/CustomDataInput_generated.hpp"


namespace godot {
namespace honeycomb_resource {

void CustomDataInput::set_add(const Dictionary& val) {
this->add = val;
}

Dictionary CustomDataInput::get_add() const {
return this->add;
}

void CustomDataInput::set_remove(const PackedStringArray& val) {
this->remove = val;
}

PackedStringArray CustomDataInput::get_remove() const {
return this->remove;
}

void CustomDataInput::_bind_methods() {
ClassDB::bind_method(D_METHOD("get_add"), &CustomDataInput::get_add);
ClassDB::bind_method(D_METHOD("set_add", "value"), &CustomDataInput::set_add);
ClassDB::add_property("CustomDataInput", PropertyInfo(Variant::Type::DICTIONARY, "add"), "set_add", "get_add");
ClassDB::bind_method(D_METHOD("get_remove"), &CustomDataInput::get_remove);
ClassDB::bind_method(D_METHOD("set_remove", "value"), &CustomDataInput::set_remove);
ClassDB::add_property("CustomDataInput", PropertyInfo(Variant::Type::PACKED_STRING_ARRAY, "remove"), "set_remove", "get_remove");
ClassDB::bind_method(D_METHOD("to_dict"), &CustomDataInput::to_dict);
}
Dictionary CustomDataInput::to_dict() {
Dictionary res;
res["add"] = add;
res["remove"] = remove;
return res;
}
} // namespace honeycomb_resource
} // namespace godot