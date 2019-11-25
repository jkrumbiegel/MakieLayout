using MakieLayout
using Makie

function stupid_subscenes(
        parent::Scene, px_area;
        events = scene.events,
        theme = copy(theme(scene)),
        current_screens = scene.current_screens,
        clear = true,
        scene_attributes...
    )
    child = Scene(
        events,
        px_area,
        Camera(px_area),
        Base.RefValue{Any}(EmptyCamera()),
        nothing,
        Transformation(),
        AbstractPlot[],
        merge(AbstractPlotting.current_default_theme(), theme),
        merge!(Attributes(clear = clear; scene_attributes...), scene.attributes),
        Scene[],
        current_screens
    )
    # Set the transformation parent
    child.transformation.parent[] = child
    push!(scene.children, child)
    child
end

MakieLayout.defaultlayout(s::Scene) = ProtrusionLayout(s)
function MakieLayout.align_to_bbox!(s::Scene, bbox)
    pixelarea(s)[] = IRect2D(bbox)
end

begin
    scene = Scene(resolution = (1000, 1000));
    screen = display(scene)
    campixel!(scene);

    nrows = 2
    ncols = 2

    maingl = GridLayout(1, 1, parent=scene, alignmode=Outside(30))

    gridgl = maingl[1, 1] = GridLayout(
        nrows, ncols)

    gridgl[1:2, 1] = LayoutedAxis(scene)
    gridgl[1, 2] = LayoutedAxis(scene)

    subscene = stupid_subscenes(scene, Node(IRect2D(BBox(0, 100, 100, 0))))
    subscene.backgroundcolor = RGBf0(0.96, 0.96, 0.96)
    subscene.clear = true
    gridgl[2, 2] = subscene

    scatter!(subscene, rand(100, 3), markersize=10, show_axis=true)

    display(scene)

    slidergl = gridgl[3, :] = GridLayout(1, 1)
    slidergl[1, 1] = LayoutedText(scene, text="Turbulence", halign=:left)
    slidergl[1, 2] = LayoutedSlider(scene, 30, 0.0:0.1:100.0; buttonsize=20, textsize=20)
    slidergl[2, 1] = LayoutedText(scene, text="Gamma Factor", halign=:left)
    slidergl[2, 2] = LayoutedSlider(scene, 30, 0.0:0.1:100.0; buttonsize=20, textsize=20)
    slidergl[3, 1] = LayoutedText(scene, text="Precision", halign=:left)
    slidergl[3, 2] = LayoutedSlider(scene, 30, 0.0:0.1:100.0; buttonsize=20, textsize=20)

    nothing
end

tight_ticklabel_spacing!(gridgl[1:2, 1].content)

gridgl[1:2, 1].content.xticklabelrotation = pi/8
gridgl[1:2, 1].content.xticklabelalign = (:top, :center)
