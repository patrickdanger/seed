#//
#	ServiceRegistry
#
#	object that handles registrations for new service types as well
#	as matching file types to the correct services.  self-implementing
#	services can use the reimplement method to assume the correct
#	service profile.
#//
class ServiceRegistry

	#/
	#	CONSTRUCTOR
	#
	#	create a new instance of ServiceRegistry and optionally
	#	pass in a reference to @services.
	#/
	constructor: (@services = {}) -> 

	#/
	#	register
	#
	#	register a service with this ServiceRegistry.  services
	#	are registered by adding their object prototype to the
	#	@services object, keyed by service.prototype.name.  if
	#	a service with the same key exists, the reference will
	#	be overwritten.
	#/
	register:    (s)       -> @services[s.prototype.name] = s
	
	#/
	#	unregister
	#
	#	remove a reference to a service.  the reference is removed
	#	by setting the key service.prototype.name in @services to
	#	null.
	#/
	unregister:  (s)       -> @services[s.prototype.name] = null

	#/
	#	service
	#
	#	return the object prototype corresponding to the key
	#	name, which maps to @services[name], or undefined.
	#/
	service:     (name)    -> @services[name]

	#/
	#	match
	#
	#	return the set of all object prototypes in @services which
	#	match the provided >type.  the match is performed by creating
	#	a RegExp object from the service.prototype.match string and
	#	performing a RegExp.test() operation.
	#
	#	object prototypes are also checked for a object.prototype.name
	#	attribute before performing the more expensive test to 
	#	eliminate non-service object members from the set.
	#/
	match:       (type)    -> @services[key] for key of @services when @services[key].prototype.name and RegExp(@services[key].prototype.match).test type

	#/
	#	reimplement
	#
	#	leverage Object(>o).implement to add the name, match and serve
	#	properties from the set of services that @match the provided
	#	>type. the set of matching services is traversed and implement'ed
	#	in order.
	#
	#	if all matching services have name, match and serve properties,
	#	in effect this will leave the >o object with the properties of
	#	the _last_ matching service.
	#/
	reimplement: (o, type) -> o.implement service, ['name', 'match', 'serve'] for service in @match type

module.exports = new ServiceRegistry()
