################## random samples of code using package multiobjectiveGraphs #######################

multObj = multiobj(2,1,2, typeofvalues=Float32)

println(multObj)
println(descr(multObj))

#=
for i in Squares(7)
           println(i)
       end
=#
      
#=       
for obj in multObj
	println(descr(obj))
end
=#

# println(descr(multObj[2]))
