extends Node

"""
How this shit works: (RN IT DOESNT)

This 'manager' can have any amount of groups and
these groups can be made from the outside and require a 'getter'.

Objects can then 'subscribe' to a group with a 'setter'.
Each frame this 'manager' will go through each 'subscriber' in each group
and use the aforementioned 'getter' and 'setter's to sync a value from the 
getter object with that of the subscribed objects.

When subscribing to a group the caller gets an ID in return. This ID must
be used in order to unsubscribe for a group.

Deleting a group will automatically unsubscribe all objects from said group.

When the getter of a group is about to be deleted it will receive the
'freed_getter_warning' singal along with the group it belongs to.
After getting this signal said getter can assign an 'heir' to the group using
the 'set_getter_heir()' function, allowing the getter role to be passed on.
If the getter does not do this this manager will automatically try to request
any other subscribers to take this role using the 'new_getter_request' signal.
Any object receiving this signal can accept using the 'accept_getter_role' function.
This will make that object the new getter.
"""

class Ref:
	var object: Object
	var funcname: String
	func _init(_object: Object, _funcname: String):
		object = _object
		funcname = _funcname
	func is_valid() -> bool:
		return is_instance_valid(object) and object.has_method(funcname)
	func ref() -> FuncRef:
		return funcref(object, funcname)

var subscriptions: Dictionary = {}
var subcounts: Dictionary = {}
var getters: Dictionary = {}
var id_groups: Array = []
var id_indices: Array = []

enum GETTER_HEIR_STATUS {
	IDLE,
	AWAITING_HEIR,
	HEIR_RECEIVED,
	REQUESTED_HEIR,
	HEIR_ACCEPTED
}
var getter_heir_status: int = GETTER_HEIR_STATUS.IDLE
var getter_heir: Object
var getter_heir_group: String

# signal freed_getter_warning(group)
# signal new_getter_request(group)

func create_group(group: String, getter: Object, funcname: String):
	print("[Synchronizer]: Group '%s' created with getter " % group, getter, ":%s" % funcname)
	subscriptions[group] = []
	subcounts[group] = 0
	getters[group] = Ref.new(getter, funcname)

	getter.add_user_signal("freed_getter_warning", ["group"])
	getter.add_user_signal("new_getter_request", ["group"])
	getter.connect("tree_exiting", self, "_getter_freed", [group])

func delete_group(group: String):
	print("[Synchronizer]: Group '%s' with %d subscribers deleted" % [group, subcounts[group]])
	subscriptions.erase(group)
	subcounts.erase(group)
	getters.erase(group)
	for id in range(id_groups.size()):
		if id_groups[id] == group: unsubscribe(id)

func has_group(group: String) -> bool:
	return subscriptions.has(group)

func get_subscriber_count(group: String) -> int:
	return subcounts.get(group, -1)

func subscribe(group: String, setter: Object, funcname: String) -> int:
	if not subscriptions.has(group):
		var msg = "[Synchronizer]: Cannot subscribe to non-existent group '%s'" % [group]
		printerr(msg)
		assert(false, msg)
		
	setter.add_user_signal("freed_getter_warning", ["group"])
	setter.add_user_signal("new_getter_request", ["group"])

	subscriptions[group].append(Ref.new(setter, funcname))
	print("[Synchronizer]: ", setter, " subscribed to '%s' with '%s' (count: %d)" % [group, funcname, subcounts[group] + 1])

	id_groups.append(group)
	id_indices.append(subscriptions[group].size() - 1)
	subcounts[group] += 1
	return id_groups.size() - 1
	
func unsubscribe(id: int):
	var group = id_groups[id]
	id_groups[id] = null
	var index = id_indices[id]
	id_indices[id] = null
	subcounts[group] -= 1
	print("[Synchronizer]: subscriber #%d unsubscribed from '%s' (count: %d)" % [id, group, subcounts[group]])
	subscriptions[group][index] = null

func _getter_freed(group: String):
	print("[Synchronizer]: Getter from group '%s' freed" % group)
	getter_heir_status = GETTER_HEIR_STATUS.AWAITING_HEIR;
	getter_heir_group = group
	getters[group].emit_signal("freed_getter_warning", group)
	
	# yield(get_tree(), "idle_frame") # allowing set_getter_heir use
	
	if getter_heir_status == GETTER_HEIR_STATUS.HEIR_RECEIVED:
		print("[Synchronizer]: New getter for group '%s' set: " % group, getter_heir.object, ":", getter_heir.funcname)
		getters[group] = getter_heir
		getter_heir_status = GETTER_HEIR_STATUS.IDLE
	
	else:
		# no heir given: ask all subs
		getter_heir_status = GETTER_HEIR_STATUS.REQUESTED_HEIR
		for sub in subscriptions[group]:
			sub.object.emit_singal("new_getter_request", group)
			if getter_heir_status == GETTER_HEIR_STATUS.HEIR_ACCEPTED:
				getters[group] = getter_heir
				getter_heir_status = GETTER_HEIR_STATUS.IDLE
				break
		
		# no sub accepted: deleting group
		print("[Synchronizer]: No subscribers of group '%s' accepted getter inheritance" % group)
		delete_group(group)
			

func set_getter_heir(getter: Object, funcname: String):
	print("[Synchronizer]: Getter role of group '%s' set to " % getter_heir_group, getter, ":%s" % funcname)
	getter_heir = Ref.new(getter, funcname)
	getter_heir_status = GETTER_HEIR_STATUS.HEIR_RECEIVED

func accept_getter_role(getter: Object, funcname: String):
	print("[Synchronizer]: Getter role of group '%s' accepted by " % getter_heir_group, getter, ":%s" % funcname)
	getter_heir = Ref.new(getter, funcname)
	getter_heir_status = GETTER_HEIR_STATUS.HEIR_ACCEPTED

func _physics_process(_delta):
	for group in subscriptions:

		if not getters[group].is_valid():
			var msg = "[Synchronizer]: Getter of group '%s' unreachable" % [group]
			printerr(msg)
			assert(false, msg)

		var value = getters[group].ref().call_func()
		for setter in subscriptions[group]:
			if setter != null:
				setter.ref().call_func(value)
