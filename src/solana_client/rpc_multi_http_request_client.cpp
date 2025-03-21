#include "rpc_multi_http_request_client.hpp"

#include "godot_cpp/classes/engine.hpp"
#include "godot_cpp/classes/object.hpp"
#include "godot_cpp/variant/callable.hpp"
#include "godot_cpp/variant/dictionary.hpp"

#include "rpc_single_http_request_client.hpp"
#include "solana_utils.hpp"

namespace godot {

void RpcMultiHttpRequestClient::_bind_methods() {
}

void RpcMultiHttpRequestClient::process(double delta) {
	const unsigned int current_frame = Engine::get_singleton()->get_process_frames();
	if (current_frame == last_processed_frame) {
		return;
	}
	last_processed_frame = current_frame;

	for (unsigned int i = 0; i < requests.size(); i++) {
		auto *single_client = Object::cast_to<RpcSingleHttpRequestClient>(requests[i]);
		single_client->process(delta);
		if (single_client->is_completed()) {
			requests.pop_at(i);
			i--;
		}
	}
}

void RpcMultiHttpRequestClient::asynchronous_request(const Dictionary &request_body, const Dictionary &parsed_url, const Callable &callback, float timeout) {
	RpcSingleHttpRequestClient *new_client = memnew_custom(RpcSingleHttpRequestClient);
	requests.append(new_client);
	new_client->asynchronous_request(request_body, parsed_url, callback, timeout);
}

} //namespace godot