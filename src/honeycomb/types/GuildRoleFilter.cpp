#include "honeycomb/types/GuildRoleFilter.hpp"


namespace godot {
namespace honeycomb_resource {

void GuildRoleFilter::set_kind(const String& val) {
this->kind = val;
}

String GuildRoleFilter::get_kind() const {
return this->kind;
}

void GuildRoleFilter::_bind_methods() {
ClassDB::bind_method(D_METHOD("get_kind"), &GuildRoleFilter::get_kind);
ClassDB::bind_method(D_METHOD("set_kind", "value"), &GuildRoleFilter::set_kind);
ClassDB::add_property("GuildRoleFilter", PropertyInfo(Variant::Type::STRING, "kind"), "set_kind", "get_kind");
ClassDB::bind_method(D_METHOD("to_dict"), &GuildRoleFilter::to_dict);
}
Dictionary GuildRoleFilter::to_dict() {
Dictionary res;
res["kind"] = kind;
return res;
}
} // namespace honeycomb_resource
} // namespace godot