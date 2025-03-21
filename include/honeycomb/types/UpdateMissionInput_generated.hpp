#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_UPDATEMISSIONINPUT
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_UPDATEMISSIONINPUT
#include "godot_cpp/variant/variant.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/classes/resource.hpp"

namespace godot{
namespace honeycomb_resource{

class UpdateMissionInput : public Resource{
GDCLASS(UpdateMissionInput, Resource)
private:
Variant cost;
int64_t minXp;
int64_t duration;
PackedInt32Array removeRewards;
Array newRewards;
Array updateRewards;
protected:
static void _bind_methods();
public:
Dictionary to_dict();
void set_cost(const Variant& val);
Variant get_cost() const;
void set_minXp(const int64_t& val);
int64_t get_minXp() const;
void set_duration(const int64_t& val);
int64_t get_duration() const;
void set_removeRewards(const PackedInt32Array& val);
PackedInt32Array get_removeRewards() const;
void set_newRewards(const Array& val);
Array get_newRewards() const;
void set_updateRewards(const Array& val);
Array get_updateRewards() const;
};
} // honeycomb_resource
} // godot
#endif
