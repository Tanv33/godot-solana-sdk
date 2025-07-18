#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKINDPARAMSHPLNONFUNGIBLE
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKINDPARAMSHPLNONFUNGIBLE

#include "godot_cpp/classes/resource.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/variant.hpp"

namespace godot {
namespace honeycomb_resource {

/**
 * @brief Resource wrapper for honeycomb type ResourceKindParamsHplNonFungible.
 */
class ResourceKindParamsHplNonFungible : public Resource {
	GDCLASS(ResourceKindParamsHplNonFungible, Resource)

private:
	PackedStringArray characteristics;

protected:
	/**
	 * @brief Bind methods and properties to the Godot engine.
	 */
	static void _bind_methods();

public:
	/**
	 * @brief Convert this resource to a Dictionary.
	 * @return Dictionary representation of this ResourceKindParamsHplNonFungible.
	 */
	Dictionary to_dict();

	/**
	 * @brief Set the characteristics property.
	 * @param val New value for characteristics.
	 */
	void set_characteristics(const PackedStringArray &val);
	/**
	 * @brief Get the characteristics property.
	 * @return Current value of characteristics.
	 */
	PackedStringArray get_characteristics() const;
};

} // namespace honeycomb_resource
} // namespace godot

#endif // GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKINDPARAMSHPLNONFUNGIBLE
