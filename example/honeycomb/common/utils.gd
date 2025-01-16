extends Node

const LAMPORTS_PER_SOL = 1000000000



func print_transaction_url(signature: String):
	if signature:
		print("Transaction URL: https://solscan.io/tx/%s?cluster=custom&customUrl=https://rpc.test.honeycombprotocol.com" % signature)




func extract_transaction(response: Dictionary):
	if response.has("tx"):
		return response.tx.transaction
	elif response.has("transaction"):
		return response.transaction
	return ""




# # Configuration
# const PAYER_FILE_PATH = "res://payer.json"
# const AIRDROP_AMOUNT = 2 * 1000000000  # 2 SOL in lamports
# const AUTH_TOKEN_FILE_PATH = "res://auth_token.txt"
# const TOTAL_CASES := 4
# var passed_test_mask := 0

# # Variables
# var user: User;
# var accessToken: String;
# var project: Project;
# var profile: Profile;

# # Initialize Solana components and connections
# func initialize_solana():
# 	solana_utility = SolanaUtils.new()
# 	TransactionInstance = Transaction.new()
# 	connect("query_error_occurred", Callable(self, "_on_query_error_occurred"))


# # Called when the node enters the scene tree for the first time.
# func _ready():
# 	print("Start running User tests...")
# 	initialize_solana()
# 	pass

#func _on_timeout_timeout(TOTAL_CASES:int,passed_test_mask:int):
	#for i in range(TOTAL_CASES):
		#if ((1 << i) & passed_test_mask) == 0:
			#print("[FAIL]: ", i)
