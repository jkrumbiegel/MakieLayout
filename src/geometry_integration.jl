left(rect::Rect2D) = minimum(rect)[1]
right(rect::Rect2D) = maximum(rect)[1]

bottom(rect::Rect2D) = minimum(rect)[2]
top(rect::Rect2D) = maximum(rect)[2]


Base.getindex(bbox::Rect2D, ::Left) = left(bbox)
Base.getindex(bbox::Rect2D, ::Right) = right(bbox)
Base.getindex(bbox::Rect2D, ::Bottom) = bottom(bbox)
Base.getindex(bbox::Rect2D, ::Top) = top(bbox)


width(rect::Rect2D) = right(rect) - left(rect)
height(rect::Rect2D) = top(rect) - bottom(rect)

bottomleft(bbox::Rect2D{T}) where T = Point2{T}(left(bbox), bottom(bbox))
topleft(bbox::Rect2D{T}) where T = Point2{T}(left(bbox), top(bbox))
bottomright(bbox::Rect2D{T}) where T = Point2{T}(right(bbox), bottom(bbox))
topright(bbox::Rect2D{T}) where T = Point2{T}(right(bbox), top(bbox))

topline(bbox::BBox) = (topleft(bbox), topright(bbox))
bottomline(bbox::BBox) = (bottomleft(bbox), bottomright(bbox))
leftline(bbox::BBox) = (bottomleft(bbox), topleft(bbox))
rightline(bbox::BBox) = (bottomright(bbox), topright(bbox))


function BBox(left::Number, right::Number, bottom::Number, top::Number)
    mini = (left, bottom)
    maxi = (right, top)
    return BBox(mini, maxi .- mini)
end

function IRect2D(bbox::Rect2D)
    return IRect2D(
        round.(Int, minimum(bbox)),
        round.(Int, widths(bbox))
    )
end

function RowCols(ncols::Int, nrows::Int)
    return RowCols(
        zeros(ncols),
        zeros(ncols),
        zeros(nrows),
        zeros(nrows)
    )
end

Base.getindex(rowcols::RowCols, ::Left) = rowcols.lefts
Base.getindex(rowcols::RowCols, ::Right) = rowcols.rights
Base.getindex(rowcols::RowCols, ::Top) = rowcols.tops
Base.getindex(rowcols::RowCols, ::Bottom) = rowcols.bottoms

"""
    eachside(f)
Calls f over all sides (Left, Right, Top, Bottom), and creates a BBox from the result of f(side)
"""
function eachside(f)
    return BBox(map(f, (Left(), Right(), Bottom(), Top()))...)
end

"""
mapsides(
       f, first::Union{Rect2D, RowCols}, rest::Union{Rect2D, RowCols}...
   )::BBox
Maps f over all sides of the rectangle like arguments.
e.g.
```julia
mapsides(BBox(left, right, top, bottom)) do side::Side, side_val::Number
    return ...
end::BBox
```
"""
function mapsides(
        f, first::Union{Rect2D, RowCols}, rest::Union{Rect2D, RowCols}...
    )
    return eachside() do side
        f(side, getindex.((first, rest...), (side,))...)
    end
end
