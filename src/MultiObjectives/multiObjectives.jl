
 include("objectives.jl")

#### for module MOGraphs ####
export  multiobj # , getObj, setObj!, summarize 
#export descr, defaultValue, mimic, combine # already in objectives.jl
# export lexicoBetter, dominates, dominatesStrictly, objLength

import Base.size, Base.length # Julia 1+ , allow redefinition of theses functions

##############################################################
#################### generic type for multi-objective values     #########
##############################################################

#### note : all objectives do not need to share the same type of values ##################

mutable struct multiobj # <: genericMultiobj # Tobjval is union of all the Tobjvals of the objectives
	nb::Int8;  ######### number of objectives is (severely) limited to 127
	objectives::Vector{ genericWeightCategory}
	############## constructors
	function multiobj() 
			## create an monoobj with initialised array of  1 summable objective
		ar= Vector{ genericWeightCategory }(undef, 1)    # Vector{ weightMinSum{Tobjval} }( 1)  for Julia 0.63
		ar[1]=weightMinSum{Float64}()
		return new(1,ar)
	end													##############

	function multiobj( mo::multiobj ) 
	 	return new( mo.nb, mo.objectives ) ## clone with same types and same values
	end 												##############
	function multiobj(n::Number; typeofobjectives=weightMinSum{Float64}) 
			## create an multiobj with initialised array of summable objectives
		nnn::Int8=convert(Int8,n)
		ar= Vector{ genericWeightCategory }(undef,  nnn )  # suppress undef first parameter for Julia 0.63
		for i::Int64 in 1:nnn 	ar[i]=typeofobjectives() 	end
		return new(nnn,ar)
	end													##############
	function multiobj(p::Number,q::Number,r::Number ; typeofvalues=Float64) 
			## create an multiobj with initialised array of
			## p summable objectives, q multiplicative and r bottleneck
		ar=Vector{genericWeightCategory}(undef, p+q+r) # suppress undef first parameter for Julia 0.63
		for i::Int64 in 1:p 	ar[i]=weightMinSum{typeofvalues}() 	end
		for i::Int64 in (p+1):(p+q) 	ar[i]=weightMinProduct{typeofvalues}() 	end
		for i::Int64 in (p+q+1):(p+q+r) 	ar[i]=weightMinMax{typeofvalues}() 	end
		return new(p+q+r,ar)
	end													##############
	function multiobj(mobjTypes::Vector{genericWeightCategory } ) 
			## create an multiobj with initialised types of weights (and matching default values)
		nn = length(mobjTypes)
		ar = Vector{genericWeightCategory}(undef,  nn ) # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(mobjTypes[i], defaultValue( mobjTypes[i] ) ) 	end
		return new{Tobjval}( nn, ar )
	end	
	function multiobj(mobjTypes::Array{genericWeightCategory } )
			## create an multiobj with initialised types of weights (and matching default values)
		nn = length(mobjTypes)
		ar = Vector{genericWeightCategory}(undef,  nn ) # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(mobjTypes[i], defaultValue( mobjTypes[i] ) ) 	end
		return new{Tobjval}( nn, ar )
	end													##############
	function multiobj(mobjTypes::Vector{ genericWeightCategory },
								mobjVals::Vector{Tvals} )  where  Tvals <: Number 
			## create an multiobj with array of objectives types and initialised array of values of weights
		nn = length(mobjVals)
		ar = Vector{genericWeightCategory}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(mobjTypes[i], mobjVals[i] ) 	end
		return new{Tobjval}( nn, ar )
	end
	function multiobj(a::multiobj,
								mobjVals::Vector{Tvals} )  where Tvals <: Number 
			## create an multiobj with model of objectives types and initialised array of values of weights
		nn = length(mobjVals)
		ar = Vector{genericWeightCategory}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(a.objectives[i], mobjVals[i] ) 	end
		return new( nn, ar )
	end													##############
	function multiobj(a::multiobj,
								mobjVals::Array{Tvals} )  where Tvals <: Number 
			## create an multiobj with model of objectives types and initialised array of values of weights
		nn = length(mobjVals)
		ar = Vector{genericWeightCategory}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(a.objectives[i], mobjVals[i] ) 	end
		return new( nn, ar )
	end													##############
	function multiobj(a::multiobj , b::multiobj )
			## create an multiobj with combinations of weights in a && b
		nn::Int8 = objLength(a)
		ar= Vector{ genericWeightCategory }(undef,  nn )  # a && b MUST be the same size  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=combine(a.objectives[i],b.objectives[i]) 	end
		return new(nn,ar)
	end
end


