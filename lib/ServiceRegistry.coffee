#//
#	ServiceRegistry
#
#	object that handles registrations for new service types as well
#	as matching file types to the correct services.  self-implementing
#	services can use the reimplement method to assume the correct
#	service profile.
#//
class ServiceRegistry

	constructor: (@services = {}) -> 

	register:    (s)       -> @services[s.prototype.name] = s
	unregister:  (s)       -> @services[s.prototype.name] = null
	service:     (name)    -> @services[name]
	match:       (type)    -> @services[key] for key of @services when @services[key].prototype.name and RegExp(@services[key].prototype.match).test type
	reimplement: (o, type) -> o.implement service, ['name', 'match', 'serve'] for service in @match type

module.exports = new ServiceRegistry()
