# Osmosis Simulation

An interactive, single-screen animal-cell osmosis model for middle and early high school biology, built for Godot 4.7. Move the outside-solution slider from −5 to +5 and watch water cross the membrane, the cell change size, and the inside and outside concentration bars respond.

## Open and run

1. Install Godot 4.7 and open the folder containing `project.godot` in the Godot project manager.
2. Let Godot import the project, then press **F6** with `scenes/main.tscn` open or **F5** to run the project.
3. Use the slider, **Pause**, **Reset**, and **Show target size**. The gold outline is a reachable shrinking target; hold the cell within 2% of its target radius for one second.

No external assets or plugins are required. The scene and visuals are drawn in GDScript.

## Reading the display

The slider is a fixed **outside setting compared with the starting cell**. The live status compares the outside solution with the **current** cell. For example, the slider may stay at +5 while the status eventually says “balanced,” because water leaving the cell increased its internal concentration. The two bars show relative model units, not measured salt percentages. Distilled water, plasma, and seawater are qualitative reference examples; saturated salt solution is off this scale.

Water crosses both ways even when there is no net movement. Blue circles are water and orange squares are solute. The organelles are decorative. Particle sizes, counts, and motion are illustrative and do not drive the calculations.

## Model and files

The simulation keeps internal solute amount fixed and treats the outside solution as a reservoir. With internal solute `S`, internal water `W`, and external concentration `C_out`, the inward water flow is `clamp(k × (S/W − C_out), −F_max, F_max)`. Water volume changes over time, and radius scales with its cube root. The update prevents crossing the equilibrium volume in one step. Parameters are in `resources/animal_cell.tres` through `scripts/cell_profile.gd`.

- `DESIGN.md` — full design document and acceptance criteria.
- `scenes/main.tscn` and `scripts/main.gd` — layout, controls, labels, and connections.
- `scripts/simulation.gd` — authoritative model and state signal.
- `scripts/cell_view.gd` — membrane and decorative organelles.
- `scripts/particle_field.gd` — illustrative particle motion and membrane crossings.

## Development status

This is the first playable implementation. It has not yet been verified in a Godot 4.7 editor in this environment. The scene uses no imported assets, so Godot's generated `.godot/` directory is excluded from Git. Open the project in Godot and report any parser or rendering issue with its line number for a quick fix.
