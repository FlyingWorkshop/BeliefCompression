abstract type Approximator end


"""
    fit!(approximator::Approximator, data)

Fit the approximator to the data.
"""
function fit!(approximator::Approximator, data) end


"""
    approximate(approximator::Approximator, points)

Approximate the points using method associated with approximator, and returns the approximation.
"""
function approximate(approximator::Approximator, points) end