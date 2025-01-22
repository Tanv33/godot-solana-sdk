extends Node

## Dependencies and Constants
var utils = load("res://common/utils.gd").new()
var assets = load("res://common/assets.gd").new()
var client: HoneyComb
var project: Dictionary
var character_model: Dictionary
#var assets: Dictionary = {}
var passed_test_mask: int = 0 # Track passed test cases using a bitmask
const TOTAL_CASES :int = 5 # Total number of test cases
const TOTAL_MPL_CORE_NFTS = 1
const TOTAL_NFTS = 1
const TOTAL_CNFTS = 1
const TOTAL_EXTENSIONS_NFT = 0

## Main execution function
func execute():
	print("start....")
	await before_all()
	#await run_tests()
#
# Run all test cases
# func run_tests():
	# await create_or_load_character_model()
	# Additional tests will be added step by step

# Perform pre-test setup
func before_all():
	add_child(utils)
	add_child(assets)
	client = HoneyComb.new()
	add_child(client)  # Add the client to the node tree
	await assets.mint_assets()



# Test: Create or Load Character Model
func create_or_load_character_model():
	print("Creating or loading character model...")
	# Logic for creating or loading a character model will be implemented here
