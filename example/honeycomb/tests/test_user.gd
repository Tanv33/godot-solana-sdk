extends Node

# Dependencies and Constants
var utils = load("res://common/utils.gd").new()
var client: HoneyComb
var project: Dictionary
var profile: Dictionary
var user: Dictionary
var admin_keypair: Keypair = Keypair.new_from_file("res://admin.json")
var user_keypair: Keypair = Keypair.new_from_file("res://user.json")
var access_token: String = ""
var passed_test_mask: int = 0 # Track passed test cases using a bitmask
const TOTAL_CASES :int = 5 # Total number of test cases
const AUTH_TOKEN_FILE_PATH = "res://auth_token.txt"

# Load user information from resources
var user_info: UserInfoInput = load("res://resources/new_user_info_input.tres")

# Main execution function
func execute():
	await before_all()
	await run_tests()

# Run all test cases
func run_tests():
	await create_or_load_user_with_profile()
	await update_profile()
	await add_wallet()
	await remove_wallet()
	await claim_badge_criteria()

# Setup function to initialize required data
func before_all():
	client = HoneyComb.new()
	add_child(client)  # Add the client to the node tree
	await create_project()

# Test: Create or Load User with Profile
func create_or_load_user_with_profile():
	# Step 1: Check if user exists by wallet
	client.find_users([], [], [user_keypair.get_public_string()])
	var user_response = await client.query_response_received
	user = user_response.user[0] if user_response.user.size() > 0 else {}
	print("user: ", user)

	# Step 2: If user doesn't exist, create a new user with profile
	if not user.has("address"):
		client.create_new_user_with_profile_transaction(
			project.address,
			user_keypair.get_public_string(),
			user_info,
			user_keypair.get_public_string(),
		)
		var res = await client.query_response_received
		var txn = utils.extract_transaction(res.createNewUserWithProfileTransaction)
		if not txn.is_empty():
			await process_transaction(txn, [user_keypair])

		# Re-fetch user after creation
		client.find_users([], [], [user_keypair.get_public_string()])
		var user_resp = await client.query_response_received
		user = user_resp.user[0] if user_resp.user.size() > 0 else {}

		# Assertions to validate user creation
		assert(user != null, "User should be created successfully.")
		assert(user.info.name == user_info.name, "User name should match.")
		assert(user.info.bio == user_info.bio, "User bio should match.")
		assert(user.info.pfp == user_info.pfp, "User profile picture should match.")

	# Step 3: Authorize the user if not already authorized
	if access_token.is_empty():
		await initiate_auth_request(user_keypair, user_keypair.get_public_string())
		access_token = load_auth_token()
		client.set_auth_token(access_token)
		var headers = client.get_headers()
		print("headers: ", headers)

	# Step 4: Check if a profile exists for the user
	client.find_profiles([], [project.address], [user.id])
	var profile_response = await client.query_response_received
	print("profile_response: ", profile_response)
	profile = profile_response.profile[0] if profile_response.profile.size() > 0 else {}

	# Step 5: If profile exists, validate it matches the user info
	if profile.has("name"):
		assert(profile.info.name == user_info.name, "Profile name should match.")
		assert(profile.info.bio == user_info.bio, "Profile bio should match.")
		assert(profile.info.pfp == user_info.pfp, "Profile picture should match.")
		return

	# Step 6: Create a new profile if it doesn't exist
	var profileInfo: ProfileInfoInput = load("res://resources/new_profile_info_input.tres")
	profileInfo.name = "(Profile) %s" % user_info["name"]
	profileInfo.bio = "This is profile of %s" % user_info["bio"]
	profileInfo.pfp = user_info.pfp

	client.create_new_profile_transaction(
		project.address,
		user_keypair.get_public_string(),
		"",
		profileInfo,
	)
	var tx_response = await client.query_response_received
	var encoded_tx = utils.extract_transaction(tx_response.createNewProfileTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [user_keypair])

	# Step 7: Fetch and validate the new profile
	client.find_profiles([], [project.address], [user.id])
	var profile_res = await client.query_response_received
	profile = profile_res.profile[0] if profile_res.profile.size() > 0 else {}
	
	# Assertions to validate profile creation
	assert(profile != null, "Profile should exist.")
	assert(profile.info.name == "(Profile) %s" % user_info["name"], "Profile name should match.")
	assert(profile.info.bio == "This is profile of %s" % user_info["bio"], "Profile bio should match.")
	assert(profile.info.pfp == user_info.pfp, "Profile picture should match.")

	print("User and Profile successfully created or loaded.")
	PASS(0)

# Test: Update Profile
func update_profile():
	var update_info: ProfileInfoInput = load("res://resources/new_profile_info_input.tres").duplicate()
	update_info.name = user.info.name + "_profile"
	var custom_data_input: CustomDataInput = load("res://resources/new_custom_data_input.tres")
	custom_data_input.add = {"customField": ["customValue"]}

	# Create the transaction using the resource
	client.create_update_profile_transaction(
		profile.address,
		user_keypair.get_public_string(),
		update_info,
		custom_data_input,
	)
	var tx_response = await client.query_response_received

	# Send the transaction using the provided utility function
	var encoded_tx = utils.extract_transaction(tx_response.createUpdateProfileTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [user_keypair])

	# Fetch the updated profile
	client.find_profiles([], [project.address], [user.id])
	var profile_response = await client.query_response_received
	profile = profile_response.profile[0] if profile_response.profile.size() > 0 else {}

	# Assertions to verify the updates
	assert(profile.info.name == user.info.name + "_profile", "Profile name should be updated.")
	assert(profile.customData.customField[0] == "customValue", "Custom field should be updated.")

	print("Profile successfully updated.")
	PASS(1)

