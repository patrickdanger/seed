###
	//
	// 	env
	//
	//	environment definitions, functions and/or objects that should
	//	excecuted for side effect or to augment base JavaScript types.
	//
###

###

	Object.prototype.implements
	
	enabling a shallow form of multiple inheritance by augmenting
	the base Object prototype to include a method that will copy
	the properties of another object onto itself.  because this
	implementation will not copy a property which already exists
	in the base object, thereby avoiding name collisions.

	this is not true inheritance and objects that have "implemented"
	another object are incompatible with an instanceof test.


	@usage

	you can use the implements function as part of a new class
	being created:

		class NewObject extends Base
			@.implements Other, Another


	===============================================================
	@parm    objects...    Comprehension    
	---------------------------------------------------------------
	comprehension over the series of arguments passed as a list of 
	objects to implement in the base object. note that because 
	keys are overwritten as prototype properties are assigned, 
	precedence in the objects passed in is right-to-left.


###
Object.prototype.implements = (objects...) ->
	for object in objects
		for key of object.prototype
			@.prototype[key] = object.prototype[key] unless @.prototype[key]


###

	Object.prototype.implement
	
	enabling a more direct form of sideways inheritance by augmenting
	the base Object prototype to include a method that will copy
	the properties of an object itself.  this method differs from
	Object.prototype.implements in that it copies properties from the
	object prototypes onto instances of the object itself, rather 
	than a serial prototype property copy.
	
	@usage
	
	myObject   = new MyObject()
	yourObject = new YourObject()
	myObject.implement YourObject, [keys...]

	===============================================================
	@parm    objects...    Comprehension
	---------------------------------------------------------------
	comprehension over the series of arguments passed as a list of
	objects to implement in the base object.  note that because
	keys are overwritten as prototype properties are assigned,
	precedence in the objects pass in is right-to-left.
	
	===============================================================
	@parm    propMask      Array
	---------------------------------------------------------------
	array of properties to copy from the objects to implement.

###
Object.prototype.implement  = (objects..., propMask = []) ->
	for object in objects
		for key of object.prototype
			@[key] = object.prototype[key] if key in propMask