extends Node

# Dependencies and Constants
var utils = load("res://common/utils.gd").new()
var client: HoneyComb
var project: Dictionary
var character_model: Dictionary
var assets: Dictionary = {}
var passed_test_mask: int = 0 # Track passed test cases using a bitmask
const TOTAL_CASES :int = 5 # Total number of test cases
var admin_keypair: Keypair = Keypair.new_from_file("res://admin.json")
var user_keypair: Keypair = Keypair.new_from_file("res://user.json")
const TOTAL_MPL_CORE_NFTS = 1
const TOTAL_NFTS = 1
const TOTAL_CNFTS = 1
const TOTAL_EXTENSIONS_NFT = 0

# Main execution function
func execute():
	await before_all()
	await run_tests()

# Run all test cases
func run_tests():
	await create_or_load_character_model()
	# Additional tests will be added step by step

# Setup function to initialize required data
func before_all():
	client = HoneyComb.new()
	add_child(client)  # Add the client to the node tree
	await mint_assets()
	await create_project()


# Test: Create or Load Character Model
func create_or_load_character_model():
	print("Creating or loading character model...")
	# Logic for creating or loading a character model will be implemented here


# Function to mint assets
func mint_assets(
	umi: Umi,
	count: Dictionary,
	beneficiary: String,
	collection: String = "",
	core_collection: String = "",
	tree: String = "",
	connection: Connection = Connection.new_from_endpoint(umi.rpc.get_endpoint()),
	admin_keypair: Keypair = admin_keypair,
	options: Dictionary = {"confirm": {"commitment": "finalized"}}
):
	# Convert beneficiary, collection, and tree to public keys if provided
	beneficiary = Pubkey.new_from_string(beneficiary)
	if collection != "":
		collection = Pubkey.new_from_string(collection)
	if tree != "":
		tree = Pubkey.new_from_string(tree)
	
	var response: Dictionary = {}
	
	# Helper function to handle errors
	func resist_error(err):
		print_error("Error occurred: ", err)
		return null

	# Mint assets concurrently (mimicking Promise.all in TS)
	response.core = yield(mint_mpl_core_collection(umi, count["core"], beneficiary, core_collection, options), "completed") or resist_error()
	response.pnfts = yield(mint_mpl_tm_collection(umi, count["pnfts"], beneficiary, collection, options), "completed") or resist_error()
	response.token22 = yield(mint_token2022_collection(connection, admin_keypair, count["token22"], beneficiary, null, options), "completed") or resist_error()
	
	# Mint compressed NFTs (if applicable)
	var c = response.pnfts and response.pnfts.group or collection
	if c:
		response.cnfts = yield(mint_mpl_bg_collection(connection, admin_keypair, count["cnfts"], Pubkey.new_from_string(c), beneficiary), "completed") or resist_error()
	
	return response




extends Node

# Dependencies
var utils = load("res://common/utils.gd").new()

# Define asset response structure
class_name AssetResponse
var core: Dictionary
var pnfts: Dictionary
var cnfts: Dictionary
var token22: Dictionary

# Mint MPL Core Collection
func mint_mpl_core_collection(umi: Umi, item_count: int, beneficiary: String, group: String = "", options: Dictionary = {"confirm": {"commitment": "finalized"}}) -> Dictionary:
	if item_count <= 0:
		return null

	var asset_signers = []
	for i in range(item_count):
		asset_signers.append(umi.generate_signer())

	var collection_with_mints = {"group": group, "mints": [], "asset": "MPL_CORE"}
	if group == "" and asset_signers.size() > 0:
		var collection_signer = umi.generate_signer()
		umi.create_collection(collection_signer, "My Collection", "https://example.com/my-collection.json").send_and_confirm(umi, options)
		collection_with_mints["group"] = collection_signer.public_key

	for i in asset_signers:
		umi.create_v1(i, {
			"uri": "https://arweave.net/WhyRt90kgI7f0EG9GPfB8TIBTIBgX3X12QaF9ObFerE",
			"name": "Test Nft MPL Core %d" % asset_signers.index(i),
			"collection": collection_with_mints["group"],
			"owner": beneficiary
		}).send_and_confirm(umi, options)
		collection_with_mints["mints"].append(i.public_key)

	return collection_with_mints

