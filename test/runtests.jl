println("=========== testing multiobjectiveGraphs package =============")


import multiobjectiveGraphs
using multiobjectiveGraphs

import Pkg ; Pkg.add("Test")

import Test
using Test

#=

@testset "priority lists" begin
	PL =  priorityList{UInt8}()
	add!(PL,UInt8(5)) ; pretty(PL)
	add!(PL,UInt8(12)) ; pretty(PL)
	add!(PL,UInt8(7)) ; pretty(PL)
	add!(PL,UInt8(2)) ; pretty(PL)
	add!(PL,UInt8(20)) ; pretty(PL)
	add!(PL,UInt8(9)) ; pretty(PL)
	@test size(PL) == 6
	@test first(PL) == 2
	@test removefirst!(PL) == 2
	@test removefirst!(PL) == 5
	@test size(PL) == 4
	for x::UInt8 in [(3*i) % 100 for i in 20:80] add!(PL,x) end
	@test removefirst!(PL) == 1
	@test first(PL) == 2
	pretty(PL) ; println("taille : ",length(PL))
end

=#

@testset "objectives" begin
	anObj = weightMinSum{Int32}()	
	@test typeof(objTypes(anObj)[1]) == typeof(		weightMinSum{Int32}() 		) 	# --> 1
  	@test typeof(objTypes(anObj)[2]) == typeof(		weightMinProduct{Int32}() 	)  	# --> 2
  	@test typeof(objTypes(anObj)[3]) == typeof(		weightMinMax{Int32}() 		)  	# --> 3
  	@test typeof(objTypes(anObj)[4]) == typeof(		weightMaxSum{Int32}() 		)	# --> 4
  	@test typeof(objTypes(anObj)[5]) == typeof(		weightMaxProduct{Int32}() 	)	# --> 5
  	@test typeof(objTypes(anObj)[6]) == typeof(		weightMaxMin{Int32}() 		) 	# --> 6
end

@testset "multiObjectives" begin
    multObj = multiobj(2,1,2, typeofvalues=Float32)
    
    @test string(typeof(multObj)) == "multiobj"
    @test string(multObj) ==  "multiobj(5, genericWeightCategory[weightMinSum{Float32}(0.0), weightMinSum{Float32}(0.0), weightMinProduct{Float32}(1.0), weightMinMax{Float32}(0.0), weightMinMax{Float32}(0.0)])"
    @test descr(multiobj())=="[ min∑(0.0)]"
    @test descr(multiobj(multiobj()))=="[ min∑(0.0)]"
    @test descr(multiobj(5))=="[ min∑(0.0),min∑(0.0),min∑(0.0),min∑(0.0),min∑(0.0)]"
    @test descr(multiobj(3,typeofobjectives=typeofweightMinSum{UInt8}(5)))=="[ min∑(0),min∑(0),min∑(0)]"
end

#=

@testset "MOgraph" begin
    GG = MOgraph{ Int64, Float64 }(5, 3) # graph with 5 vertices, 3 objectives
    ar = edge{  Int64, Float64 }( 2, multiobj{Float64}(3), 5 ) # edge from 2 to 5 with default tri-objective
	addEdge!( GG, ar )
	moType = [weightMinSum{Float64}() , weightMinProduct{Float64}(), weightMinMax{Float64}() ] # default specific tri-objective
	for i in 2:nv(GG)				
			mo = mimic( moType, [ i*i, i, 99-i ] ) # same of multiobjective but with these 3 values 
			ar=mimic(ar,i-1, mo, i)						# same type of edge but from i-1 to i with this objective 
			addEdge!( GG, ar )
			mo = mimic( moType, [ 99-i, i*i, i ] )
			ar = mimic(ar, i, mo, nv(GG)+1-i )
			addEdge!( GG, ar )
	end
	
	summarize(GG)
	println(typeof(GG))
	t=plot(GG)
	GG=WheelGraph(10)
	println(typeof(GG))
    t=plot(GG)
    save(SVG("TikzDessin.svg"), t)
	
    @test nv(GG) == 5
    @test ne(GG) == 9
end

=#