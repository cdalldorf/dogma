# File: LinkedList.gd
extends Object

class_name ScriptingLinks

var head : LinkedListNode = null  # First node in the linked list
var prev_node : LinkedListNode = null
var all_nodes : Array = []

# Constructor method
func _init():
	head = LinkedListNode.new(Scripting_Utils.init_chain)
	prev_node = head
	
# Add a function reference to the linked list
func add_node(func_ref: Callable, parents: Array, children: Array) -> void:
	var new_node = LinkedListNode.new(func_ref)
	for parent in parents:
		new_node.add_parent(parent)
	for child in children:
		new_node.add_child(child)
	all_nodes.append(new_node)

func run_next() -> LinkedListNode:
	# check if sibilings have been run
	for sib in prev_node.check_sibilings():
		if not sib.run:
			sib.call_node()
			prev_node = sib
			return
	
	# move on to children
	for child in prev_node.children:
		if not child.run:
			child.call_node()
			prev_node = child
			return
	
	# none are callable, let's reset all
	reset_tree()
	head.call_node()
	prev_node = head
	return

func reset_tree() -> void:
	for node in all_nodes:
		node.run = false
