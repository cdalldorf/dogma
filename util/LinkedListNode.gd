# File: LinkedListNode.gd
extends Object

class_name LinkedListNode

var ScriptingLinks_link : ScriptingLinks
var func_ref = null  # Stores the function to call
var func_name : String = ''
var inputs = null # inputs to the function
var parent : LinkedListNode
var children : Array = []
var run = false

signal func_output # there's multiple outputs now, this doesn't work, how about you send a message for them to do this

func _init(_func_ref, max_children : int, _inputs = null, ):
	func_ref = _func_ref
	var null_array = []
	null_array.resize(max_children)
	null_array.fill(null)
	children = null_array
	func_name = str(func_ref).split('::')[1]
	inputs = _inputs

func duplicate(ribo): # does not duplicate parents/children
	var new_copy = LinkedListNode.new(func_ref, len(children), inputs)
	var old_to_new = {
		'init_chain' : Scripting_Utils.init_chain,
		'pass_on' : Scripting_Utils.pass_on,
		'random_switch' : Scripting_Utils.random_switch,
		'spawn_ribosome' : ribo.spawn_ribosome,
		'spawn_protein' : ribo.spawn_protein,
		'spawn_lipid' : ribo.spawn_lipid,
	}
	new_copy.func_ref = old_to_new[func_name]
	new_copy.ScriptingLinks_link = ribo.function_tree
	return(new_copy)

func call_node() -> LinkedListNode:
	var check = null
	if inputs:
		check = func_ref.call(inputs)
	else:
		check = func_ref.call()
	if check is Array:
		func_output.emit(check) # update the UI if needed
		if len(children) > 0:
			var true_index = check.find(true)
			return(children[true_index])
		else:
			return(null)
	return(null)

func find_root() -> LinkedListNode:
	var curr = self
	while len(curr.parents) > 0:
		curr = curr.parents[0]
	return(curr)

func add_child(child : LinkedListNode, index : int = 0):
	children[index] = child
	child.parent = self

func remove_child(child : LinkedListNode):
	children.erase(child)
	child.parents.erase(self)

func add_parent(_parent : LinkedListNode):
	parent = _parent
	parent.children.append(self)

func remove_parent():
	parent = null
	parent.children.erase(self)
