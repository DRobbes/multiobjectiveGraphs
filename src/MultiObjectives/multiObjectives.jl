
include("objectives.jl")

#### for module MOGraphs ####
export  multiobj, getObj, setObj!, summarize 
# export descr, defaultValue, mimic, combine # already in objectives.jl
export lexicoBetter, dominates, dominatesStrictly, objLength

##############################################################
#################### generic type for multi-objective values     #########
##############################################################

#### note : all objectives share the same type of value ##################
###  (upgrade needed to handle different types -> Tuple instead of Array ? ) #
abstract genericMultiobj end
mutable struct multiobj{Tobjval} <: genericMultiobj # Tobjval is union of all the Tobjvals of the objectives
	nb::Int8;  ######### number of objectives is (severely) limited to 127
	objectives::Vector{ genericWeightCategory}
	############## constructors
	function multiobj{Tobjval}() where Tobjval<:Number
			## create an monoobj with initialised array of  1 summabl objective
		ar= Vector{ weightMinSum{Tobjval} }(undef, 1)    # Vector{ weightMinSum{Tobjval} }( 1)  for Julia 0.63
		ar[1]=weightMinSum{Tobjval}()
		return new{Tobjval}(1,ar)
	end													##############
	function multiobj{Tobjval}( mo::multiobj{Tobjval} ) where  Tobjval <: Number
	 	return new{Tobjval}( mo.nb, mo.objectives ) ## clone
	end 												##############
	function multiobj{Tobjval}(n::Number) where Tobjval<:Number
			## create an multiobj with initialised array of summable objectives
		nnn::Int8=convert(Int8,n)
		ar= Vector{ weightMinSum{Tobjval} }(undef,  nnn )  # suppress undef first parameter for Julia 0.63
		for i::Int64 in 1:nnn 	ar[i]=weightMinSum{Tobjval}() 	end
		return new{Tobjval}(nnn,ar)
	end													##############
	function multiobj{Tobjval}(p::Number,q::Number,r::Number) where Tobjval<:Number
			## create an multiobj with initialised array of
			## p summable objectives, q multiplicative and r bottleneck
		ar=Vector{weightCategory{Tobjval}}(undef, p+q+r) # suppress undef first parameter for Julia 0.63
		for i::Int64 in 1:p 	ar[i]=weightMinSum{Tobjval}() 	end
		for i::Int64 in (p+1):(p+q) 	ar[i]=weightMinProduct{Tobjval}() 	end
		for i::Int64 in (p+q+1):(p+q+r) 	ar[i]=weightMinMax{Tobjval}() 	end
		return new(p+q+r,ar)
	end													##############
	function multiobj{Tobjval}(objTypes::Vector{weightCategory{Tobjval} } ) where Tobjval<:Number
			## create an multiobj with initialised types of weights (and matching default values)
		nn = length(objTypes)
		ar = Vector{weightCategory{Tobjval}}(undef,  nn ) # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(objTypes[i], defaultValue( objTypes[i] ) ) 	end
		return new{Tobjval}( nn, ar )
	end	
	function multiobj{Tobjval}(objTypes::Array{weightCategory{Tobjval} } ) where Tobjval<:Number
			## create an multiobj with initialised types of weights (and matching default values)
		nn = length(objTypes)
		ar = Vector{weightCategory{Tobjval}}(undef,  nn ) # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(objTypes[i], defaultValue( objTypes[i] ) ) 	end
		return new{Tobjval}( nn, ar )
	end													##############
	function multiobj{	Tobjval}(objTypes::Vector{ weightCategory{Tobjval} },
								objVals::Vector{Tvals} )  where { Tobjval<:Number , Tvals <: Number }
			## create an multiobj with array of objectives types and initialised array of values of weights
		nn = length(objVals)
		ar = Vector{weightCategory{Tobjval}}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(objTypes[i], objVals[i] ) 	end
		return new{Tobjval}( nn, ar )
	end
	function multiobj{	Tobjval}(a::multiobj{Tobjval},
								objVals::Vector{Tvals} )  where { Tobjval<:Number , Tvals <: Number }
			## create an multiobj with model of objectives types and initialised array of values of weights
		nn = length(objVals)
		ar = Vector{weightCategory{Tobjval}}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(a.objectives[i], objVals[i] ) 	end
		return new{Tobjval}( nn, ar )
	end													##############
	function multiobj{	Tobjval}(a::multiobj{Tobjval},
								objVals::Array{Tvals} )  where { Tobjval<:Number , Tvals <: Number }
			## create an multiobj with model of objectives types and initialised array of values of weights
		nn = length(objVals)
		ar = Vector{weightCategory{Tobjval}}(undef, nn )  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=mimic(a.objectives[i], objVals[i] ) 	end
		return new{Tobjval}( nn, ar )
	end													##############
	function multiobj{Tobjval}(a::multiobj{Tobjval} , b::multiobj{Tobjval} ) where Tobjval<:Number
			## create an multiobj with combinations of weights in a && b
		nn::Int8 = objLength(a)
		ar= Vector{ weightCategory{Tobjval} }(undef,  nn )  # a && b MUST be the same size  # suppress undef first parameter for Julia 0.63
		   # with the same types in the same indices
		for i::Int64 in 1:nn 	ar[i]=combine(a.objectives[i],b.objectives[i]) 	end
		return new{Tobjval}(nn,ar)
	end
