#### for module multiobjectiveGraphs ####
export genericWeightCategory, weightCategory, objTypes # abstract type and list of concrete
# 6 predefined types
export weightMinSum, weightMinProduct, weightMinMax, weightMaxSum, weightMaxProduct, weightMaxMin
# Programming Interface
export typeCode, defaultValue, mimic, compare, combine # , descr


##############################################################
#################### generic type for one objective value ####
##############################################################
abstract type genericWeightCategory end
abstract type weightCategory{Tobjval} <: genericWeightCategory end


############################################################
# each concrete weightCategory must implement
# 	... typeCode ... wich returns a small positive integer
# 		specific to this weightCategory and so is unique
# 			see function objTypes for existing values
# ... descr ... wich return the description of the objective type and value
# 	... defaultValue ... wich returns the base value for combining.  ###### really needed  ?? -> change initializations !!! , a arbitary base value may suffice
# 		e.g. 0 for sum, 1 for product
# 	... mimic ... wich yields a new element similar to its first parameter with or without value (2 functions)
# 	... compare(a,b) ... whose result is a couple of booleans (a is better than b or equals b, b is better than a or equals a)
#      compare a total order (especially  : forall (a,b) if a<=b & b<=a then a=b)
# 	... combine ... to create a new weight from two such weights
# 		that can be a sum, a product, a min, a max or anything
# 		that is associative ( combine(x,combine(y,z)) == combine(combine(x,y),z) )
#      and monotonous ( i.e. compare(x, combine(x,y)) must always yield (true, _) ) ### this constraint can be relaxed with appropriate detection in algorithms
#      in order to ensure there is no "negative weight" circuit in the graph
# don't forget to add each new type to the array (by redefining the function objTypes ???). ### must be tested
############################################################

#############################################################
################# objective types coding ##########################
function objTypes( a::weightCategory{Tobjval} )  where  Tobjval
  return [
   				weightMinSum{Tobjval}(),   			# --> 1
  				weightMinProduct{Tobjval}(),   	# --> 2
  				weightMinMax{Tobjval}(),   			# --> 3
  				weightMaxSum{Tobjval}(),   		# --> 4
  				weightMaxProduct{Tobjval}(),   	# --> 5
  				weightMaxMin{Tobjval}()   			# --> 6
  				]
end




##############################################################
##########        weights that sum up   ( min = better  )  ###
##############################################################
struct weightMinSum{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMinSum{Tobjval}() where Tobjval
	   new(0)                                       ## default weight                    					 ### 0 must be convertible to Tobjval
	   				### setting it to 1 can prevent from zero weighted closed path !!!!
	 end
	 function weightMinSum{Tobjval}(nb) where Tobjval
	   new( convert(Tobjval,nb) )																				### nb must be convertible to Tobjval
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMinSum{Tobjval} ) where  Tobjval
   		return UInt8(1)
   end
############## objective type name and value (for trace)
   function descr(a::weightMinSum{Tobjval} ) where  Tobjval
   		return "min∑("*string(a.value)*")"
   end
   ############## initialisation value
	function defaultValue(a::weightMinSum{Tobjval} ) where  Tobjval
		w::weightMinSum{Tobjval} = weightMinSum{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMinSum{Tobjval}, value ) where  Tobjval
		return weightMinSum{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMinSum{Tobjval},b::weightMinSum{Tobjval}) where  Tobjval
	 	return ( a.value <= b.value, b.value <= a.value )  ####### Tobjval must implement <= #######
	 end
############## combination
	 function combine(a::weightMinSum{Tobjval},b::weightMinSum{Tobjval}) where  Tobjval
	 	return weightMinSum{Tobjval}(a.value + b.value) ####### Tobjval must implement + #######
	 end



##############################################################
###########        weights that multiply ( min = better  )    ################
##############################################################
struct weightMinProduct{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMinProduct{Tobjval}() where Tobjval
	   new(1)                                       ## defaults to one, all values assumed to be >= 1
	 end
	 function weightMinProduct{Tobjval}(nb::Number) where Tobjval
	   new( convert(Tobjval,nb) )
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMinProduct{Tobjval} ) where  Tobjval
   		return UInt8(2)
   end
############## objective type name and value (for trace)
   function descr(a::weightMinProduct{Tobjval} ) where  Tobjval
   		return "min∏("*string(a.value)*")"
   end
############## initialisation value
	function defaultValue(a::weightMinProduct{Tobjval} ) where  Tobjval
		w::weightMinProduct{Tobjval} = weightMinProduct{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMinProduct{Tobjval}, value ) where  Tobjval
		return weightMinProduct{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMinProduct{Tobjval},b::weightMinProduct{Tobjval}) where  Tobjval
	 	return ( a.value <= b.value, b.value <= a.value )
	 end
 ############## combination
	 function combine(a::weightMinProduct{Tobjval},b::weightMinProduct{Tobjval}) where  Tobjval
	 	return weightMinProduct{Tobjval}(a.value * b.value)
	 end


##############################################################
##########           bottleneck objectives  ( min = better  )       #############
##############################################################
struct weightMinMax{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMinMax{Tobjval}() where Tobjval
	   new(0)                                       ## begin with 0 (all values > 0)
	 end
	 function weightMinMax{Tobjval}(nb) where Tobjval
	   new( convert(Tobjval,nb) )
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMinMax{Tobjval} ) where  Tobjval
   		return UInt8(3)
   end
