#ifndef GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKIND
#define GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKIND

#include "godot_cpp/classes/resource.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/variant.hpp"

namespace godot {
namespace honeycomb_resource {

/**
 * @brief Resource wrapper for honeycomb type ResourceKind.
 */
class ResourceKind : public Resource {
	GDCLASS(ResourceKind, Resource)

private:
	String kind;
	Dictionary params;

protected:
	/**
	 * @brief Bind methods and properties to the Godot engine.
	 */
	static void _bind_methods();

public:
	/**
	 * @brief Convert this resource to a Dictionary.
	 * @return Dictionary representation of this ResourceKind.
	 */
	Dictionary to_dict();

	/**
	 * @brief Set the kind property.
	 * @param val New value for kind.
	 */
	void set_kind(const String &val);
	/**
	 * @brief Get the kind property.
	 * @return Current value of kind.
	 */
	String get_kind() const;

	/**
	 * @brief Set the params property.
	 * @param val New value for params.
	 */
	void set_params(const Dictionary &val);
	/**
	 * @brief Get the params property.
	 * @return Current value of params.
	 */
	Dictionary get_params() const;
};

} // namespace honeycomb_resource
} // namespace godot

#endif // GODOT_SOLANA_SDK_HONEYCOMB_TYPE_RESOURCEKIND
