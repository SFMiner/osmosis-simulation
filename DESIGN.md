# Osmosis Simulation — Game Design Document

**Status:** Revised design draft  
**Engine:** Godot 4.7  
**Format:** Single-screen, interactive 2D science simulation  
**Audience:** Middle and early high school biology students

## 1. Purpose

Let students change the concentration of the solution around a cell and observe how water moves across its membrane. The central idea is **osmosis: net movement of water toward the side with higher solute concentration**, causing the cell to swell or shrink. The display is a teaching model; particle sizes, numbers, speeds, and cell dimensions are illustrative rather than to scale.

The experience should reward experimenting with both sides of neutral. Students can move the slider while the simulation runs and watch the cell respond, then return it to neutral and see movement settle.

## 2. Main screen

A large cell occupies the center of a visible area of surrounding solution. Its boundary is an animated membrane. Inside are cytoplasm, moving water particles, solute particles, and recognizable but nonfunctional organelles. The organelles give the cell visual context; they do not take part in transport or alter the calculations.

The surrounding solution contains the **same visual types** of water and solute particles. Water particles are small blue dots; solute particles use a contrasting shape and color so the two remain distinguishable without relying on color alone. A compact legend labels them. Particles move gently on both sides even at equilibrium.

Below or beside the scene is one slider with eleven discrete positions: **−5 to +5**, with **0 = equal to the starting cell**. Negative values initially make the outside hypotonic relative to the cell; positive values initially make it hypertonic. The slider heading stays **“Outside solution setting (compared with the starting cell)”**; its fixed end and center labels read “Lower solute,” “Starting match,” and “Higher solute.” A separate live readout says **“Right now: outside hypotonic / hypertonic / balanced relative to the current cell”**, followed by “Net water movement: in / out / balanced.” Once the cell adjusts, this readout may say balanced even though the setting is still +5: an adjacent sentence explains, “The outside setting stayed the same; water leaving the cell raised its inside concentration.” Display the selected number. Include **Reset** and **Pause / Play** controls.

Add a short **real-world reference rail** near the slider, explicitly labeled “Examples, not measurements of this model.” Its hover/focus notes identify distilled water as essentially no dissolved solute; blood plasma as a complex mixture that is roughly isotonic to typical human cells (normal saline is an approximate teaching comparison, not plasma); seawater as substantially saltier; and saturated sodium chloride solution as the most NaCl that dissolves at a specified temperature, with undissolved salt remaining if more is added. Place distilled water at the low end, plasma near the baseline, and seawater at the high end as *qualitative* anchors. Show salt saturation beyond the +5 end with an **“off scale”** marker, not a selectable tick. The markers are deliberately not evenly spaced and do not assign salt percentages to slider values. Provide the same notes by click or keyboard focus; no information is hover-only. Do not imply that all solutes behave identically or that seawater and NaCl solution have the same composition.

## 3. Core interaction and observable results

| Outside setting | Relative outside solute | Net water movement | Cell response |
| --- | --- | --- | --- |
| −5 to −1: hypotonic | Lower than inside | Into cell | Swells |
| 0: isotonic | Equal to inside | Neither direction overall | Stable size |
| +1 to +5: hypertonic | Higher than inside | Out of cell | Shrinks |

Larger absolute slider values produce a stronger imbalance and a faster visible approach to the corresponding size. Water crosses in **both directions at every setting**; the difference in crossing rates creates the net effect. Solute particles remain on their side of the membrane in this first version. At 0, water continues crossing in both directions at roughly equal rates and the cell stays approximately the same size.

When the slider changes, the outside particle mix updates clearly and smoothly. The cell's size and the net-flow indicator respond over time, not in an instant. Students can reverse the direction by dragging across zero. The simulation must remain legible if the slider moves repeatedly while the cell is still changing size.

## 4. Model rules for the first build

This is a conceptual model, not a molecular dynamics simulation. Set an internal baseline concentration and represent the selected slider position as an **external concentration relative to that baseline**. Keep the internal solute amount fixed. Track the cell's water amount and use it to determine its displayed size. As water enters or leaves, internal concentration changes; movement should slow as the concentrations approach equilibrium. The simulation should never allow the cell to disappear or grow beyond the viewport.