end
######### accessor ##############
 function getObj( mo::multiobj{Tobjval}, numobj::Integer ) where Tobjval<:Number
   return mo.objectives[numobj]
 end
 function setObj!( mo::multiobj{Tobjval}, numobj::Integer, objvalue) where Tobjval<:Number
   old = mo.objectives[numobj] ; mo.objectives[numobj] = objvalue ; return old
 end
######### displaying a multi-objective ############
 function summarize( mo::multiobj{Tobjval} ; log=stdout) where Tobjval<:Number
 	print(log,"[ ")
 	 for obj in mo.objectives
 	 	print(log,obj.value," ")
 	 end
 	 print(log,"]");  #### be carefull using it : no line break here
 end
 ######### description of a multi-objective ############
 function descr( mo::multiobj{Tobjval} ; withName=true ) where Tobjval<:Number
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
	function defaultValue( mo::multiobj{Tobjval} ) where  Tobjval<:Number
		return multiobj{Tobjval}( mo.objectives )
	end
############## initialisation values of given types
	function defaultValue( objTypes::Vector{ weightCategory{Tobjval} } ) where  Tobjval<:Number
		return multiobj{Tobjval}( objTypes )
	end############## same types with default values ( same than preceding )
	function mimic( objTypes::Vector{ weightCategory{Tobjval} } ) where  Tobjval <: Number
	 	return multiobj{Tobjval}( objTypes )
	end
############## same types with other values
	function mimic( objTypes::Vector{ weightCategory{Tobjval} },
								objVals::Vector{Tvals} ) where   { Tobjval <: Number, Tvals <: Number }
	 	return multiobj{Tobjval}( objTypes, objVals )
	end
	function mimic( objTypes::Vector{ weightCategory{Tobjval} },
								objVals::Array{Tvals} ) where   { Tobjval <: Number, Tvals <: Number }
	 	return multiobj{Tobjval}( objTypes, objVals )
	end
############## same types with other values
	function mimic( objTypes::multiobj{Tobjval},
									objVals::Vector{Tvals} ) where   { Tobjval <: Number, Tvals <: Number }
		 return multiobj{Tobjval}( objTypes, objVals )
	end
############## clone
	function mimic( mo::multiobj{Tobjval} ) where  Tobjval <: Number
	 	return multiobj{Tobjval}( mo )
	end
############# combination ##########
function combine(a::multiobj{Tobjval}, b::multiobj{Tobjval} )::multiobj{Tobjval} where Tobjval<:Number
 return multiobj{Tobjval}(a , b )
end

