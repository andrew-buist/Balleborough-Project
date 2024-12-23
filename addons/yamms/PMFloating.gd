# MIT License
# 
# Copyright (c) 2023 Mattiny
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
@tool
extends PlacementMode
class_name PMFloating




func _debug(message):
	if _debug_messages:
		print("YAMMS: PMFloating:  " + message)

func place_item(
		scatter_item,
		index : int,
		pos_3D : Vector3, 
		avg_height, 
		global_position,
		normal_influence,
		rotation, 
		scale, 
		min_offset_y,
		max_offset_y,
		collision_mask, 
		space,
		additionalScene,
		targetNode) -> bool:

	# Distribute ScatterItems floating: 
	# some random height between min and max y.
	pos_3D.y = generate_random(min_offset_y, max_offset_y)
	_debug("Set position for index %s to %s" %[index, pos_3D])
	var transform = create_transform(pos_3D, rotation, scale)
	scatter_item.do_transform(index, transform)
	_place_additional_scene(additionalScene, targetNode, transform)
	return true
