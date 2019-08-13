using JuMP, CPLEX
#leitura de dados e parâmetros iniciais
a = readdlm("instancia.txt") #lê arquivo e monta matriz a de dados
m = a[1] #número de itens (linha 1)
L = a[2] #comprimento do objeto (linha 2 coluna 1)
W = a[2,2] #largura do objeto (linha 2 coluna 2)
es = a[3] #espessura da serra (linha 3)
cf = a[4] #controle de folga, sem folga (0) ou com folga (1) (linha 4)
cr = a[5] #controle de rotação, fixa (0) ou rotação (1) (linha 5)
l = a[6:5+m,1] #comprimento do item 1..m (linha 6 até 5+m, coluna 1)
w = a[6:5+m,2] #largura do item 1..m (linha 6 até 5+m, coluna 2)
b = a[6:5+m,3] #demanda do item 1..m (linha 6 até 5+m, coluna 3)
#eps = 0.000001
A = eye(m,m)
p=zeros(m)
tic() #início de contagem de tempo

ProblemaMestre = Model(solver=CplexSolver())
@variable(ProblemaMestre, 0<=x[1:size(A,2)]<=Inf)
@objective(ProblemaMestre, Min, sum(x))
@constraint(ProblemaMestre, ConstraintRef[i=1:m], dot(x, vec(A[i,:])) == b[i])
solve(ProblemaMestre)
print(ProblemaMestre)
#sortperm(l) #retorna os indices do vetor l em ordem crescente de valor das entradas
#!indice_lo = sortperm(l) #monta um vetor de indices do vetor l ordenado conforme sortperm(l)
println("x1=$(getvalue(x[1])), x2=$(getvalue(x[2])), x3=$(getvalue(x[3]))")
tempo=toc()
ordem = sortperm(w)
#Coletar a variável dual e armazená-la.
for i=1:m
    p[ordem[i]]=getdual(ConstraintRef)[i]
end
function ordenando(SS)
    for i = 1:size(SS,1)
        for j = 1:size(SS,1)
            if SS[i][1] > SS[j][1] && i < j
                insert!(SS,i,SS[j])
                deleteat!(SS,j+1)
            end
        end
    end
end

function dominados(SS)
    i = 2
    while i <= size(SS,1)
        while (SS[i][1] > SS[i-1][1] && SS[i][2] <= SS[i-1][2]) || (SS[i][1] >= SS[i-1][1] && SS[i][2] < SS[i-1][2]) || (SS[i][1] == SS[i-1][1] && SS[i][2] > SS[i-1][2])
            if SS[i][1] > SS[i-1][1] && SS[i][2] <= SS[i-1][2]
                deleteat!(SS,i)
                if i > size(SS,1)
                    break
                end
            elseif SS[i][1] >= SS[i-1][1] && SS[i][2] < SS[i-1][2]
                deleteat!(SS,i)
                if i > size(SS,1)
                    break
                end
            else
                deleteat!(SS,i-1)
                i = i-1
                if i == 1
                    i = i+1
                end
            end
        end
        i=i+1
    end
end

################ Etapa1 - m problemas da mochila (construção das faixas) ###########
S0=[0.0,0.0,0.0]
#S = Array{Array{Int64,1},1}(0)
#SS = [S0]
#SS = Array{Array{Int64,1},1}(0)
SSS = [[S0]] #definir SSS como vetor de seqûencia de vetores SSS = [SS1,SS2,...,SSk] k=m
#SSS = Array{Array{Array{Float64,1},1},1}(m)
insert!(SSS,1,[S0])
deleteat!(SSS,2)


for k = 1:2 ### início da S^k
    println("k = $k primeiro item")
    SSSaux = Array{Array{Array{Float64,1},1},1}(0)
    for i = k
        push!(SSSaux, SSS[k])
        println("SSSaux = $SSSaux")
    end
    SS = Array{Array{Float64,1},1}(0)
    println("SS = $SS")
    for i = 1:size(SSSaux[1],1)
        push!(SS,SSSaux[1][i])
        println("SS = $SS")
    end
    S = Array{Array{Float64,1},1}(0)
    println("S = $S")
    for i = 1:size(SS,1)
        SS[i][3] = 0
        push!(S,SS[i])
        println("SSS= $SSS")
        println("S[$i] = $(S[i])")
        println("SS = $SS")
    end ### zera a terceira coordenada de todos os ternos da S^k após armazenala e S^(k+1)_0 = S^k
    println("SSS = $SSS")
    println("S = $S")
    println("$(min(b[ordem[k]],trunc(L/l[ordem[k]])))")
    for j = 1:min(b[ordem[k]],trunc(L/l[ordem[k]])) ### início segundo loop (obtendo as S^(k+1)_j)
        println("j = $j de 1 até limite do item")
        for i = 1:size(S,1) ### Soma de [jpk,jvk,j] em cada terno de S^(k+1)_(j-1)
            println("i = $i soma das parcelas")
            println("S[$i] = $(S[i]) e termo = $([l[ordem[k]],p[k],1])")
            S[i] = S[i] .+ [l[ordem[k]],p[k],1] #Não soma com [jpk,jvk,j], pois o S está sendo atualizado
            println("S[$i] = $(S[i]) e S = $S")
            if S[i][1] <= L #Coloca os termos viáveis na S^k
                println("SS = $SS")
                push!(SS,S[i])
                println("SS = $SS")
            end
        end
    end
    println("SS = $SS")
    ordenando(SS) #Ordena a S^k
    println("SS = $SS")
    dominados(SS) #Tira os ternos dominados da S^k
    println("SS = $SS")
    println("SSS = $SSS")
    #for i = 1:size(SS,1)
    #    push!(SSS[k+1][i],SS[i])
    #end
    push!(SSS,SS) #Armazena a S^k no vetor SSS
    println("SSS = $SSS")
