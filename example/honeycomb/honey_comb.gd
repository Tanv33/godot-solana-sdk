extends HoneyComb

var utils = load("res://common/utils.gd").new()
# const AUTH_TOKEN_FILE_PATH = "res://auth_token.txt"

#Constants
const LAMPORTS_PER_SOL = 1_000_000_000
const AIRDROP_AMOUNT = 2 * LAMPORTS_PER_SOL
const ADMIN_FILE_PATH = "res://admin.json"	
const USER_FILE_PATH = "res://user.json"


func _ready():
	await before_all()
	#await run_project_tests()
	await run_user_tests()

func before_all():
	await create_account(ADMIN_FILE_PATH, AIRDROP_AMOUNT)
	await create_account(USER_FILE_PATH, AIRDROP_AMOUNT)

func run_project_tests():
	var project_flow = load("res://tests/test_project.gd").new()
	add_child(project_flow)
	await project_flow.execute()

func run_user_tests():
	var user_flow = load("res://tests/test_user.gd").new()
	add_child(user_flow)
	await user_flow.execute()


func create_account(payer_file_path: String, amount: int):
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

	#if not save_keypair(keypair, filename):
		#return null
		
	 #Request airdrop
	#if not await request_airdrop_func(keypair.get_public_string(), amount):
		#return null
		
	return keypair



func request_airdrop_func(wallet: String, amount: int):
	$SolanaClient.request_airdrop(wallet, amount)
	var response = await $SolanaClient.http_response_received
	if not response or not response.has("result"):
		print("Failed to receive airdrop")
		return false
	else:
		print("Failed to receive airdrop")
		utils.print_transaction_url(response.result)
		return true


func save_keypair(keypair: Keypair, filename: String):
	keypair.save_to_file(filename)
	
	var file_check = FileAccess.open(filename, FileAccess.READ)
	if not file_check:
		push_error("Failed to save keypair to file: %s" % filename)
		return false
	file_check.close()
	return true
