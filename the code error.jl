##############################################################################################################
Nícolas Samuel Assis
Universidade Estadual Paulista 
Copyright 1989, 2004, 2005, 2009, 2016, 2019 Socorro Rangel/UNESP
This program is part of CorteBiFur
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################################################

using JuMP

######################### This is the method, not complete, but here is the problem #######################

for i =1:m
    SSS = [[0.0,0.0,0.0]]
end

for k = 1:m #################################### Here i initialize the method
    SSSaux = Array{Array{Array{Float64,1},1},1}(0)
    
    if k>1
        push!(SSSaux, SSS[k-1]) ################ Here i get the k-1 solution of SSS and put in other vector
    else
        push!(SSSaux, SSS[k])
    end
    
    SS = Array{Array{Float64,1},1}(0)
    for i = 1:size(SSSaux[1],1)
        push!(SS,SSSaux[1][i])
    end
    S = Array{Array{Float64,1},1}(0)
    for i = 1:size(SS,1)
        SS[i][3] = 0 ################### Here occurs the error, i need to change SS this way, but don'ting changeing SSS, but this happens.
        push!(S,SS[i])
    end 
    for j = 1:min(b[ordem[k]],trunc(L/l[ordem[k]])) ### Here i manipulate the SS and getting the k solution
        for i = 1:size(S,1) 
            S[i] = S[i] .+ [l[ordem[k]],p[k],1] 
            if S[i][1] <= L 
                push!(SS,S[i])
            end
        end
    end
    ordenando(SS) 
    dominados(SS) 
    for i = 2:size(SS,1) ################## here i put the k solution at the vector SSS at k coordinate
        push!(SSS[k],SS[i])
    end
end

