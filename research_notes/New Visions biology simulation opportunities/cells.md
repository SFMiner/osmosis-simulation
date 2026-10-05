# Cellular and physiology simulation opportunities

## What does the curriculum actually contain?

### Takeaway
The user's existing osmosis work fits Unit 1, Marathon Runner. The strongest next extension connects the cell to whole-body water regulation; separate glucose, gas-exchange, and thermoregulation modules also have specific lesson homes.

### Cited Findings
- New Visions labels this a high-school biology course. Middle-school use would be an adaptation, not evidence of a separate middle-school edition. [Official biology page](https://www.newvisions.org/curriculum/science/biology)
- Marathon Runner contains Gas Exchange and Cellular Respiration, Muscles & Energy, Human Thermoregulation, and Water Balance, all connected to explaining the runner's collapse. [Official unit page](https://www.newvisions.org/curriculum/science/biology/marathon-runner)
- The public unit plan linked on that page is titled SY 26-27, but its text did not load. [Current unit plan](https://docs.google.com/document/d/1FHXcjyCGDh5am_OmrdS3XV_UQYpoioNzbwBkbNGuSzw/edit?tab=t.0)
- In SY25-26, gas exchange Explore 2 analyzes secondary blood O2/CO2 datasets; Muscles & Energy Explore 2 includes a glucose-regulation simulation using cups and chemicals; thermoregulation Explore collects human temperature data, followed by feedback diagrams. These are verified placements, not claims about unseen SY26-27 revisions. [Official SY25-26 teacher materials, pp.39,98,121](https://newvisions-uploads-production.s3.amazonaws.com/bio_U1/BIO%20%7C%20U1%20%7C%20Marathon%20Runner%20%7C%20Teacher%20Materials%20%7C%20SY%2025-26.pdf)
- The kidney investigation provides data for one person exercising three hours on different days with varying water intake and otherwise controlled conditions. Students examine blood solute concentration before/after the kidney and urine observations. It is a supplied-data investigation, not a student-operated kidney simulation. [Official SY25-26 student materials, p.135](https://newvisions-uploads-production.s3.amazonaws.com/bio_U1/BIO%20%7C%20U1%20%7C%20Marathon%20Runner%20%7C%20Student%20Materials%20%7C%20SY%2025-26.pdf)

### Inferences
- The opportunity is to turn hidden mechanisms and static comparisons into testable changes over time, while retaining the wet labs and supplied evidence.

### Gaps
- The complete teacher PDF exceeded web retrieval size; targeted indexed passages were accessible. Registration gates detailed links on the current unit page. Consequently, no exhaustive audit of all embedded digital simulations was possible, and claims that a particular digital tool is absent would be unjustified.

## Which simulations would add the most value?

### Takeaway
Build the kidney/body-to-cell bridge first if reusing the osmosis simulator is a priority. Glucose feedback is the best separate, tightly scoped next module. All designs below are proposals, not existing New Visions resources.

### Cited Findings
- The curricular anchors for the designs below are the four named Unit 1 sequences. [Official unit storyline](https://www.newvisions.org/curriculum/science/biology/marathon-runner)

### Inferences

#### 1. Body water balance → cell volume (highest leverage extension)
- Placement: after the kidney dataset activity in Water Balance, connecting students' onion-cell observations to the runner explanation.
- Question: How can water entering the body eventually change a cell's size?
- Controls: water intake events and activity/sweating setting; start with one control at a time. A later toggle compares regulated versus fixed water removal.
- See: one blood-water reservoir, a fixed/reference solute quantity or explicitly tracked solute amount, urine water leaving, and a linked animal cell shrinking/swelling as the blood concentration changes. Add a time graph of blood concentration and cell volume.
- Misconception targeted: the amount of solute and its concentration are the same; more water always returns the body toward normal; osmosis is disconnected from organ systems.
- MVP: two or three scripted hydration scenarios, one reservoir, one cell, pause/reset/graph. Reuse the existing cell renderer rather than add detailed kidney anatomy.
- Scientific limits: label it a qualitative model. Keep mass accounting explicit and do not equate urine formation with passive osmosis alone. A real kidney filters and selectively reabsorbs; hormone control, salt loss, and water excretion capacity cannot be inferred from a simple reservoir. If displaying hormone control, obtain a physiology review before presenting quantitative values. Distinguish the supplied data from simulated output.
- Middle-school access: low/normal/high concentration band, matched icon counts and reservoir volume, then optional numbers. Ask students to predict the cell before running the scenario.

#### 2. Blood glucose feedback laboratory (best compact standalone)
- Placement: Muscles & Energy, after the chemical cup investigation, linking its symbolic color change to a visible mechanism.
- Controls: add a meal, change activity demand, enable/disable an automatic feedback response; optional later comparison of insulin production and tissue response.
- See: glucose moving among a digestive input, blood, cells, and storage; a graph fluctuating around a normal band; feedback arrows activating and subsiding.
- Misconception targeted: homeostasis means a perfectly flat line; insulin simply destroys sugar; the controller runs at maximum all the time.
- MVP: meal button, activity slider, normal feedback toggle, one graph, and glucose-token accounting. Avoid detailed diabetes treatment or medication-dose mechanics.
- Added value: the curriculum already has a physical simulation. Build the biological transfer and dynamic graph, rather than an on-screen duplicate of colored cups.
- Middle-school access: three labeled compartments, familiar meal/exercise events, short run durations, graph axes with optional numerical detail.

#### 3. Exercise, gas exchange, and delivery
- Placement: Gas Exchange and Cellular Respiration Explore 2/Explain 2, beside the provided blood-gas evidence.
- Controls: exercise intensity first; a separate investigation allows breathing and circulation to respond automatically or stay at their baseline settings.
- See: O2 entering blood at lungs and reaching muscle cells, CO2 returning to lungs, cellular energy-use demand, and recovery after exercise stops.
- Misconception targeted: breathing and cellular respiration are identical; lungs make usable cellular energy; breathing faster is the entire explanation without circulation and cells.
- MVP: lungs → blood → muscle loop, two gas particle types, activity demand, automatic response toggle, and one graph. Avoid realistic hemoglobin chemistry and numeric clinical predictions.
- Scientific limits: do not reduce human respiratory feedback to a direct low-oxygen switch; represent the regulation as simplified and have CO2/waste accumulation participate in the explanatory loop. Keep gas concentration, transport rate, and saturation distinct if more than one appears.
- Middle-school access: follow a single highlighted molecule, pause at each compartment, show quantities with bars before interpreting the graph.

#### 4. Thermal balance under exercise (good, but second wave)
- Placement: Human Thermoregulation Explain/Elaborate after students' physical temperature investigation.
- Controls: activity and outside temperature; add humidity only after the basic system is understandable.
- See: heat generated, heat transferred out, evaporative loss, sweating response, and internal temperature versus time.
- Misconception targeted: sweating itself guarantees cooling; homeostasis prevents any change; external air temperature and internal temperature are the same.
- MVP: one body with incoming/outgoing heat arrows, two controls, one feedback toggle, one graph. Humidity is valuable because it creates a meaningful contrast between sweat present and evaporation effective.
- Scientific limits: qualitative educational model, not a prediction of safe exercise duration or medical risk.
- Middle-school access: heat arrows whose width reflects rate; students compare two saved runs with exactly one changed variable.

### Gaps
- These are proposed learning designs and qualitative scope judgments, not measured effectiveness results. They need classroom piloting and scientific review of any quantitative model.

## How should these be built for the intended learners?

### Takeaway
Keep the same investigation structure across modules: predict, change one variable, run, collect a small graph, explain with visible matter/energy movement. Make feedback and hidden processes visible rather than adding controls for their own sake.

### Cited Findings
- New Visions' unit emphasizes interacting organ systems and models explaining homeostasis; its listed performance expectations are HS-LS1-2, HS-LS1-3, HS-LS1-7. [Official unit overview](https://www.newvisions.org/curriculum/science/biology/marathon-runner)

### Inferences
- Use a default view with two or three controls, labels plus symbols rather than color alone, pause/reset, clear normal-range references, and optional vocabulary/detail layers.
- Provide side-by-side saved runs for evidence: what changed, what stayed constant, what happened, and why. Preserve normal fluctuations rather than force an exact target number.
- For the existing osmosis simulator, a body-level context panel is a smaller and more distinctive next step than rebuilding the cell. Keep plant-cell wall behavior separate from animal-cell behavior when transferring the lesson to the runner.
- Avoid one giant runner simulation initially: hidden coupled controls would obscure causal reasoning and expand scientific validation requirements. Build reusable modules and connect them after students understand each mechanism.

### Gaps
- The user's exact grade, class prior knowledge, device limits, and desired lesson length are not known. Recommendations assume middle-school readability while retaining the high-school curriculum's phenomenon.