############# lexicographic order ##########
function lexicoBetter(a::multiobj{Tobjval}, b::multiobj{Tobjval} )::Bool  where Tobjval<:Number
	num::Int8 = 1 ; maxNum::Int8 = objLength(a)
	while num < maxNum && compare(a.objectives[num], b.objectives[num])==(true,true) ## lazy evaluation not needed here
		num += 1
	end
	return compare(a.objectives[num], b.objectives[num])[1]
end
############# lexicographic order beginning with k-th  ##########
function lexicoBetter(a::multiobj{Tobjval}, b::multiobj{Tobjval}, k::Int8 )::Bool  where Tobjval<:Number
	cntr::Int8 = 1 ; maxNum::Int8 = objLength(a) ; num::Int8 =k
	while cntr < maxNum && compare(a.objectives[num], b.objectives[num])==(true,true) ## lazy evaluation not needed here
		cntr += 1 ; num = (num % maxNum) + 1 ; 
	end
	return compare(a.objectives[num], b.objectives[num])[1]
end
############# dominance ##########
function compare(a::multiobj{Tobjval}, b::multiobj{Tobjval} )::Tuple{Bool,Bool}  where Tobjval<:Number
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

function dominates(a::multiobj{Tobjval}, b::multiobj{Tobjval} )::Bool where Tobjval<:Number
  cp = compare(a,b)
  return cp[1]
end

function dominatesStrictly(a::multiobj{Tobjval}, b::multiobj{Tobjval} )::Bool where Tobjval<:Number
  cp = compare(a,b)
  return cp[1] && ! cp[2]
end

######### specific dominance (one objective only -> Dijsktra) ###########
function dominates(a::multiobj{Tobjval}, b::multiobj{Tobjval}, objnum::Int8 )::Bool where Tobjval<:Number
  return compare(a.objectives[objnum],  b.objectives[objnum])[1]
end


############## some well known functions redefined      ##########  !!!! not for Julia 1.0
#	function size(mo::multiobj{Tobjval})::Int8  where Tobjval<:Number return mo.nb end
function objLength(mo::multiobj{Tobjval})::Int8  where Tobjval<:Number return mo.nb end




############ unit tests ###################


function unittest(mo::multiobj{Tobjval} ) where Tobjval<:Number

	x = weightMinSum{Int16}()     		; println("x=weightMinSum{Int64}()=",x)
	y = weightMinSum{Int16}(5)     	; println("y=weightMinSum{Int64}(5)=",y)
	z = combine(x,y)    						; println("z=combine(x,y)=",z)
	t = combine(z,z)    						; println("t=combine(z,z) =",t)

  	mo = multiobj{Int32}(convert(Int8,3))	; println("mo = multiobj(3) ; objLength(mo)	=",objLength(mo) )
  	mpqr = multiobj{Float64}(2,1,3)			; println("mpqr = multiobj(2,1,3) ; objLength(mpqr)	=",objLength(mpqr) )
  	comb = combine(mpqr,mpqr)				; println("comb=combine(mpqr,mpqr) ; objLength(comb)	=",objLength(comb) )

  	cmpr = compare(mpqr,comb) 				; println("comb=compare(mpqr,comb)=",cmpr )

	lb = lexicoBetter(mpqr,comb)			; println("comb=leico(mpqr,comb)=",lb )
	lb = lexicoBetter(comb,mpqr)			; println("comb=leico(comb,mpqr)=",lb )
	lb = lexicoBetter(mpqr,mpqr)			; println("comb=leico(mpqr,mpqr)=",lb )

	lb = lexicoBetter(multiobj{Float64}(multiobj{Float64}(2,0,0),[105,13]),
						multiobj{Float64}(multiobj{Float64}(2,0,0),[30,19]) )
				 	println("comb=leico([105,13],[30,19])=",lb )
	lb = lexicoBetter(multiobj{Float64}(multiobj{Float64}(2,0,0),[30,19]),
						multiobj{Float64}(multiobj{Float64}(2,0,0),[105,13]) )
	 				println("comb=leico([30,19],[105,13])=",lb )


end