######### accessor ##############
 function getObj( mo::multiobj, numobj::Integer ) 
   return mo.objectives[numobj]
 end
 function setObj!( mo::multiobj, numobj::Integer, objvalue)
   old = mo.objectives[numobj] ; mo.objectives[numobj] = objvalue ; return old
 end
######### displaying a multi-objective ############
 function summarize( mo::multiobj ; log=stdout) 
 	print(log,"[ ")
 	 for obj in mo.objectives
 	 	print(log,obj.value," ")
 	 end
 	 print(log,"]");  #### be carefull using it : no line break here
 end
 
 
 ######### description of a multi-objective ############
 function descr( mo::multiobj ; withName=true ) 
  txt::String="[ "
  if withName
 	 txt*=descr(mo.objectives[1])
 	 for i in 2:length(mo.objectives) txt*=","*descr(mo.objectives[i])  end
 	 txt*="]"
  else
 	 txt*=string(mo.objectives[1].value)
 	 for i in 2:length(mo.objectives)  txt*=","*string(mo.objectives[i].value)  end
 	 txt*="]"
  end
  return txt
 end
 
 
############## initialisation values of given types
	function defaultValue( mo::multiobj )
		return multiobj( mo.objectives )
	end
############## initialisation values of given types
	function defaultValue( objTypes::Vector{ genericWeightCategory } )
		return multiobj( objTypes )
	end
############## same types with default values ( same than preceding )
	function mimic( objTypes::Vector{ genericWeightCategory} ) 
	 	return multiobj( objTypes )
	end
############## same types with other values
	function mimic( objTypes::Vector{ genericWeightCategory },
								objVals::Vector{Tvals} ) where   Tvals <: Number 
	 	return multiobj( objTypes, objVals )
	end
	
	function mimic( objTypes::Vector{ genericWeightCategory },
								objVals::Array{Tvals} ) where  Tvals <: Number 
	 	return multiobj( objTypes, objVals )
	end
############## same types with other values
	function mimic( objTypes::multiobj,
									objVals::Vector{Tvals} ) where  Tvals <: Number 
		 return multiobj( objTypes, objVals )
	end
############## clone
	function mimic( mo::multiobj ) 
	 	return multiobj( mo )
	end
	
############# combination ##########
function combine(a::multiobj, b::multiobj )::multiobj 
 return multiobj(a , b )
end

############# lexicographic order ##########
function lexicoBetter(a::multiobj, b::multiobj )::Bool  
	num::Int8 = 1 ; maxNum::Int8 = objLength(a)
	while num < maxNum && compare(a.objectives[num], b.objectives[num])==(true,true) ## sequential evaluation not needed here
		num += 1
	end
	return compare(a.objectives[num], b.objectives[num])[1]
end
############# lexicographic order cycling, beginning with k-th  ##########
function lexicoBetter(a::multiobj, b::multiobj, k::Int8 )::Bool  
	cntr::Int8 = 1 ; maxNum::Int8 = objLength(a) ; num::Int8 =k
	while cntr < maxNum && compare(a.objectives[num], b.objectives[num])==(true,true) ## sequential evaluation not needed here
		cntr += 1 ; num = (num % maxNum) + 1 ; 
	end
	return compare(a.objectives[num], b.objectives[num])[1]
end
############# dominance ##########
function compare(a::multiobj, b::multiobj )::Tuple{Bool,Bool} 
              ## returns (a<=b, b<=a) ; hence returns  (true,true) if  a == b
 			i::Int8=1; aisbetter::Bool=true  # better and worse must be seen here as large ( _ or equal)
 			while i <= a.nb &&  aisbetter                                # a.nb is assumed == b.nb
 					aisbetter = aisbetter && compare(a.objectives[i],  b.objectives[i])[1]
 				    i += 1
 			end
 			i=1; aisworse::Bool=true
 			while i <= a.nb &&  aisworse                               # a.nb is assumed == b.nb
 					aisworse = aisworse && compare(a.objectives[i], b.objectives[i])[2]
 				    i += 1
 			end
 			return  aisbetter, aisworse
end

function dominates(a::multiobj, b::multiobj )::Bool 
  cp = compare(a,b)
  return cp[1]
end

function dominatesStrictly(a::multiobj, b::multiobj )::Bool 
  cp = compare(a,b)
  return cp[1] && ! cp[2]
end

######### specific dominance (one objective only -> Dijsktra) ###########
function dominates(a::multiobj, b::multiobj, objnum::Int8 )::Bool 
  return compare(a.objectives[objnum],  b.objectives[objnum])[1]
end


############## some well known functions redefined     ##########
function size(mo::multiobj)::Int8  where Tobjval<:Number  return mo.nb end
function length(mo::multiobj)::Int8  where Tobjval<:Number  return mo.nb end
function objLength(mo::multiobj)::Int8  where Tobjval<:Number return mo.nb end




