extends Object
class_name Uniform
## The base class for all uniform types.

## Emitted when an internal RID is updated
signal rid_updated(uniform: Uniform)

## Return an RDUniform object with the given [param binding]. Used internally by [ComputeHelper].
func get_rd_uniform(_binding: int) -> RDUniform:
	return null
