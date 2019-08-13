# Hello-world
This project is about my master's degree. My research area is related to Operational Research, specifically the cutting stock problem for the furniture industry. I am developing a method to solve the pricing subproblem of the two-dimensional cutting stock problem. This subproblem is a two-dimensional guillotine cutting problem and the method is based on the one-dimensional knapsack problem.
########## Goal to be here ###################
My goal being here is to correct an error in my method code. Basically, I have a m-dimensional SSS vector, which will store the solution of the iterations of my method. Iteration k = 1, to do iteration k> 1 I need to retrieve the solution of iteration k-1 and do a lot of manipulation to get the solution of iteration k, however, without changing my solution of the SSS vector of iteration k-1.
##############################################
########## The error #########################
The problem I'm having is, when I retrieve k-1 and do the manipulations, to get k, the code is changing k-1 at vector SSS as well.
##############################################
How can I fix this? Possible corrections or changes.
