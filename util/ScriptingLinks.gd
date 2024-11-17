extends Object

class_name ScriptingLinks

var head : LinkedListNode = null  # First node in the linked list
var prev_node : LinkedListNode = null
signal tree_reset

# Constructor method
func _init():
	head = LinkedListNode.new(Scripting_Utils.init_chain)
	prev_node = head

func duplicate() -> ScriptingLinks: # creates full duplication
	var new_copy = ScriptingLinks.new()
	new_copy.head = head.duplicate()
	copy_children(head, new_copy.head)
	return(new_copy)

func copy_children(head, new_head):
	for child in head.children:
		var new_child = child.duplicate()
		new_head.children.append(new_child)
		copy_children(child, new_child)

# Add a function reference to the linked list
func add_node(func_ref: Callable, parents: Array, children: Array) -> void:
	var new_node = LinkedListNode.new(func_ref)
	for parent in parents:
		new_node.add_parent(parent)
	for child in children:
		new_node.add_child(child)

func run_next() -> void:
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

func reset_all_children(node : LinkedListNode):
	for child in node.children:
		reset_all_children(child)
	node.run = false

func reset_tree() -> void:
	reset_all_children(head)
	tree_reset.emit()
