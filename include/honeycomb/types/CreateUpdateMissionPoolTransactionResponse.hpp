#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_CREATEUPDATEMISSIONPOOLTRANSACTIONRESPONSE
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_CREATEUPDATEMISSIONPOOLTRANSACTIONRESPONSE
#include "godot_cpp/variant/variant.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/classes/resource.hpp"

namespace godot{
namespace honeycomb_resource{

class CreateUpdateMissionPoolTransactionResponse : public Resource{
GDCLASS(CreateUpdateMissionPoolTransactionResponse, Resource)
private:
Variant tx;
protected:
static void _bind_methods();
public:
Dictionary to_dict();
void set_tx(const Variant& val);
Variant get_tx() const;
};
} // honeycomb_resource
} // godot
#endif