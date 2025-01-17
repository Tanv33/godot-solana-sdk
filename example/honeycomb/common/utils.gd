extends HoneyComb

var admin_keypair: Keypair = Keypair.new_from_file("res://admin.json")
var user_keypair: Keypair = Keypair.new_from_file("res://user.json")
const AUTH_TOKEN_FILE_PATH = "res://auth_token.txt"
const LAMPORTS_PER_SOL = 1_000_000_000
const AIRDROP_AMOUNT = 3 * LAMPORTS_PER_SOL
const ADMIN_FILE_PATH = "res://admin.json"
const USER_FILE_PATH = "res://user.json"


func print_transaction_url(signature: String):
	if signature:
		print("Transaction URL: https://solscan.io/tx/%s?cluster=custom&customUrl=https://rpc.test.honeycombprotocol.com" % signature)

func extract_transaction(response: Dictionary):
	if response.has("tx"):
		return response.tx.transaction
	elif response.has("transaction"):
		return response.transaction
	return ""

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
	auth_request(wallet, use_tx, use_rpc)  # Call the SDK method
	var auth_response = await query_response_received
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
	auth_confirm(wallet, signature)  # Call the SDK method
	# Process the SDK response
	var confirm_response = await query_response_received
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

# Utility function to mark a test as passed
func PASS(unique_identifier: int):
	# passed_test_mask += (1 << unique_identifier)
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
		print_transaction_url(response.result if response.has("result") else "")

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
	var project: Dictionary
	create_create_project_transaction(
		authority,
		project_name,
		"",  # Description
		[],  # Tags
		null,  # Category
		false,  # Is private
		payer
	)
	var response = await query_response_received
	var project_address = response.createCreateProjectTransaction.project

	var encoded_tx = extract_transaction(response.createCreateProjectTransaction)
	if not encoded_tx.is_empty():
		await process_transaction(encoded_tx, [admin_keypair])

	find_projects([project_address])
	var project_resp = await query_response_received
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
			print_transaction_url(fund_response.result if fund_response.has("result") else "")

	if create_profiles_tree:
		print("Creating profile trees...")
		var tree_config = load("res://resources/new_tree_setup_config.tres")
		create_create_profiles_tree_transaction(
			tree_config,
			project_address,
			payer,
		)
		var tree_response = await query_response_received
		var en_tx = extract_transaction(tree_response.createCreateProfilesTreeTransaction)
		if not en_tx.is_empty():
			await process_transaction(en_tx, [admin_keypair])

		find_projects([project_address])
		var project_response = await query_response_received
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
		create_initialize_badge_criteria_transaction(badge_criteria_input)
		var badge_response = await query_response_received
		var en_tx = extract_transaction(badge_response.createInitializeBadgeCriteriaTransaction)
		if not en_tx.is_empty():
			await process_transaction(en_tx, [admin_keypair])

		find_projects([project_address])
		var project_response = await query_response_received
		project = project_response.project[0]
	return project




func create_or_find_wallet(payer_file_path: String, amount: int):
	var keypair = await setup_payer(payer_file_path, amount)
	if keypair:
		print("Account initialized with public key: ", keypair.get_public_string())
	return keypair

func setup_payer(file_path: String, amount: int):
	return await create_keypair_and_airdrop(file_path, amount)

func create_keypair_and_airdrop(filename: String, amount: int):
	# Generate and save keypair
	var keypair: Keypair = Keypair.new_from_file(filename)
	#var keypair: Keypair = Keypair.new_random()
#
	#if not save_keypair(keypair, filename):
		#return null
		#
	 ##Request airdrop
	#if not await request_airdrop_func(keypair.get_public_string(), amount):
		#return null
		
	return keypair



func request_airdrop_func(wallet: String, amount: int):
	var solana_client = SolanaClient.new()
	add_child(solana_client)
	solana_client.request_airdrop(wallet, amount)
	var response = await solana_client.http_response_received
	if not response or not response.has("result"):
		print("Failed to receive airdrop")
		return false
	else:
		print("Failed to receive airdrop")
		print_transaction_url(response.result)
		return true


func save_keypair(keypair: Keypair, filename: String):
	keypair.save_to_file(filename)
	
	var file_check = FileAccess.open(filename, FileAccess.READ)
	if not file_check:
		push_error("Failed to save keypair to file: %s" % filename)
		return false
	file_check.close()
	return true