# Mint MPL TM Collection
func mint_mpl_tm_collection(umi: Umi, item_count: int, beneficiary: String, group: String = "", options: Dictionary = {"confirm": {"commitment": "finalized"}}) -> Dictionary:
	if item_count <= 0:
		return null

	var asset_signers = []
	for i in range(item_count):
		asset_signers.append(umi.generate_signer())

	var collection_with_mints = {"group": group, "mints": [], "asset": "MPL_TM"}
	if group == "" and asset_signers.size() > 0:
		var collection_signer = umi.generate_signer()
		umi.create_nft(collection_signer, {
			"name": "My Collection",
			"uri": "https://example.com/my-collection.json",
			"seller_fee_basis_points": 55,  # 5.5%
			"is_collection": true
		}).send_and_confirm(umi, options)
		collection_with_mints["group"] = collection_signer.public_key

	for i in asset_signers:
		umi.create_programmable_nft(i, {
			"uri": "https://arweave.net/WhyRt90kgI7f0EG9GPfB8TIBTIBgX3X12QaF9ObFerE",
			"name": "Test Nft MPL TM %d" % asset_signers.index(i),
			"collection": {"key": collection_with_mints["group"], "verified": false},
			"seller_fee_basis_points": 55,
			"token_owner": beneficiary
		}).add(umi.verify_collection_v1(collection_with_mints["group"], umi.find_metadata_pda(i.public_key))).send_and_confirm(umi)
		collection_with_mints["mints"].append(i.public_key)

	return collection_with_mints

# Mint MPL BG Collection
func mint_mpl_bg_collection(connection: Connection, admin_keypair: Keypair, item_count: int, collection_mint: String, beneficiary: String, group: String = "", options: Dictionary = {"confirm": {"commitment": "finalized"}}) -> Dictionary:
	if item_count <= 0:
		return null

	var collection_with_mints = {"group": group, "mints": [], "asset": "MPL_BG"}
	if group == "" and item_count > 0:
		collection_with_mints["group"] = connection.create_new_tree(admin_keypair)[0]

	for i in range(item_count):
		connection.mint_one_cnft(admin_keypair, {
			"drop_wallet_key": beneficiary,
			"name": "cNFT #%d" % i,
			"symbol": "cNFT",
			"uri": "https://arweave.net/WhyRt90kgI7f0EG9GPfB8TIBTIBgX3X12QaF9ObFerE",
			"collection_mint": collection_mint,
			"merkle_tree": collection_with_mints["group"]
		})

	collection_with_mints["mints"] = connection.fetch_helius_assets({
		"wallet_address": beneficiary,
		"collection_address": collection_mint
	}).filter(lambda asset: asset.has("compression"))
	return collection_with_mints

# Mint Token 2022 Collection
func mint_token2022_collection(connection: Connection, admin_keypair: Keypair, item_count: int, beneficiary: String, group: Dictionary = null, options: Dictionary = {"confirm": {"commitment": "finalized"}}) -> Dictionary:
	if item_count <= 0:
		return null

	if group == null:
		group = connection.create_2022_group({
			"name": "Extensions Group",
			"symbol": "Extensions",
			"uri": "https://example.com/my-collection.json",
			"max_size": item_count
		}, admin_keypair)

	var collection_with_mints = {"group": group["group_address"], "mints": [], "asset": "TOKEN_2022"}
	for i in range(item_count):
		var mint = connection.mint_one_2022_nft({
			"name": "Extensions #%d" % i,
			"symbol": "Extensions",
			"uri": "https://arweave.net/WhyRt90kgI7f0EG9GPfB8TIBTIBgX3X12QaF9ObFerE"
		}, beneficiary, admin_keypair, group, options)
		collection_with_mints["mints"].append(mint)

	return collection_with_mints

# Mint assets function
func mint_assets(umi: Umi, count: Dictionary, beneficiary: String, collection: String = "", core_collection: String = "", tree: String = "", connection: Connection = null, admin_keypair: Keypair = null, options: Dictionary = {"confirm": {"commitment": "finalized"}}) -> Dictionary:
	connection = connection or Connection.new_from_endpoint(umi.rpc.get_endpoint())
	admin_keypair = admin_keypair or admin_keypair

	var response = AssetResponse.new()
	func resist_error(err):
		print_error("Error: ", err)
		return null

	response.core = yield(mint_mpl_core_collection(umi, count.get("core", 0), beneficiary, core_collection, options), "completed") or resist_error()
	response.pnfts = yield(mint_mpl_tm_collection(umi, count.get("pnfts", 0), beneficiary, collection, options), "completed") or resist_error()
	response.token22 = yield(mint_token2022_collection(connection, admin_keypair, count.get("token22", 0), beneficiary, null, options), "completed") or resist_error()

	var c = response.pnfts and response.pnfts.group or collection
	if c:
		response.cnfts = yield(mint_mpl_bg_collection(connection, admin_keypair, count.get("cnfts", 0), c, beneficiary), "completed") or resist_error()

	return response


