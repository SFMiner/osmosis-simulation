# Osmosis Simulation

An interactive, single-screen animal-cell osmosis model for middle and early high school biology, built for Godot 4.7. Move the outside-solution slider from −5 to +5 and watch water cross the membrane, the cell change size, and the inside and outside concentration bars respond.

## Open and run

1. Install Godot 4.7 and open the folder containing `project.godot` in the Godot project manager.
2. Let Godot import the project, then press **F6** with `scenes/main.tscn` open or **F5** to run the project.
3. Use the slider, **Pause**, **Reset**, and **Show Neutral size**. The gold outline marks the normal starting cell size at setting 0, providing a fixed reference as hypotonic solutions swell the cell and hypertonic solutions shrink it.

No external assets or plugins are required. The scene and visuals are drawn in GDScript.

## Reading the display

The slider is a fixed **outside setting compared with the starting cell**. The live status compares the outside solution with the **current** cell. For example, the slider may stay at +5 while the status eventually says “balanced,” because water leaving the cell increased its internal concentration. The two bars show relative model units, not measured salt percentages. Distilled water, plasma, and seawater are qualitative reference examples; saturated salt solution is off this scale.

Water crosses both ways even when there is no net movement. Blue circles are water and orange squares are solute. The organelles are decorative. Particle sizes, counts, and motion are illustrative and do not drive the calculations.

## Model and files

The simulation keeps internal solute amount fixed and treats the outside solution as a reservoir. With internal solute `S`, internal water `W`, and external concentration `C_out`, the inward water flow is `clamp(k × (S/W − C_out), −F_max, F_max)`. Water volume changes over time, and the displayed radius doubles the cube-root size change from neutral: `r = r₀ × [1 + 2 × ((W/W₀)^(1/3) − 1)]`. This visual exaggeration makes swelling and shrinking easier to compare. The update prevents crossing the equilibrium volume in one step. Parameters are in `resources/animal_cell.tres` through `scripts/cell_profile.gd`.

- `DESIGN.md` — full design document and acceptance criteria.
- `scenes/main.tscn` and `scripts/main.gd` — layout, controls, labels, and connections.
- `scripts/simulation.gd` — authoritative model and state signal.
- `scripts/cell_view.gd` — membrane and decorative organelles.
- `scripts/particle_field.gd` — illustrative particle motion and membrane crossings.

## Development status

This is the first playable implementation. It has not yet been verified in a Godot 4.7 editor in this environment. The scene uses no imported assets, so Godot's generated `.godot/` directory is excluded from Git. Open the project in Godot and report any parser or rendering issue with its line number for a quick fix.

The lowest setting (-5) represents solute-free distilled water. Negative settings interpolate to the normal concentration at 0; positive settings retain their original scale. Outside solute particles track the selected concentration. Very dilute solutions reach the display size limit, which is explicitly distinguished from equilibrium.

## Red blood cell mode

Click **Red blood cell mode** at the top to switch to 16 floating red blood cells. **Single-cell mode** switches back. Switching modes starts a fresh neutral simulation.

The shared slider changes the surrounding solution. Hypertonic solutions shrink the cells and give them uneven outlines. Hypotonic solutions swell them; sufficiently dilute solutions, including distilled water at -5, rupture their membranes (hemolysis), then the broken outlines fade away. Cells do not return when the slider changes: **Reset** supplies new cells. **Pause** freezes swelling, drifting, and fading. **Show Neutral size** adds each intact cell's original outline.

Each cell tracks its own water amount and internal concentration. The bars summarize the mean inside concentration of intact cells and the reservoir concentration. After all cells burst, the inside bar disappears. The illustrative burst thresholds vary from 1.55 to 1.70 times starting water volume; sizes, timings, and thresholds are teaching choices, not measured clinical values. Released contents are not tracked in the reservoir.

Behavior checks: run Godot with `--headless --path . --script res://tests/red_blood_cell_mode_test.gd`.
