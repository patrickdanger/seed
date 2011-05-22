


Description:

Seed is a web server framework that dynamically decomposes request
paths into an object hierarchy of responders.  Seed owes all of the 
credit for this idea to lightnode, an excellent and far more mature
expression of the idea.

When a request is received by a seed, it is successively tokenized
(decomposed) and emitted down a determinate path through through it's
children.  If no child is found for a token, one is created by 
mapping the token to a service using the a service registry which
any object implementing the Service object can register to.

For example, the request path:

	webroot/development/index.html
	
would end up creating an object tree that looked like:

	Seed.children[webroot].children[development].children[index.html]
	
where children[index.html] is a FileServer object which will load the
requested file and write it into the response buffer.


Usage:

You can create new seeds and bind them to custom routes, for example:

	development = new Seed "webroot/development"
	production = new Seed "webroot/production"
	api = new Seed "api"


Services:

Seed comes packaged with Services (defined in lib/Services.coffee)
which can handle a majority of requests:

	"*"			FileService
	".jade"		JadeService
	".styl"		StylusService
	".coffee" 	CoffeeScriptService

You can also add custom objects into the service map. You do this by 
creating service objects which implement the Service object:

	class APIService extends Seed
		@.implements Service
		constructor: -> @registerService @, "api"

If a request path terminates at an "api" token, this service will
be created and bound at that leaf.


Caching:
