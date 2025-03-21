#include "honeycomb/types/ProfileDataConfigInput_generated.hpp"


namespace godot {
namespace honeycomb_resource {

void ProfileDataConfigInput::set_achievements(const PackedStringArray& val) {
this->achievements = val;
}

PackedStringArray ProfileDataConfigInput::get_achievements() const {
return this->achievements;
}

void ProfileDataConfigInput::set_customDataFields(const PackedStringArray& val) {
this->customDataFields = val;
}

PackedStringArray ProfileDataConfigInput::get_customDataFields() const {
return this->customDataFields;
}

void ProfileDataConfigInput::_bind_methods() {
ClassDB::bind_method(D_METHOD("get_achievements"), &ProfileDataConfigInput::get_achievements);
ClassDB::bind_method(D_METHOD("set_achievements", "value"), &ProfileDataConfigInput::set_achievements);
ClassDB::add_property("ProfileDataConfigInput", PropertyInfo(Variant::Type::PACKED_STRING_ARRAY, "achievements"), "set_achievements", "get_achievements");
ClassDB::bind_method(D_METHOD("get_customDataFields"), &ProfileDataConfigInput::get_customDataFields);
ClassDB::bind_method(D_METHOD("set_customDataFields", "value"), &ProfileDataConfigInput::set_customDataFields);
ClassDB::add_property("ProfileDataConfigInput", PropertyInfo(Variant::Type::PACKED_STRING_ARRAY, "customDataFields"), "set_customDataFields", "get_customDataFields");
ClassDB::bind_method(D_METHOD("to_dict"), &ProfileDataConfigInput::to_dict);
}
Dictionary ProfileDataConfigInput::to_dict() {
Dictionary res;
res["achievements"] = achievements;
res["customDataFields"] = customDataFields;
return res;
}
} // namespace honeycomb_resource
} // namespace godot