end

#for k = 1:m
    for i = 1:size(SS,1)
        SS[i][3] = 0
    end
    S = SS
    j = 1
    while j <= min(b[ordem[k]],trunc(L/l[ordem[k]]))
        i = 1
        while i <= size(S,1)
            S[i] = S[i] .+ [l[ordem[k]],p[ordem[k]],1]
            if S[i][1] <= L
                push!(SS,S[i])
            end
            i = i + 1
        end
        j = j + 1
    end
    ordenando(SS)
    dominados(SS)
    push!(SSS,SS)
#end

#function mochila1(m,ordem,L,l,p,b,S,SS,SSS)
    SS = [S0]
    for k = 1:m
        for r = 1:size(SS,1)
            SS[r][3] = 0
        end
        S = SS
        j = 1
        while j <= min(b[ordem[k]],trunc(L/l[ordem[k]]))
            i = 1
            while i <= size(S,1)
                S[i] = S[i] .+ [l[ordem[k]],p[ordem[k]],1]
                if S[i][1] <= L
                    insert!(SS,i,S[i])
                else
                    continue
                end
                i = i+1
            end
            j = j+1
        end
        ordenando(SS)
        dominados(SS)
        insert!(SSS,k,SS)
    end
#end

############### Recuperação da solução das m mochilas e armazenamento #################
gama = zeros(m,m) ####### Matriz onde será armazenado as soluções
gama[1,1] = SSS[2][size(SSS[2],1)][3]
for i =2:m
    j = i-1
    C = SSS[i+1][size(SSS[i+1],1)][1]
    gama[i,i] = SSS[i+1][size(SSS[i+1],1)][3]
    while j >= 1
        gama[i,j] = 0
        C = C - gama[i,j+1]*l[ordem[j+1]]
        for r = 1:size(SSS[j+1],1)
            if SSS[j+1][r][1] == C && SSS[j+1][r][3] > gama[i,j]
                gama[i,j] = SSS[j+1][r][3]
            end
        end
        j = j-1
    end
end
########################### Fim da recuperação ########################################

p2 = zeros(m)
p2 = gama*p ###### vetor dos coeficientes da mochila m+1

################### Início da mochila m+1 obtendo m padrões de corte #######################
F0=[0.0,0.0,0.0]
#F = Array{Array{Int64,1},1}(0)
#FF = [S0]
#FF = Array{Array{Int64,1},1}(0)
FFF = [[S0]] #definir SSS como vetor de seqûencia de vetores SSS = [SS1,SS2,...,SSk] k=m
ordem = sortperm(w)

for k = 1:m ### início da S^k
    println("k = $k primeiro item")
    SSSaux = Array{Array{Array{Float64,1},1},1}(0)
    push!(SSSaux, SSS[k])
    println("SSSaux = $SSSaux")
    SS = Array{Array{Float64,1},1}(0)
    println("SS = $SS")
    for i = 1:size(SSSaux[1],1)
        push!(SS,SSSaux[1][i])
    end
    println("SS = $SS")
    S = Array{Array{Float64,1},1}(0)
    println("S = $S")
    for i = 1:size(SS,1)
        SS[i][3] = 0
        push!(S,SS[i])
        println("S[$i] = $(S[i])")
        println("SS = $SS")
    end ### zera a terceira coordenada de todos os ternos da S^k após armazenala e S^(k+1)_0 = S^k
    println("SSS = $SSS")
    println("S = $S")
    println("$(min(b[ordem[k]],trunc(L/l[ordem[k]])))")
    for j = 1:min(b[ordem[k]],trunc(L/l[ordem[k]])) ### início segundo loop (obtendo as S^(k+1)_j)
        println("j = $j de 1 até limite do item")
        for i = 1:size(S,1) ### Soma de [jpk,jvk,j] em cada terno de S^(k+1)_(j-1)
            println("i = $i soma das parcelas")
            println("S[$i] = $(S[i]) e termo = $([l[ordem[k]],p[ordem[k]],1])")
            S[i] = S[i] .+ [l[ordem[k]],p[k],1] #Não soma com [jpk,jvk,j], pois o S está sendo atualizado
            println("S[$i] = $(S[i]) e S = $S")
            if S[i][1] <= L #Coloca os termos viáveis na S^k
                println("SS = $SS")
                push!(SS,S[i])
                println("SS = $SS")
            end
        end
    end
    println("SS = $SS")
    ordenando(SS) #Ordena a S^k
    println("SS = $SS")
    dominados(SS) #Tira os ternos dominados da S^k
    println("SS = $SS")
    println("SSS = $SSS")
    #for i = 1:size(SS,1)
        #push!(SSS[k],SS[i])
    #end
    push!(SSS,SS) #Armazena a S^k no vetor SSS
    println("SSS = $SSS")
end