At each simulation step:

1. Determine inside concentration from fixed internal solute amount and current internal water amount.
2. Determine outside concentration from the slider setting. Treat the surrounding solution as a large reservoir whose setting stays fixed until the student changes it.
3. Calculate net water movement toward the higher effective solute concentration using the proportional rule below.
4. Update internal water amount and cell radius within safe display bounds.
5. Animate individual water particles crossing both ways, with crossing frequencies reflecting the current net movement. Particle positions are a visual representation of the model's totals, not the source of the calculations.

**Teaching simplification:** The slider directly sets the outside solution's concentration. It does not specify a physically measured molarity. Particle counts are illustrative and need not equal the values in the calculation. The terms hypo-, hyper-, and isotonic describe the **outside solution relative to the cell at that moment**. Since the cell changes as water moves, the live description should use the actual current concentration difference; the slider label identifies the chosen external setting relative to the original cell. This prevents the display from claiming a lasting net flow after equilibrium.

**Deterministic update rule (model units):** Let fixed internal solute amount be `S = 1`, initial water volume `W₀ = 1`, and `C₀ = S/W₀ = 1`. For slider integer `p ∈ [−5, 5]`, set reservoir concentration `C_out = C₀ × (1 + 0.08p)` (range 0.60–1.40). At each physics step of `dt` seconds, `C_in = S/W`, `raw_flow = k × (C_in − C_out)` water-volume units per second, with positive flow meaning inward. Set `flow = clamp(raw_flow, −F_max, F_max)`, and `W_next = clamp(W + flow × dt, W_min, W_max)`. Start with `k = 0.30 s⁻¹`, `F_max = 0.20 volume/s`, and `W_min = 0.65`, `W_max = 1.75`; tune with students. Map volume to the drawn 2D radius as `r = r₀ × (W/W₀)^(1/3)` to suggest a three-dimensional cell, then validate that the drawn radius stays within the viewport. These bounds encompass the nominal equilibria `W* = S/C_out` across all eleven settings. Do not use visual tween lag as model state; the view follows the authoritative `W`. Use fixed physics steps or bounded `dt` and never overshoot `W*` in one step: if the proposed update crosses `W*`, set `W_next = W*`. Display “balanced” when `|C_in − C_out| < 0.01` and suppress any residual numerical drift at equilibrium. At a bound with nonzero gradient, describe the size limit rather than calling it equilibrium.

**Particle crossings:** For every step, schedule a low baseline number of inward and outward water crossings. Increase only the crossing frequency in the net direction by an amount proportional to `|flow|`; do not assign all crossings to one direction. Pick a wandering particle already near the membrane in the relevant compartment, let it continue locally to a crossing point, then move it continuously across the boundary and return it to ordinary random motion. A short waiting queue may hold an event until a nearby particle is available; never drag a remote particle across the scene or teleport it. Crossing sprites are recycled on the destination side; background counts are maintained by a pool, not read back into the model. At equilibrium, equal baseline crossing frequencies persist. Recompute crossing paths against the moving membrane and discard or reschedule outdated events when the slider reverses, pauses, or resets.

## 5. Feedback and visual behavior

- Membrane: a clear, flexible outline that expands and contracts with the cell. Organelles stay within it and reposition gently as the cell changes size.
- Particles: continuous low-speed motion; water crossing the membrane is visible, with no teleporting or clustering at the boundary. Solute particles do not cross.
- Flow feedback: a modest arrow and text for “Net movement: in,” “out,” or “balanced.” The arrow is secondary to the actual particle crossings.
- Concentration feedback: **required** paired inside and outside bars on one fixed, labeled scale spanning the modeled concentration range, alongside numeric model-unit values and the live relationship in words. The inside bar rises as water leaves the cell; the outside bar remains fixed until the slider changes. Clarify that these are relative model units, not measured salt percentages.
- Target-size activity: a toggle overlays a transparent target-cell outline and a “Match the target size” prompt. Provide a reachable target within the cell's modeled size range, a size-difference indicator, and a success message once the cell remains within tolerance (initially 2% of target radius for 1 second). After matching, students may keep experimenting. Reset clears the target challenge; Pause freezes its timer. The target is an optional activity, while the sandbox remains usable without it.
- Size feedback: cell visibly swells or shrinks, with gentle easing. Avoid implying that it bursts or dies in the first version.
- Accessibility: readable labels, strong contrast, particle shape differences, and text that explains movement without depending on animation or color alone.

