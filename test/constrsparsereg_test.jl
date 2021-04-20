module constrsparsereg_test

using Test, ConstrainedLasso, ECOS, Random

@info("Test lsq_constrsparsereg: sum-to-zero constraint")

# set up
Random.seed!(123)
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
Aeq = ones(1, p)
beq = [0.0]
penwt  = ones(p)
solver = ECOSSolver(maxit=10e8, verbose=0)

@info("Optimize at a single tuning parameter value")
ρ = 10.0
β̂, = lsq_constrsparsereg(X, y, ρ; Aeq = Aeq, beq = beq,
    penwt = penwt, solver = solver)
@test sum(β̂)≈0.0 atol=1e-6

@info("Optimize at multiple tuning parameter values")
ρlist = [0.0:10.0; Inf]
β̂, = lsq_constrsparsereg(X, y, ρlist; Aeq = Aeq, beq = beq,
    penwt = penwt, solver = solver)
@testset "zero-sum for multiple param values" begin
for si in sum(β̂, dims=1)
    @test si≈0.0 atol=1e-6
end
end

@info("Optimize at multiple tuning parameter values (warm start)")
β̂ws, = lsq_constrsparsereg(X, y, ρlist; Aeq = Aeq, beq = beq,
    penwt = penwt, solver = solver, warmstart = true)
#@show sum(β̂ws, 1)
@testset "zero-sum for multiple param values" begin
for si in sum(β̂ws, dims=1)
    @test si≈0.0 atol=1e-6
end
end

end # end of module
