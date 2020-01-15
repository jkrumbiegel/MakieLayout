# Questions
- How can a recipe system work with complex layouts?
- How can axes be reused in recipes to plot a second layer on top of a previous?
- How are legends constructed in single recipes and how are they correctly updated in case of a second layer plotted on an existing one?
- What should be sensible defaults for plotting with base commands, what should they return?

With MakieLayout, high-level elements are treated as mostly autonomous containers
that take care of how their content is presented. They adjust their visual size and position
by receiving a suggested bounding box. This should usually (but doesn't need to)
be generated by a GridLayout that the element is assigned to. Therefore, to be placed
in a scene, an element does not need to be in a layout, but being in a layout moves
and resizes the element so it sensibly fits in with the other content. Usually, most
elements will exist in a layout, so incorporating layouts into the Makie pipeline
should be the default mode of thinking.

GridLayouts are flexibly resizable, columns and rows can be added and removed,
and they can be placed inside other GridLayouts. Therefore, a whole group of
elements can be placed inside an existing layout as a cohesive layout element using
a common GridLayout. This makes it possible to easily assemble larger layouts from
smaller parts. A subplot group can be generated in a separate function (or recipe)
and the result be attached to an existing Scene. This way, complex plots can be assembled
easily.

There are multiple important objects that the user should keep track of in order
to correctly build their visualization and update parameters if they wish. These are:

- The top-level Scene in which all other content is placed
- The layout tree in form of the top GridLayout, or even every single used GridLayout
- Larger content elements of the top-level Scene such as other Scenes or SceneLikes
(LAxis is a SceneLike) or elements such as LText, LColorbar, LLegend, etc.
- Plots that have been added to Scenes or LAxis instances

The user will not always want to specify all parameters needed for a single correctly
plotted element. For example, a Scene should be generated when creating a Scatter
plot, if there is no Scene given as a mutated argument. In the same way, an LAxis
could be needed if none exists yet, which would be placed in the Scene. And for
the LAxis to be placed correctly, a layout will be needed, too. Of course, the Scatter
object itself should also be accessible as a result of the function call.
Therefore, a simple Scatter plot can result in four (or even more?) objects being created.

```julia
scene, layout, ax, scat = scatter(rand(10, 2))
```

It is probably not desirable to force the user to assign all of these to variables
every time they create a simple plot. Also, it should still be possible to show the
scene even after a single command like this is run. This could be achieved with
multiple dispatch on the specific return Tuple or NamedTuple type from the scatter
function.

```julia
function scatter(x, y)
    # create scene, layout, ax and scat
    # then return a NamedTuple
    NamedTuple(scene = scene, layout = layout, axis = ax, plot = scat)
end

function Base.display(nt::NamedTuple{T, Tuple{Scene,GridLayout,U, V}}) where {T, U, V}
    display(nt.scene)
end
```