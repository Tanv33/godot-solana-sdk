#include "honeycomb/types/TimeRequirement.hpp"

#include "honeycomb/types/TimeRequirementParams.hpp"

namespace godot {
namespace honeycomb_resource {

void TimeRequirement::set_kind(const String& val) {
this->kind = val;
}

String TimeRequirement::get_kind() const {
return this->kind;
}

void TimeRequirement::set_params(const Variant& val) {
this->params = val;
}

Variant TimeRequirement::get_params() const {
return this->params;
}

void TimeRequirement::_bind_methods() {
ClassDB::bind_method(D_METHOD("get_kind"), &TimeRequirement::get_kind);
ClassDB::bind_method(D_METHOD("set_kind", "value"), &TimeRequirement::set_kind);
ClassDB::add_property("TimeRequirement", PropertyInfo(Variant::Type::STRING, "kind"), "set_kind", "get_kind");
ClassDB::bind_method(D_METHOD("get_params"), &TimeRequirement::get_params);
ClassDB::bind_method(D_METHOD("set_params", "value"), &TimeRequirement::set_params);
ClassDB::add_property("TimeRequirement", PropertyInfo(Variant::Type::OBJECT, "params"), "set_params", "get_params");
ClassDB::bind_method(D_METHOD("to_dict"), &TimeRequirement::to_dict);
}
Dictionary TimeRequirement::to_dict() {
Dictionary res;
res["kind"] = kind;

          if (params.get_type() != Variant::NIL) {
              auto* ptr = Object::cast_to<godot::honeycomb_resource::TimeRequirementParams>(params);
              if (ptr) {
                  res["params"] = ptr->to_dict();
              }
          }
return res;
}
} // namespace honeycomb_resource
} // namespace godot