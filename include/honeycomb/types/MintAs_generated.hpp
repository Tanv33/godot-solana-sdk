#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_MINTAS
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_MINTAS
#include "godot_cpp/variant/variant.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/classes/resource.hpp"
#include "honeycomb/enums_generated.hpp"

namespace godot{
namespace honeycomb_resource{

class MintAs : public Resource{
GDCLASS(MintAs, Resource)
private:
String kind;
Dictionary params;
protected:
static void _bind_methods();
public:
Dictionary to_dict();
void set_kind(const String& val);
String get_kind() const;
void set_params(const Dictionary& val);
Dictionary get_params() const;
};
} // honeycomb_resource
} // godot
#endif