## 6. First-version scope

**Required:** single scene; centered cell and decorative organelles; inside/outside water and solute particles; eleven-position slider and qualitative reference markers; bidirectional water movement with visible net direction; gradual cell size changes; responsive reversal and equilibration; live labels and two concentration bars; toggleable target-size challenge; pause/play; reset; short on-screen legend and instruction.

**Deferred:** selectable cell types, real concentration units, membrane channels, active transport, solute permeability, cell rupture or lysis, scoring, levels, quizzes, and saved sessions.

## 7. Suggested Godot structure

- `Main` (`Control`): layout, slider, buttons, concentration bars, challenge controls, labels, and legend; owns connection setup.
- `Simulation` (`Node2D`): owns concentration, water amount, rate calculation, and update loop. Keep simulation state separate from drawn particles.
- `CellView` (`Node2D`): membrane, cytoplasm, decorative organelles, and size animation driven by simulation state.
- `ParticleField` (`Node2D`): pooled particles on each side and visual crossing events; visual density is independent of modeled quantities.
- `CellProfile` (`Resource`): tunable model constants, initial quantities, visual bounds, and crossing/display rates; the first preset is an animal cell. A `CellProfile.tres` instance is exported on `Simulation`.

Wire communication in `Main` at startup with explicit signals and typed methods: `Main.slider_changed(value)` connects to `Simulation.set_external_setting(value)`; `Simulation.state_updated(radius, net_flow_rate, c_in, c_out)` connects to `CellView.update_state(...)`, `ParticleField.update_state(...)`, and `Main.update_readouts(...)`. `Simulation` owns physics ticks and emits state after each step, including pause, reset, and setting changes. Controls signal intent upward to `Main`, which calls the simulation downward; visual nodes do not fetch state through hardcoded sibling paths. The target overlay uses the same authoritative radius and emits `target_reached` to `Main` when the dwell criterion is met. A profile can change tuning without changing the node tree; a future cell type still needs separate validation of its biology and rendering.

## 8. Acceptance criteria

1. At 0, particles move and water crosses both ways, while the cell's overall size remains stable.
2. At −5, the outside displays relatively less solute, net water flow is inward, and the cell visibly swells over several seconds.
3. At +5, the outside displays relatively more solute, net water flow is outward, and the cell visibly shrinks over several seconds.
4. Switching from −5 to +5 while running reverses net movement and eventually reverses the size trend without a jump.
5. At a fixed slider value, cell size approaches a stable value rather than changing forever; the live net-flow label becomes balanced near equilibrium.
6. Solute particles stay on their side of the membrane; decorative organelles do not affect water movement.
7. Pause stops model and particle animation; Play resumes. Reset restores the initial cell, particle presentation, and slider value.
8. At +5 after equilibration, the fixed slider setting still reads “Higher solute,” while the current-state readout says balanced and explains the cell's changed concentration; the bars converge.
9. The paired bars show the internal rise during shrinkage and the stable external reservoir; both remain legible in pause and on reset.
10. Water crossing is continuous at the membrane, including during reversal; the target outline can be reached by slider timing and reports success only after its dwell period.

## 9. Design decisions to revisit after the prototype

- Should this be identified specifically as an animal cell? The current swelling/shrinking behavior and absence of a rigid cell wall imply one; the first build should label it **animal cell**.
- How quickly should a full slider setting reach visible near-equilibrium in class? Initial target: about 10–20 seconds, tunable after hands-on testing.
- Should the external particle display show a fixed total number of dots or a fixed water count with solute added? Prefer fixed visual density with a changing mix so students can compare concentrations without crowding.
