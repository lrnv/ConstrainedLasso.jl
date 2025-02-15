module genlasso_test

using Test, ConstrainedLasso, ECOS, Random, LinearAlgebra

@info("Test genlasso")

y = randn(20)
n = p = size(y, 1)
X = Matrix{Float64}(I, n,n)
D = [eye(p-1) zeros(p-1, 1)] - [zeros(p-1, 1) Matrix{Float64}(I, p-1,p-1)]
β̂path, = genlasso(X, y; D = D)
tmp = round.(β̂path, 6)

@testset "fused lasso" begin
for i in 1:(size(tmp, 2) - 1)
  @test length(unique(tmp[:, i])) < n
end
end


end # end of module
