#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_SERVICEPARAMSRAFFLES
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_SERVICEPARAMSRAFFLES

#include "godot_cpp/classes/resource.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/variant.hpp"

namespace godot {
namespace honeycomb_resource {

/**
 * @brief Resource wrapper for honeycomb type ServiceParamsRaffles.
 */
class ServiceParamsRaffles : public Resource {
	GDCLASS(ServiceParamsRaffles, Resource)

private:
	Variant poolId;

protected:
	/**
	 * @brief Bind methods and properties to the Godot engine.
	 */
	static void _bind_methods();

public:
	/**
	 * @brief Convert this resource to a Dictionary.
	 * @return Dictionary representation of this ServiceParamsRaffles.
	 */
	Dictionary to_dict();

	/**
	 * @brief Set the poolId property.
	 * @param val New value for poolId.
	 */
	void set_poolId(const Variant &val);
	/**
	 * @brief Get the poolId property.
	 * @return Current value of poolId.
	 */
	Variant get_poolId() const;
};

} // namespace honeycomb_resource
} // namespace godot

#endif // GODOT_SOLANA_SDK_HONEYCOMB_TYPE_SERVICEPARAMSRAFFLES
