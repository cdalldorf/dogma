# File: LinkedListNode.gd
extends Object

class_name LinkedListNode

var func_ref : Callable  # Stores the function to call
var parents : Array = [] # ParentChildNode
var children : Array = []
var run = false

signal output_true

func _init(_func_ref: Callable):
	func_ref = _func_ref

func call_node():
	if not run:
		var check = func_ref.call()
		if check: output_true.emit()
	run = true

func find_root() -> LinkedListNode:
	var curr = self
	while len(curr.parents) > 0:
		curr = curr.parents[0]
	return(curr)

func check_sibilings():
	var sibs = []
	for parent in parents:
		for child in parent.children:
			sibs.append(child)
	return sibs

func add_child(child : LinkedListNode):
	children.append(child)
	child.parents.append(self)

func remove_child(child : LinkedListNode):
	children.erase(child)
	child.parents.erase(self)

func add_parent(parent : LinkedListNode):
	if parent == null:
		return
	parents.append(parent)
	parent.children.append(self)

func remove_parent(parent : LinkedListNode):
	parents.erase(parent)
	parent.children.erase(self)
