ServiceRegistry = require './Registry'

#//
#	Service
#
#	basic service object, designed to automatically reimplement itself
#	when the serve method is called.  because the match variable won't
#	ever match a type, we don't have to worry about cyclic calls.
#//
class exports.Service

	name:  "stub"
	match: "$^"

	ServiceRegistry.register @

	serve: (context, stream) -> ServiceRegistry.reimplement @, @id; @serve context, stream


#//
#	GenericService
#	
#	basic service designed to capture requests not matched by any other
#	registered service types.
#//
class exports.GenericService

	name:  "generic"
	match: ".*"

	ServiceRegistry.register @

	serve: (context, stream) -> stream.write "I am a #{@name} service for #{@id}.\n"

#//
#	DirectoryService
#
#	output directory information (currently unimplemented), but
#	could be useful for stats collection or for overriding in a
#	custom implementation.
#//
class exports.DirectoryService

	name:  "directory"
	match: "^[^\.]"

	ServiceRegistry.register @