############## objective type name and value (for trace)
   function descr(a::weightMinMax{Tobjval} ) where  Tobjval
   		return "minMAX("*string(a.value)*")"
   end
############## initialisation value
	function defaultValue(a::weightMinMax{Tobjval} ) where  Tobjval
		w::weightMinMax{Tobjval} = weightMinMax{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMinMax{Tobjval}, value ) where  Tobjval
	 	return weightMinMax{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMinMax{Tobjval},b::weightMinMax{Tobjval}) where  Tobjval
	 	return  ( a.value <= b.value, b.value <= a.value )
	 end
############## combination
	 function combine(a::weightMinMax{Tobjval},b::weightMinMax{Tobjval}) where  Tobjval
	 	return weightMinMax{Tobjval}(max(a.value, b.value))
	 end

##############################################################
##########       weights that sum up   ( max = better  )  #################
##############################################################
struct weightMaxSum{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMaxSum{Tobjval}() where Tobjval
	   new(0)                                       ## default weight is zero
	 end
	 function weightMaxSum{Tobjval}(nb) where Tobjval
	   new( convert(Tobjval,nb) )
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMaxSum{Tobjval} ) where  Tobjval
   		return UInt8(4)
   end
############## objective type name and value (for trace)
   function descr(a::weightMaxSum{Tobjval} ) where  Tobjval
   		return "max∑("*string(a.value)*")"
   end
############## initialisation value
	function defaultValue(a::weightMaxSum{Tobjval} ) where  Tobjval
		w::weightMaxSum{Tobjval} = weightMaxSum{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMaxSum{Tobjval}, value ) where  Tobjval
		return weightMaxSum{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMaxSum{Tobjval},b::weightMaxSum{Tobjval}) where  Tobjval
	 	return ( b.value <= a.value, a.value <= b.value )
	 end
############## combination
	 function combine(a::weightMaxSum{Tobjval},b::weightMaxSum{Tobjval}) where  Tobjval
	 	return weightMaxSum{Tobjval}(a.value + b.value)
	 end



##############################################################
###########       weights that multiply ( max = better  )    ################
##############################################################
struct weightMaxProduct{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMaxProduct{Tobjval}() where Tobjval
	   new(1)                                       ## initialisation = 1 ( all values <= 1 -> probabilities)
	 end
	 function weightMaxProduct{Tobjval}(nb) where Tobjval
	   new( convert(Tobjval,nb) )
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMaxProduct{Tobjval} ) where  Tobjval
   		return UInt8(5)
   end
############## objective type name and value (for trace)
   function descr(a::weightMaxProduct{Tobjval} ) where  Tobjval
   		return "max∏("*string(a.value)*")"
   end
############## initialisation value
	function defaultValue(a::weightMaxProduct{Tobjval} ) where  Tobjval
		w::weightMaxProduct{Tobjval} = weightMaxProduct{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMaxProduct{Tobjval}, value ) where  Tobjval
		return weightMaxProduct{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMaxProduct{Tobjval},b::weightMaxProduct{Tobjval}) where  Tobjval
	 	return ( b.value <= a.value, a.value <= b.value )
	 end
 ############## combination
	 function combine(a::weightMaxProduct{Tobjval},b::weightMaxProduct{Tobjval}) where  Tobjval
	 	return weightMaxProduct{Tobjval}(a.value * b.value)
	 end


##############################################################
##########           bottleneck objectives  ( max = better )       #############
##############################################################
struct weightMaxMin{Tobjval}  <: weightCategory{Tobjval}
				# immutable  -> perhaps make it mutable to gain execution  time and memory
   value::Tobjval
   ############## constructors
	function weightMaxMin{Tobjval}() where Tobjval
	   new(typemax(Tobjval))                                       ## initialisation = infinity
	 end
	 function weightMaxMin{Tobjval}(nb::Number) where Tobjval
	   new( convert(Tobjval,nb) )
	 end
end
############## objective type code (for graph text file format)
   function typeCode(a::weightMaxMin{Tobjval} ) where  Tobjval
   		return UInt8(6)
   end
 ############## objective type name and value (for trace)
   function descr(a::weightMaxMin{Tobjval} ) where  Tobjval
   		return "maxMIN("*string(a.value)*")"
   end
 ############## initialisation value
	function defaultValue(a::weightMaxMin{Tobjval} ) where  Tobjval
		w::weightMaxMin{Tobjval} = weightMaxMin{Tobjval}()
		return w.value
	end
############## same type with another value
	function mimic( a::weightMaxMin{Tobjval}, value::Number ) where  Tobjval
	 	return weightMaxMin{Tobjval}( value )
	end
############## comparaison
	 function compare(a::weightMaxMin{Tobjval},b::weightMaxMin{Tobjval}) where  Tobjval
	 	return  ( b.value <= a.value, a.value <= b.value )
	 end
############## combination
	 function combine(a::weightMaxMin{Tobjval},b::weightMaxMin{Tobjval}) where  Tobjval
	 	return weightMaxMin{Tobjval}(min(a.value, b.value))
	 end


############ unit tests ###################


### TO DO #############
