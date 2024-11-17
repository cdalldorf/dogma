extends Object

class_name ScriptingLinks

var head : LinkedListNode = null  # First node in the linked list
var next_node = null # next node to run
signal tree_reset

# Constructor method
func _init():
	head = LinkedListNode.new(Scripting_Utils.init_chain, 1)
	head.ScriptingLinks_link = self
	next_node = head

func duplicate(ribo) -> ScriptingLinks: # creates full duplication for new ribosome
	var new_copy = ScriptingLinks.new()
	var new_head = head.duplicate(ribo)
	new_copy.head = new_head
	copy_children(head, new_head, ribo)
	return(new_copy)

func copy_children(old_head, new_head, ribo):
	var i = 0
	for child in old_head.children:
		if child:
			var new_child = child.duplicate(ribo)
			new_head.add_child(new_child, i)
			copy_children(child, new_child, ribo)
		i += 1

# Add a function reference to the linked list
func add_node(func_ref: Callable, parents: Array, children: Array, max_children : int) -> void:
	var new_node = LinkedListNode.new(func_ref, max_children)
	for parent in parents:
		new_node.add_parent(parent)
	for child in children:
		new_node.add_child(child)

func run_next() -> void:
	# run next_node, which is set by the called node
	if next_node:
		next_node = next_node.call_node()
		return
		
	# none are callable, let's reset all
	reset_tree()

func reset_all_children(node : LinkedListNode):
	for child in node.children:
		if child:
			reset_all_children(child)
	node.run = false
	next_node = head

func reset_tree() -> void:
	reset_all_children(head)
	tree_reset.emit()
	next_node = head
