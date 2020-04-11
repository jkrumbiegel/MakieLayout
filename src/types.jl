const Optional{T} = Union{Nothing, T}



struct AxisAspect
    aspect::Float32
end

struct DataAspect end

abstract type Ticks end

struct AutoLinearTicks{T<:Union{Int, Float32}} <: Ticks
    target::T
end

"""
    WilkinsonTicks([k_ideal::Int = 5]; kwargs...)
This is basically Wilkinson's ad-hoc scoring method that tries to balance
tight fit around the data, optimal number of ticks, and simple numbers.
This is the function which Plots.jl and Makie.jl use by default.

## Keyword Arguments

* `Q`: A distribution of nice numbers from which labellings are sampled. Stored in the form (number, score).
* `k_min`: The minimum number of ticks.
* `k_max`: The maximum number of ticks.
* `k_ideal`:  The ideal number of ticks.
* `granularity_weight`: Encourages returning roughly the number of labels requested.
* `simplicity_weight`: Encourages nicer labeling sequences by preferring step sizes that appear earlier in Q.
    Also rewards labelings that include 0 as a way to ground the sequence.
* `coverage_weight`: Encourages labelings that do not extend far beyond the range of the data, penalizing unnecessary whitespace.
* `niceness_weight`: Encourages labellings to produce nice ranges.

"""
struct WilkinsonTicks <: Ticks
    k_ideal::Int
    k_min::Int
    k_max::Int
    Q::Vector{Tuple{Float64, Float64}}
    granularity_weight::Float64
    simplicity_weight::Float64
    coverage_weight::Float64
    niceness_weight::Float64
    min_px_dist::Float64
end

"""
    struct ManualTicks <: Ticks

These allow you to encode arbitrary, manual ticks.  The constructor has the form
`ManualTicks(values::Vector{Float32), labels::Vector{String})`.
"""
struct ManualTicks <: Ticks
    values::Vector{Float32}
    labels::Vector{String}
end

"""
    struct CustomTicks{F1<:Function, F2<:Function} <: Ticks

For the use of custom functions that compute tick values and labels in an `LAxis`.

- `f_tickvalues::F1`: A function that takes minimum_value, maximum_value, and pixelwidth as arguments and returns a `Float` array of tick values.
- `f_ticklabels::F2`: A function that takes in an array of `Float`s and returns an array of `String` labels.
"""
struct CustomTicks{F1<:Function, F2<:Function} <: Ticks
    f_tickvalues::F1
    f_ticklabels::F2
end

mutable struct LineAxis
    parent::Scene
    protrusion::Node{Float32}
    attributes::Attributes
    decorations::Dict{Symbol, Any}
    tickpositions::Node{Vector{Point2f0}}
    tickvalues::Node{Vector{Float32}}
    ticklabels::Node{Vector{String}}
end

abstract type LObject end

mutable struct LAxis <: AbstractPlotting.AbstractScene
    parent::Scene
    scene::Scene
    xaxislinks::Vector{LAxis}
    yaxislinks::Vector{LAxis}
    limits::Node{FRect2D}
    layoutobservables::LayoutObservables
    attributes::Attributes
    block_limit_linking::Node{Bool}
    decorations::Dict{Symbol, Any}
end

mutable struct LColorbar <: LObject
    parent::Scene
    layoutobservables::LayoutObservables
    attributes::Attributes
    decorations::Dict{Symbol, Any}
end

mutable struct LText <: LObject
    parent::Scene
    layoutobservables::LayoutObservables
    textobject::AbstractPlotting.Text
    attributes::Attributes
end

mutable struct LRect <: LObject
    parent::Scene
    layoutobservables::LayoutObservables
    rect::AbstractPlotting.Poly
    attributes::Attributes
end

struct LSlider <: LObject
    scene::Scene
    layoutobservables::LayoutObservables
    attributes::Attributes
    decorations::Dict{Symbol, Any}
end

struct LButton <: LObject
    scene::Scene
    layoutobservables::LayoutObservables
    attributes::Attributes
    decorations::Dict{Symbol, Any}
end

struct LToggle <: LObject
    scene::Scene
    layoutobservables::LayoutObservables
    attributes::Attributes
    decorations::Dict{Symbol, Any}
end

abstract type LegendElement end

struct LineElement <: LegendElement
    attributes::Attributes
end

struct MarkerElement <: LegendElement
    attributes::Attributes
end

struct PolyElement <: LegendElement
    attributes::Attributes
end

struct LegendEntry
    elements::Vector{LegendElement}
    attributes::Attributes
end

const EntryGroup = Tuple{Optional{String}, Vector{LegendEntry}}

struct LLegend <: LObject
    scene::Scene
    entrygroups::Node{Vector{EntryGroup}}
    layoutobservables::LayoutObservables
    attributes::Attributes
    decorations::Dict{Symbol, Any}
    entrytexts::Vector{LText}
    entryplots::Vector{Vector{AbstractPlot}}
end

const Indexables = Union{UnitRange, Int, Colon}

struct GridPosition
    layout::GridLayout
    rows::Indexables # this doesn't warrant type parameters I think
    cols::Indexables # as these objects will only be used briefly
end

struct LScene <: AbstractPlotting.AbstractScene
    scene::Scene
    attributes::Attributes
    layoutobservables::MakieLayout.LayoutObservables
end
