#ifndef SOLANA_SDK_MPL_TOKEN_PROGRAM
#define SOLANA_SDK_MPL_TOKEN_PROGRAM


#include <godot_cpp/classes/node.hpp>
#include <instruction.hpp>
#include <meta_data.hpp>
#include <solana_client.hpp>

namespace godot{

class MplTokenMetadata : public SolanaClient{
    GDCLASS(MplTokenMetadata, SolanaClient)
private:
    bool pending_fetch = false;

    void metadata_callback(const Dictionary& rpc_result);

protected:
    static void _bind_methods();

public:
    MplTokenMetadata();

    static const std::string ID;

    static Variant new_associated_metadata_pubkey(const Variant& mint);
    static Variant new_associated_metadata_pubkey_master_edition(const Variant& mint);

    Variant get_mint_metadata(const Variant& mint);

    static Variant create_metadata_account(const Variant& mint, const Variant& mint_authority, const Variant& update_authority, const Variant &meta_data, bool is_mutable);
    static Variant update_metadata_account(const Variant& metadata_account, const Variant& update_authority);
    static Variant create_master_edition(const Variant& mint, const Variant& update_authority, const Variant& mint_authority, const Variant &payer, const Variant &max_supply);
    static Variant get_pid();
};

}

#endif