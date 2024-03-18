### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 6635a1e0-cb76-4e9a-8262-2ba7f49dd939
begin
	using Pkg
	Pkg.activate()
	using Revise

	using Random

	# JuliaPOMDPs
	using POMDPs
	using POMDPModels
	using POMDPTools
end

# ╔═╡ f09875f8-e6ea-4292-86dc-bf013bd6dab4
pomdp = BabyPOMDP();

# ╔═╡ 28574220-d159-4468-b66b-4cc24654662a
begin
	using BasicPOMCP

	pomcp_solver = POMCPSolver(; c=5.0, tree_queries=1000, rng=MersenneTwister(1))
	pomcp_planner = solve(pomcp_solver, pomdp)
end

# ╔═╡ d733546c-5810-43f9-a191-e08d8cb48609
begin
	using CompressedBeliefMDPs
	sampler = DiscreteRandomSampler(pomdp)
	compressor = PCACompressor(1)
	comp_solver = CompressedSolver(
		pomdp, 
		sampler, 
		compressor; 
		n_samples=100, 
		verbose=true,
		k=10,
		max_iterations=1000,
		n_generative_samples=10,
	)
	comp_policy = solve(comp_solver, pomdp)
end

# ╔═╡ 253c9eaa-97c2-4205-8e51-9ef52181f3dc
begin
	using SARSOP
	
	sarsop_solver = SARSOPSolver()
	sarsop_policy = solve(sarsop_solver, pomdp)
end

# ╔═╡ 3d438978-6f62-4246-9b15-cfb89b3ee41e
begin
	using Plots
	using LaTeXStrings
	
	plot()
	x = LinRange(0, 1, 5)
	policies = (
		(sarsop_policy, "SARSOP"),
		(comp_policy, "compressed"),
	)
	for (policy, label) in policies
		y = map(p->value(policy, DiscreteBelief(pomdp, [1-p, p])), x)
		plot!(x, y, label=label)
	end
	xlabel!(L"$P($hungry$)$")
	ylabel!(L"$U(b)$")
end

# ╔═╡ b74c08b0-846c-4598-8386-c42cb558d1e1
begin
	struct HeuristicFeedPolicy{P<:POMDP} <: Policy
	    pomdp::P
	end
	
	# We need to implement the action function for our policy
	function POMDPs.action(policy::HeuristicFeedPolicy, b)
	    if pdf(b, :hungry) > 0.5
	        return :feed
	    else
	        return rand([:ignore, :sing])
	    end
	end
	
	# Let's also define the default updater for our policy
	function POMDPs.updater(policy::HeuristicFeedPolicy)
	    return DiscreteUpdater(policy.pomdp)
	end
	
	heuristic_policy = HeuristicFeedPolicy(pomdp)
end

# ╔═╡ 59b10983-324d-41f0-ae17-5a10dacfd072
begin
	sim = RolloutSimulator(MersenneTwister(1), 10)
	sarsop_r = simulate(sim, pomdp, sarsop_policy)
	comp_r = simulate(sim, pomdp, comp_policy)
end

# ╔═╡ Cell order:
# ╠═6635a1e0-cb76-4e9a-8262-2ba7f49dd939
# ╠═f09875f8-e6ea-4292-86dc-bf013bd6dab4
# ╠═d733546c-5810-43f9-a191-e08d8cb48609
# ╠═253c9eaa-97c2-4205-8e51-9ef52181f3dc
# ╠═28574220-d159-4468-b66b-4cc24654662a
# ╠═b74c08b0-846c-4598-8386-c42cb558d1e1
# ╠═3d438978-6f62-4246-9b15-cfb89b3ee41e
# ╠═59b10983-324d-41f0-ae17-5a10dacfd072