# Function to create a project
func create_project(
	project_name: String = "Test Project",
	authority: String = admin_keypair.get_public_string(),
	payer: String = admin_keypair.get_public_string(),
	subsidize_fees: bool = true,
	create_profiles_tree: bool = true,
	create_badging_criteria: bool = true
):
	print("Creating project...")

	client.create_create_project_transaction(
		authority,
		project_name,
		"",  # Description
		[],  # Tags
		null,  # Category
		false,  # Is private
		payer
	)
	var response = await client.query_response_received
	var project_address = response.createCreateProjectTransaction.project

	var encoded_tx = utils.extract_transaction(response.createCreateProjectTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [admin_keypair])

	client.find_projects([project_address])
	var project_resp = await client.query_response_received
	project = project_resp.project[0] if project_resp.project.size() > 0 else {}

	assert(project != null, "Project should be created successfully.")

	if subsidize_fees:
		print("Funding project for subsidy...")
		var tx = transfer_lamports(
			project_address,
			admin_keypair,
			1_000_000_000  # 1 SOL
		)
		var fund_response = await tx.transaction_response_received
		if fund_response:
			utils.print_transaction_url(fund_response.result if fund_response.has("result") else "")

	if create_profiles_tree:
		print("Creating profile trees...")
		var tree_config = load("res://resources/new_tree_setup_config.tres")
		client.create_create_profiles_tree_transaction(
			tree_config,
			project_address,
			payer,
		)
		var tree_response = await client.query_response_received
		var en_tx = utils.extract_transaction(tree_response.createCreateProfilesTreeTransaction)
		if not en_tx.is_empty():
			await process_transaction(en_tx, [admin_keypair])

		client.find_projects([project_address])
		var project_response = await client.query_response_received
		project = project_response.project[0]
		print("project: ", project)
		assert(
			project.profileTrees.merkle_trees[project.profileTrees.active] != null,
			"Profile trees should be created successfully."
		)

	if create_badging_criteria:
		print("Initializing badge criteria...")
		var badge_criteria_input: CreateBadgeCriteriaInput = load("res://resources/new_create_badge_criteria_input.tres")
		badge_criteria_input.authority = admin_keypair.get_public_string()
		badge_criteria_input.projectAddress = project.address
		badge_criteria_input.endTime = Time.get_unix_time_from_system() + 60 * 60 * 24 * 7
		badge_criteria_input.startTime = Time.get_unix_time_from_system()
		badge_criteria_input.badgeIndex = 0
		badge_criteria_input.payer = admin_keypair.get_public_string()
		badge_criteria_input.condition = BadgesCondition.get_public()
		client.create_initialize_badge_criteria_transaction(badge_criteria_input)
		var badge_response = await client.query_response_received
		var en_tx = utils.extract_transaction(badge_response.createInitializeBadgeCriteriaTransaction)
		if not en_tx.is_empty():
			await process_transaction(en_tx, [admin_keypair])

		client.find_projects([project_address])
		var project_response = await client.query_response_received
		project = project_response.project[0]


# Utility function to transfer lamports
func transfer_lamports(receiver: String, payer: Keypair, amount: int):
	print("Payer Public Key: ", payer.get_public_string())
	print("Receiver Address: ", receiver)

	var tx = Transaction.new()
	add_child(tx)

	var ix = SystemProgram.transfer(
		Pubkey.new_from_string(payer.get_public_string()),  # Sender
		Pubkey.new_from_string(receiver),  # Receiver
		amount  # Amount in lamports
	)
	tx.add_instruction(ix)
	tx.set_payer(Pubkey.new_from_string(payer.get_public_string()))
	tx.update_latest_blockhash()

	print("Signing transaction...")
	tx.set_signers([payer])
	tx.partially_sign([payer])

	print("Sending transaction...")
	tx.send()
	print("Transaction successfully sent.")
	return tx

# Utility function to mark a test as passed
func PASS(unique_identifier: int):
	passed_test_mask += (1 << unique_identifier)
	print("[OK]: ", unique_identifier)

# Utility function to process a transaction
func process_transaction(encoded_transaction: String, signers: Array[Keypair]):
	var tx = await send_transaction(encoded_transaction, signers)
	if not tx:
		print("Failed to create transaction")
		return

	print("Transaction sent, awaiting response...")
	var response = await tx.transaction_response_received
	tx.queue_free()

	if response:
		utils.print_transaction_url(response.result if response.has("result") else "")

# Utility function to send a transaction
func send_transaction(encoded_transaction: String, signers: Array[Keypair]):
	var decoded_tx = SolanaUtils.bs58_decode(encoded_transaction)
	var transaction = Transaction.new_from_bytes(decoded_tx)
	add_child(transaction)

	transaction.set_signers(signers)
	print("Signing transaction...")
	transaction.partially_sign(signers)
	transaction.send()
	return transaction
