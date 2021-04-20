module classopath_test

using Test, ConstrainedLasso, ECOS, Random

@info("Test lsq_classopath: sum-to-zero constraint")

# set up
Random.seed!(456)
n, p = 100, 20
# truth with sum constraint sum(β) = 0
β = zeros(p)
β[1:round(Int, p / 4)] .= 0
β[(round(Int, p / 4) + 1):round(Int, p / 2)] .= 1
β[(round(Int, p / 2) + 1):round(Int, 3p / 4)] .= 0
β[(round(Int, 3p / 4) + 1):p] .= -1
# generate data
X = randn(n, p)
y = X * β + randn(n)
# equality constraints
Aeq = ones(1, p)
beq = [0.0]
penwt  = ones(p)

β̂path1, ρpath1, objpath, = lsq_classopath(X, y; Aeq = Aeq, beq = beq)
# print(β̂path1)
# print(size(β̂path1))
# print(sum(β̂path1,1))
@test all(abs.(sum(β̂path1, 1)) .< 1.0e-6)


@info("Test lsq_classopath: non-negativity constraint")

# set up
n, p = 20, 100
# truth with a few non-zero coefficients
β = zeros(p)
β[1:10] = 1:10
# generate data
Random.seed!(123)
X = randn(n, p)
y = X * β + randn(n)
# inequality constraints
Aineq = - eye(p)
bineq = zeros(p)

solver = ECOSSolver(verbose=0, maxit=1e8)

β̂path2, ρpath2, = lsq_classopath(X, y; Aineq = Aineq, bineq = bineq, solver=solver)

@testset "non-negativity" begin
for i in reshape(β̂path2, p * length(ρpath2), 1)
  @test i >= 0
end
end

end # classopath_test module
