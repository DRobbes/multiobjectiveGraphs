##################################################################################
#
#  					fichier d'utilisation en cours de développement, doit disparaître de la version finale
#
##################################################################################
import Pkg
# Pkg.add("Revise") ; using Revise

monpk = Pkg.PackageSpec(name="multiobjectiveGraphs", path="/Users/robbes-d/Nextcloud/Robberies/Recherche/gitHubMOGraphs/multiobjectiveGraphs", mode=Pkg.PKGMODE_MANIFEST)
Pkg.add(monpk)
 import multiobjectiveGraphs
# multiobjectiveGraphs.greet()   ### premier essai ####
using multiobjectiveGraphs
greet()									   ### second essai ####
println("+++++++++++++++++++",Squares(5))


#################### execution des tests #######################
include("runtests.jl")

################## exemples simples d'utilisation ######################
include("examples.jl")