[pre-ANN] CompressedBeliefMDPs.jl: Solve large POMDPs in POMDPs.jl!
https://github.com/JuliaPOMDP/CompressedBeliefMDPs.jl

Hello everyone!

I'm excited to announce CompressedBeliefMDPs.jl ([repo](https://github.com/JuliaPOMDP/CompressedBeliefMDPs.jl), [docs](https://juliapomdp.github.io/CompressedBeliefMDPs.jl/dev/)), *an upcoming addition* to the [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) ecosystem. CompressedBeliefMDPs.jl provides a framework for solving large POMDPs through [belief compression](https://www.cs.cmu.edu/~ggordon/roy-gordon-thrun.belief-compression-jair.pdf). 

**We are looking for suggestions, feature requests, and any other feedback people would like to share! We will be accepting feedback for around a week before we launch.**

# Current Features
- Algorithms for fast belief sampling from POMDPs
- Wrappers for compression and dimensionality reduction (ranging from variational auto-encoders to Isomap compression)
- Support for continuous and discrete action + state space POMDPs 
- Extensible framework that supports custom base solvers, compressors, and samplers

# Example Usage

```julia
using POMDPs, POMDPTools, POMDPModels
using CompressedBeliefMDPs

pomdp = BabyPOMDP()
compressor = PCACompressor(1)
updater = DiscreteUpdater(pomdp)
sampler = BeliefExpansionSampler(pomdp)
solver = CompressedBeliefSolver(
    pomdp;
    compressor=compressor,
    sampler=sampler,
    updater=updater,
    verbose=true, 
    max_iterations=100, 
    n_generative_samples=50, 
    k=2
)
policy = solve(solver, pomdp)
```

# What is belief compression?

> This provides an informal introduction to belief compression if you are unfamiliar with POMDPs.

In RL and sequential decision-making, we deal with objects called partially observed Markov decision processes (POMDPs). This is just a fancy word for a sequence of states and actions that we have imperfect information over. For example, in poker, we have a set of actions (e.g., check, bet, call, raise) and a current state that we imperfectly observe (e.g., I don't know what cards my opponents have). 

Unfortunately, real-world problems are often much larger than poker (e.g., consider all the states and actions you might face while driving in NYC), so we have to devise techniques that make the enormity of the real world computationally tractable. One way to do this is with a technique called "belief compression."

At the highest level, belief compression is just as its name implies: a compression of my beliefs. In the literature, belief is the word we use to describe a distribution over possible states. More intuitively, since I observe the world imperfectly, I don't know the _exact_ state I'm in for certain. Consider a rover on Mars, we only know its position through noisy sensor measurements that are beamed to Earth from millions of miles away: it's unreasonable to assume that we know the rover's exact position at any moment, but we do have some _belief_ over where it's likely to be. 

Since real-world problems are large, we have to maintain belief over a potentially gargantuan number of states. Luckily, there are many real-world problems where belief is sparsely distributed or concentrated. Take the Mars rover example, while the Rover could theoretically be anywhere on the surface of the planet, it is more likely to be close to where its sensors say it is (this example is, of course, an exaggeration; real POMDPs for mobile robot navigation would likely not maintain belief over an entire planet's worth of positions). As another example, we could take stock prices. For non-volatile stocks, the price one second in the future is likely to be similar to the price it trades at now (this is the essence of [martingales](https://en.wikipedia.org/wiki/Martingale_(probability_theory)). 

But what does all of this get at? The core idea of belief compression is this: _because I am likely to have some information about what state I'm in, it's inefficient to maintain belief about places I'm unlikely to be; if I can learn to more compactly represent my beliefs, then I can focus on planning from the most relevant belief-states._

Belief compression is thus a method for solving large POMDPs that concentrates computational power on a compressed representation of the belief space.
