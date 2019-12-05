function LayoutedButton(scene::Scene; kwargs...)

    attrs = merge!(Attributes(kwargs), default_attributes(LayoutedButton))

    @extract attrs (padding, textsize, label, font, halign, valign, cornerradius,
        cornersegments, strokewidth, strokecolor, buttoncolor,
        labelcolor, labelcolor_hover, labelcolor_active,
        buttoncolor_active, buttoncolor_hover, clicks)

    decorations = Dict{Symbol, Any}()

    sizeattrs = sizenode!(attrs.width, attrs.height)

    alignment = lift(tuple, halign, valign)

    autosizenode = Node((0f0, 0f0))

    computedsize = computedsizenode!(sizeattrs, autosizenode)

    suggestedbbox = Node(BBox(0, 100, 0, 100))

    finalbbox = alignedbboxnode!(suggestedbbox, computedsize, alignment,
        sizeattrs)

    textpos = Node(Point2f0(0, 0))

    subarea = lift(finalbbox) do bbox
        IRect2D(bbox)
    end
    subscene = Scene(scene, subarea, camera=campixel!)

    lcolor = Node{Any}(labelcolor[])
    labeltext = text!(subscene, label, position = textpos, textsize = textsize, font = font,
        color = lcolor, align = (:center, :center), raw = true)[end]

    buttonwidth = Node{Optional{Float32}}(nothing)
    buttonheight = Node{Optional{Float32}}(nothing)

    onany(label, textsize, font, padding) do label, textsize, font, padding
        textbb = FRect2D(boundingbox(labeltext))
        autowidth = width(textbb) + padding[1] + padding[2]
        autoheight = height(textbb) + padding[3] + padding[4]
        autosizenode[] = (autowidth, autoheight)
    end

    label[] = label[]

    # buttonrect is without the left bottom offset of the bbox
    buttonrect = lift(finalbbox) do bbox
        BBox(0, width(bbox), 0, height(bbox))
    end

    on(buttonrect) do rect
        textpos[] = Point2f0(left(rect) + 0.5f0 * width(rect), bottom(rect) + 0.5f0 * height(rect))
    end

    roundedrectpoints = lift(buttonrect, cornerradius, cornersegments) do rect,
            cr, csegs

        cr = min(width(rect) / 2, height(rect) / 2, cr)

        # inner corners
        ictl = topleft(rect) .+ Point2(cr, -cr)
        ictr = topright(rect) .+ Point2(-cr, -cr)
        icbl = bottomleft(rect) .+ Point2(cr, cr)
        icbr = bottomright(rect) .+ Point2(-cr, cr)

        cstr = anglepoint.(Ref(ictr), LinRange(0, pi/2, csegs), cr)
        cstl = anglepoint.(Ref(ictl), LinRange(pi/2, pi, csegs), cr)
        csbl = anglepoint.(Ref(icbl), LinRange(pi, 3pi/2, csegs), cr)
        csbr = anglepoint.(Ref(icbr), LinRange(3pi/2, 2pi, csegs), cr)

        arr = [cstr; cstl; csbl; csbr]
    end

    bcolor = Node{Any}(buttoncolor[])
    button = poly!(subscene, roundedrectpoints, strokewidth = strokewidth, strokecolor = strokecolor,
        color = bcolor, raw = true)[end]
    decorations[:button] = button
    # put button in front so the text doesn't block the mouse
    reverse!(subscene.plots)

    mousestate = addmousestate!(scene, button, labeltext)

    onmouseover(mousestate) do state
        bcolor[] = buttoncolor_hover[]
        lcolor[] = labelcolor_hover[]
    end

    onmouseout(mousestate) do state
        bcolor[] = buttoncolor[]
        lcolor[] = labelcolor[]
    end

    onmousedown(mousestate) do state
        bcolor[] = buttoncolor_active[]
        lcolor[] = labelcolor_active[]
    end

    onmouseclick(mousestate) do state
        clicks[] = clicks[] + 1
    end

    protrusions = Node(RectSides(0f0, 0f0, 0f0, 0f0))
    layoutnodes = LayoutNodes(suggestedbbox, protrusions, computedsize, finalbbox)

    LayoutedButton(scene, layoutnodes, attrs, decorations)
end

function anglepoint(center::Point2, angle::Real, radius::Real)
    Ref(center) .+ Ref(Point2(cos(angle), sin(angle))) .* radius
end

function align_to_bbox!(lb::LayoutedButton, bbox)
    lb.layoutnodes.suggestedbbox[] = bbox
end

computedsizenode(lb::LayoutedButton) = lb.layoutnodes.computedsize
protrusionnode(lb::LayoutedButton) = lb.layoutnodes.protrusions

defaultlayout(lb::LayoutedButton) = ProtrusionLayout(lb)

function Base.getproperty(lb::LayoutedButton, s::Symbol)
    if s in fieldnames(LayoutedButton)
        getfield(lb, s)
    else
        lb.attributes[s]
    end
end
function Base.propertynames(lb::LayoutedButton)
    vcat(fieldnames(LayoutedButton, keys(lb.attributes))
end
