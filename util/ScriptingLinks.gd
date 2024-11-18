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

static func unserialize(input_str : String, ribo) -> ScriptingLinks:
	var old_to_new = {
		'init_chain' : Scripting_Utils.init_chain,
		'pass_on' : Scripting_Utils.pass_on,
		'random_switch' : Scripting_Utils.random_switch,
		'spawn_ribosome' : ribo.spawn_ribosome,
		'spawn_protein' : ribo.spawn_protein,
		'spawn_lipid' : ribo.spawn_lipid,
	}
	var new_SL = ScriptingLinks.new()
	var node_to_func_input_parent_children_new_node = {}
	var options = input_str.split("__START__")
	for node_str in options.slice(1, len(options)):
		var node_id = node_str.split('<')[1].split('>')[0]
		var func_name = node_str.split(' \"')[1].split('\",')[0]
		var input_val = node_str.split('\", ')[2].split(',')[0]
		if 'null' in input_val:
			input_val = null
		var parent_val = 'Obj'+node_str.split(', ')[3]
		if 'null' in parent_val:
			parent_val = null
		var children_val = node_str.split('[')[1].split(']')[0]
		var func_ref = old_to_new[func_name]
		var new_node = null
		if input_val:
			new_node = LinkedListNode.new(func_ref, len(children_val.split(',')), float(input_val))
		else:
			new_node = LinkedListNode.new(func_ref, len(children_val.split(',')))
		node_to_func_input_parent_children_new_node[node_id] = [func_name, input_val, parent_val, children_val, new_node]
		if 'init_chain' == func_name:
			new_SL.head = new_node
			new_SL.next_node = new_node
			
	# let's add children to connect them
	for node in node_to_func_input_parent_children_new_node.keys():
		var children = node_to_func_input_parent_children_new_node[node][3].split(',')
		var node_ref = node_to_func_input_parent_children_new_node[node][4]
		var i = 0
		for child in children:
			if 'null' not in child and len(child) > 0:
				var index = child.replace('>', '').replace('<', '').replace(' ', '')
				var child_node = node_to_func_input_parent_children_new_node[index]#[4]
				node_ref.add_child(child_node[4], i)
			i += 1
	return(new_SL)

func serialize() -> String:
	# converts the scriptinglinks into a string that can be saved, later create function to undo this
	var all_nodes = find_all_children(head)
	var output = []
	for node in all_nodes:
		output.append(['__START__', node, node.func_name, node.inputs, node.parent, node.children, '__END__'])
	return(str(output))

func find_all_children(node, node_list = []) -> Array:
	node_list.append(node)
	for child in node.children:
		if child:
			find_all_children(child, node_list)
	return(node_list)

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