# Test: Add Wallet
func add_wallet():
	var update_wallet_input: UpdateWalletInput = load("res://resources/new_update_wallet_input.tres")
	var new_wallet: Keypair = Keypair.new_random()
	print("new_wallet: ", new_wallet.get_public_string())
	update_wallet_input.add = [new_wallet.get_public_string()] as PackedStringArray

	client.create_update_user_transaction(
		user_keypair.get_public_string(),
		null,
		update_wallet_input,
		true
	)
	var tx_response = await client.query_response_received
	var encoded_tx = utils.extract_transaction(tx_response.createUpdateUserTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [user_keypair])

	client.find_users([], [], [user_keypair.get_public_string()])
	var user_response = await client.query_response_received
	user = user_response.user[0] if user_response.user.size() > 0 else {}
	assert(user != null, "User should still exist.")
	print(user.wallets.wallets)
	print(new_wallet.get_public_string())
	assert(user.wallets.wallets[-1] == new_wallet.get_public_string(), "User should contain new wallet")
	PASS(2)

# Test: Remove Wallet
func remove_wallet():
	var update_wallet_input: UpdateWalletInput = load("res://resources/new_update_wallet_input.tres").duplicate(true)
	update_wallet_input.remove = user.wallets.wallets[-1]
	update_wallet_input.add = []

	client.create_update_user_transaction(
		user_keypair.get_public_string(),
		null,
		update_wallet_input,
		false
	)
	var tx_response = await client.query_response_received

	var encoded_tx = utils.extract_transaction(tx_response.createUpdateUserTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [user_keypair])

	client.find_users([], [], [user_keypair.get_public_string()])
	var user_response = await client.query_response_received
	user = user_response.user[0] if user_response.user.size() > 0 else {}

	assert(user != null, "User should still exist after wallet removal.")
	assert(user.wallets.wallets.size() > 0, "Only one wallet should remain.")
	assert(user.wallets.wallets.has(user_keypair.get_public_string()), "Remaining wallet should match the original public key.")

	print("Wallet successfully removed. Remaining wallet: ", user.wallets.wallets)
	PASS(3)

# Test: Claim Badge Criteria
func claim_badge_criteria():
	var claim_badge_input: ClaimBadgeCriteriaInput = load("res://resources/new_claim_badge_criteria_input.tres")
	claim_badge_input.criteriaIndex = 0
	claim_badge_input.profileAddress = profile.address
	claim_badge_input.projectAddress = project.address
	claim_badge_input.proof = "Public"
	claim_badge_input.payer = user_keypair.get_public_string()

	client.create_claim_badge_criteria_transaction(claim_badge_input)
	var tx_response = await client.query_response_received

	var encoded_tx = utils.extract_transaction(tx_response.createClaimBadgeCriteriaTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [user_keypair])

	client.find_profiles([], [project.address], [user.id])
	var profile_response = await client.query_response_received
	profile = profile_response.profile[0] if profile_response.profile.size() > 0 else {}

	assert(profile != null, "Profile should exist.")
	assert(profile.platformData.achievements != null, "Achievements should exist.")
	assert(profile.platformData.achievements.size() > 0, "Achievements should not be empty.")

	print("Badge criteria successfully claimed. Achievements: ", profile.platformData.achievements)
	PASS(4)

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



func initiate_auth_request(payerKeypair: Keypair,wallet: String, use_tx: bool = false, use_rpc: String = ""):
	client.auth_request(wallet, use_tx, use_rpc)  # Call the SDK method
	var auth_response = await client.query_response_received
	if auth_response.has("authRequest"):
		#print("Authentication message: ", auth_response.authRequest)
		var message: PackedByteArray = String(auth_response.authRequest.message).to_ascii_buffer()
		var sig: PackedByteArray = payerKeypair.sign_message(message)
		assert(payerKeypair.verify_signature(sig, message))
		var signature = SolanaUtils.bs58_encode(sig)
		var res = await confirm_authentication(wallet, signature) 
		return res
	else:
		print("Failed to initiate auth request.")
		return {}

# Wrapper Function to Call auth_confirm from SDK and Handle the Response
func confirm_authentication(wallet: String, signature: String):
	client.auth_confirm(wallet, signature)  # Call the SDK method
	# Process the SDK response
	var confirm_response = await client.query_response_received
	if confirm_response.has("authConfirm"):
		var auth_token = confirm_response.authConfirm.accessToken
		print("Authentication successful. Token: ", auth_token)
		if not save_auth_token(auth_token):
			print("Failed to save authentication token.")
			return {}
		return confirm_response
	else:
		print("Failed to confirm authentication.")
		return {}

# Utility Function to Save the Authentication Token
func save_auth_token(auth_token: String):
	var file = FileAccess.open(AUTH_TOKEN_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for saving auth token.")
		return false
	file.store_string(auth_token)
	file.close()
	return true

# Utility Function to Load the Authentication Token
func load_auth_token():
	var file = FileAccess.open(AUTH_TOKEN_FILE_PATH, FileAccess.READ)
	if not file:
		print("Auth token file not found.")
		return ""
	var auth_token = file.get_as_text()
	file.close()
	return auth_token
