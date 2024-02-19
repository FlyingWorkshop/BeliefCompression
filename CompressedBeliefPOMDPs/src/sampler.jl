using POMDPs: POMDP, Policy, Updater


abstract type Sampler end


struct BaseSampler
    n_samples::Int
    policy::Policy
    updater::Updater
end

RandomSampler(pomdp::POMDP; n_samples::Int=100) = BaseSampler(n_samples, RandomPolicy(pomdp), Updater(pomdp))

sample(sampler::BaseSampler, pomdp::POMDP) = sample(pomdp, sampler.n_samples, sampler.policy, sampler.updater)

function sample(pomdp::POMDP, n_samples::Int, policy::Policy, updater::Updater)
    # TODO: make compatible w/ envs w/ terminal states that don't reach max steps
    B = [dist.b for dist in stepthrough(pomdp, policy, updater, "b", max_steps=n_samples)]
    B = hcat(B...)'  # convert to matrix
    return B
end
