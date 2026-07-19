# Ramp Lab review — six winning ramps, tuned and verified

**Date:** 2026-07-18 · **Reviewer:** Claude (subscription review session) · **Status:** **signed off 2026-07-18** (see `plans/DECISIONS.md`, rows dated 2026-07-18/ref 2.2 + brand): six picks adopted; Leaf + Cerulean join the HFV palette; protan diverging caveat accepted with a documented legend rule; Berry accent rejected for now; **HDA diverging is provisional** pending a follow-up lab pass to differentiate it from PHA's (teal-forward cool arm) before adoption.

One winner per slot (3 brands × sequential/diverging), judged across every
dashboard preview (smooth, binned 7-class, choropleth map, bar, line/area,
diverging-bar) under normal vision plus protanopia, deuteranopia, and
tritanopia. Every pick was slider-tuned (or deliberately left at defaults
after tuning was explored and rejected on evidence), recorded in-dashboard
via "Pick as winner" with a note, and its "Copy R snippet" output verified
against real `colorspace` via Rscript.

**⚠ localStorage caveat:** the in-dashboard picks/notes/slider overrides live
in the *review browser's* localStorage (`hdatools-ramp-lab-v1`), which your
own browser will not see when you open `dashboard.html`. This file is the
durable record — the picks JSON at the bottom can be pasted into DevTools
(`localStorage.setItem('hdatools-ramp-lab-v1', JSON.stringify(<that object>))`)
to reproduce the exact dashboard state.

**Method note:** the review environment's browser pane renders the dashboard
at thumbnail resolution, unusable for judging color. All visual passes
therefore ran on an offline replica of the dashboard's previews (exact ports
of its HCL math, Machado-2009 CVD matrices, seeded synthetic dataset, and
layouts), validated against `candidates.js`: all 36 candidates' **7-class
binned output matches real colorspace exactly**. The dashboard itself was
still the system of record — final values were entered through its sliders,
picks/notes recorded there, and R snippets copied from it. Separation numbers
below are CIE76 ΔE between adjacent binned classes (sequential) or mirrored
cross-arm classes (diverging), after Machado full-severity CVD simulation.
For a 7-class ramp, adjacent ΔE ≥ 12 is comfortable, 8–12 usable with a
legend, < 8 a real merge risk.

---

## HDA sequential — **Blue → cream (standard), tuned**

- **Base:** `hda-seq-blue-cream-standard` (generated candidate 1 of 6).
- **Final sliders:** hue (dark) 259.2 · chroma (dark) **64** (was 60) ·
  lum (dark) 26 · cream 80 / 10 / 95 · power **0.85** (was 1.00).
- **R snippet (verified: R output within 1/255 of dashboard hex):**

  ```r
  colorspace::sequential_hcl(
    n = 7,
    h = c(259.2, 80.0),
    c = c(64.0, 10.0),
    l = c(26.0, 95.0),
    power = 0.85
  )
  # R: #0A388A #006087 #007D84 #359784 #81B090 #BCCBAE #F3F1E4
  ```

- **Rationale.** The navy → teal → sage → cream path is the most editorial
  thing in the slot — multi-hue like YlGnBu/NYT ramps, not a stock
  single-blue gradient. As generated it hoarded separation at the dark end
  (first boundary ΔE 36, hue-driven) while the light classes ran thin
  (10.6–12.4 under protan/deutan). Power 0.85 shifts the class positions
  darker, redistributing that surplus: normal min ΔE 14.2 → 17.1, deutan
  11.7 → 13.1, and the pale classes keep more chroma (no chalky lights).
  Chroma 64 moves the dark end *closer* to the true brand Blue (source
  C = 67; the generator had nudged it down to 60) and deepens the navy tip.
  The wide-contrast variant was rejected for its electric ultramarine tip
  (#002696) — the one over-saturated note against otherwise muted neighbors.
  Coral was the runner-up (remarkably CVD-uniform) but the primary brand
  color should anchor the workhorse ramp. Checked under all three CVD modes.
- **Residual concerns.** Under tritanopia (very rare) classes 2–3 compress to
  ΔE ~9.7 — luminance still orders them. Mid-ramp reads teal rather than
  blue; that's the shared-cream system's signature, not a bug, but worth a
  human eye on brand fit.

## HDA diverging — **Blue vs Coral (standard), tuned**

- **Base:** `hda-div-blue-vs-coral-standard`.
- **Final sliders:** hue arm 1 259.2 · hue arm 2 20.4 · chroma **76**
  (was 70) · lum (arms) **26** (was 28) · cream center 80 / 10 / 95 ·
  power **0.90** (was 1.00).
- **R snippet (verified: exact match):**

  ```r
  n <- 7
  n2 <- ceiling(n / 2)
  arm <- function(h) colorspace::sequential_hcl(
    n2, h = c(h, 80.0), c = c(76.0, 10.0),
    l = c(26.0, 95.0), power = 0.90
  )
  diverging_hex <- c(arm(259.2), rev(arm(20.4)))
  if (floor(n / 2) < n2) diverging_hex <- diverging_hex[-n2]
  diverging_hex
  # R: #00369B #00828A #80B591 #F3F1E4 #BEA680 #9A6330 #781C00
  ```

- **Rationale.** The flagship brand pairing — navy/teal vs sienna/brick,
  classic cool-warm with balanced arms. The tune (deeper tips, +6 chroma,
  power 0.9) improved every cross-arm line: protan inner pair 5.5 → 6.7,
  deutan 11.5 → 12.7, tritan 31.9 → 37.5, with richer inner classes on the
  map. Blue vs Yellow rejected: its "yellow" arm is khaki-brown mud at dark
  luminances. Lavender vs Sea Green rejected outright: the plum arm passes
  through slate-blue mid-arm (three hue families on one arm — mid cells
  could belong to either side) and it had the weakest CVD tips. Checked
  under all three CVD modes.
- **Residual concerns.** The innermost pair (pale sage vs pale tan) merges
  under protanopia (ΔE ~6.7). This is *structural* to the shared-cream
  center — both inner classes are low-chroma yellowish tints, unlike RdBu
  whose cool arm stays blue to the end. Consequence: near-zero cells lose
  sign for protan viewers; keep legends/direct labels on 7-class diverging
  maps. Flagged as a system-level trade-off of the cream-center design.

## HFV sequential — **Leaf → cream (standard), kept at generated defaults**

- **Base:** `hfv-seq-leaf-experimental-hfv-secondary-cream-standard`
  (the experimental Leaf secondary, per the generator's anchor swap).
- **Final sliders:** hue 118.5 · chroma 65 · lum (dark) 28 · cream
  80 / 10 / 95 · power 1.00 — **unchanged, deliberately.**
- **R snippet (verified: exact match):**

  ```r
  colorspace::sequential_hcl(
    n = 7,
    h = c(118.5, 80.0),
    c = c(65.0, 10.0),
    l = c(28.0, 95.0),
    power = 1.00
  )
  # R: #005000 #3D6800 #678136 #8C9B64 #B0B68F #D2D3B9 #F3F1E4
  ```

- **Rationale.** Twelve slider variants were tested (hue toward emerald,
  chroma 70–75, power 0.85–0.95, l1/l2 moves): every one of them traded a
  CVD floor below the default. Dark saturated greens are gamut-clamped, so
  demanding more chroma or a greener hue eats the dark-end hue
  differentiation (e.g. hue+8° drops tritan classes 1–2 from 12.9 → 8.3;
  power 0.9 drops protan classes 2–3 from 11.9 → 9.8). The generated
  default has the most uniform profile in the slot (min ΔE
  13.2/11.9/12.6/11.1 across normal/prot/deut/trit) — a genuine local
  optimum, which is itself a finding from working the sliders. Green is
  also the right identity call: Shadow would twin HDA's pick mid-ramp
  (#267D7C vs #007D84 — near-identical teals). Checked under all three CVD
  modes.
- **Residual concerns.** Midtones lean olive/khaki (#8C9B64, #B0B68F) — the
  one aesthetic reservation; fixing it costs CVD floors, so it stays. Worth
  a human eye on whether the olive reads "organic" or "army surplus" in a
  real report. **Berry deserves a note:** its magenta → periwinkle → teal
  spiral is the most striking normal-vision ramp in the whole lab and has
  the best normal-vision separation (min 16.4), but its magenta–purple
  boundary collapses under deuteranopia (ΔE 8.9, structural — no in-cap fix
  found). Consider it a *special-purpose accent ramp* candidate, never the
  default.

## HFV diverging — **Leaf vs Berry (standard), tuned**

- **Base:** `hfv-div-leaf-experimental-hfv-secondary-vs-berry-standard`.
- **Final sliders:** hue arm 1 118.5 · hue arm 2 344.0 · chroma **68**
  (was 62) · lum (arms) **26** (was 28) · cream center 80 / 10 / 95 ·
  power **0.95** (was 1.00).
- **R snippet (verified: R output within 1/255 of dashboard hex):**

  ```r
  n <- 7
  n2 <- ceiling(n / 2)
  arm <- function(h) colorspace::sequential_hcl(
    n2, h = c(h, 80.0), c = c(68.0, 10.0),
    l = c(26.0, 95.0), power = 0.95
  )
  diverging_hex <- c(arm(118.5), rev(arm(344.0)))
  if (floor(n / 2) < n2) diverging_hex <- diverging_hex[-n2]
  diverging_hex
  # R: #004C00 #607B27 #ABB186 #F3F1E4 #7BB9A9 #5C71A7 #81004D
  ```

- **Rationale.** Green vs berry-wine (PiYG-family) gives HFV its own
  diverging axis instead of a third navy-vs-tan, ties to the Leaf
  sequential and the Berry brand color, and is by far the most CVD-uniform
  candidate in the slot: worst cross-arm ΔE anywhere is 14.5 as generated
  (16.5 after tuning), versus protan inner-pair collapses of 3.9 (Shadow vs
  Desert) and 1.9 (Cerulean vs Desert). The green-vs-purple axis keeps a
  blue-channel difference that survives red-green CVD — under deuteranopia
  it reads olive-vs-blue with sign fully legible. Tune: deeper forest/wine
  tips, richer arms; every line improved except a mild, still-comfortable
  drop in deutan tip distance (35.8 → 32.8). Checked under all three CVD
  modes.
- **Residual concerns.** The berry arm passes through periwinkle → seafoam
  near the center, so its inner positive class hue-rhymes with the green
  arm for normal-vision readers who key on "green vs pink" (ColorBrewer
  PiYG shares this property). Luminance order and a legend carry it, but a
  human eye should confirm the seafoam class doesn't confuse in a real
  choropleth.

## PHA sequential — **Red → cream (standard), tuned**

- **Base:** `pha-seq-red-cream-standard`.
- **Final sliders:** hue 19.7 · chroma **84** (was 90) · lum (dark) 28 ·
  cream 80 / 10 / 95 · power **0.95** (was 1.00).
- **R snippet (verified: exact match):**

  ```r
  colorspace::sequential_hcl(
    n = 7,
    h = c(19.7, 80.0),
    c = c(84.0, 10.0),
    l = c(28.0, 95.0),
    power = 0.95
  )
  # R: #811C00 #924500 #A36831 #B38A5A #C4AC84 #D8CEB2 #F3F1E4
  ```

- **Rationale.** Red completes a blue/green/red system across the three
  brands — Dark Blue would have been the system's third navy→teal ramp
  (visually a twin of HDA's pick), and Green is the slot's numerically
  weakest family (deutan dark end ΔE 9.0). The tune is the rare move that
  improves **every** floor simultaneously: deutan 11.9 → 12.6, normal
  14.0 → 14.8, protan 12.5 → 12.8, tritan 13.0 → 13.5 — dropping dark-end
  chroma to 84 gives deuteranopia more luminance to work with, and the
  eased curve feeds the thin light end. Also reads oxide-red/terracotta
  rather than fire-engine — restrained, Urban-Institute-warm. Checked under
  all three CVD modes.
- **Residual concerns.** None beyond the general cream-system notes; this is
  the most robust pick of the six.

## PHA diverging — **Dark Blue vs Red (standard), tuned**

- **Base:** `pha-div-dark-blue-vs-red-standard`.
- **Final sliders:** hue arm 1 243.4 · hue arm 2 19.7 · chroma **72**
  (was 65) · lum (arms) **26** (was 28) · cream center 80 / 10 / 95 ·
  power **0.90** (was 1.00).
- **R snippet (verified: exact match):**

  ```r
  n <- 7
  n2 <- ceiling(n / 2)
  arm <- function(h) colorspace::sequential_hcl(
    n2, h = c(h, 80.0), c = c(72.0, 10.0),
    l = c(26.0, 95.0), power = 0.90
  )
  diverging_hex <- c(arm(243.4), rev(arm(19.7)))
  if (floor(n / 2) < n2) diverging_hex <- diverging_hex[-n2]
  diverging_hex
  # R: #00468E #00827F #86B48F #F3F1E4 #BDA682 #996436 #761E00
  ```

- **Rationale.** PHA's two flagship civic colors, and it rhymes with the Red
  sequential pick. Same tuning treatment as the HDA diverging (deeper tips,
  more chroma, power 0.9), which keeps the two cool-warm divergings
  system-coherent; every cross-arm line improved (deutan inner 8.2 → 10.0,
  tritan 28.7 → 33.6). Purple vs Green was rejected outright — its
  normal-vision inner pair is ΔE 7.9 and its arm *tips* merge under
  tritanopia (ΔE 12); the purple arm passes through teal mid-arm. Dark Blue
  vs Orange is nearly identical to Blue-vs-Red but with a muddier brown
  tip. Checked under all three CVD modes.
- **Residual concerns.** Same protan inner-pair merge as HDA's diverging
  (ΔE ~4.5) — the shared-cream-center trade-off; legends/labels mitigate.

---

## Cross-brand coherence

The six picks read as one designed system. The shared cream light-end/center,
matched class rhythm (7 classes, L ≈ 26–28 → 95), and comparable chroma
ceilings make the family unmistakable; the hue identities (HDA navy-teal,
HFV leaf-green, PHA oxide-red) keep the brands unmistakably apart. The three
sequentials are the strongest expression of this — hang them side by side
and they look like one studio's work.

**The odd ones out are the two cool-warm divergings relative to *each
other*:** HDA (navy 259° vs coral 20°) and PHA (navy 243° vs red 20°) are
visual siblings — at a glance the same ramp. Within each brand's own
publications this is invisible, and cool-vs-warm is the genre convention
(every RdBu/RdYlBu user does this), but if HDA and PHA charts ever share a
page, their divergings won't differentiate the brands. No in-slot fix
exists: PHA's only structurally sound pair is Dark-Blue-vs-Red (Purple vs
Green fails outright). If differentiation matters, the lever is HDA's
diverging (e.g. swap toward a teal-forward cool arm) — a decision for
Jonathan, not this session.

## Things that need sign-off (not silently changed)

- **No new anchors proposed.** All six slots hit the bar with existing
  anchors. Berry is flagged (above) as a possible *additional*
  special-purpose accent ramp, not a swap.
- **The protan inner-pair merge on both cool-warm divergings** is a property
  of the shared cream center (the cool arm goes greenish near center, so
  both inner classes are yellowish tints under protanopia). Accepting it
  implies a documentation/usage rule (legend + labels on diverging
  choropleths). The alternative — a per-ramp cream or a cool-biased center
  — breaks the shared-cream system and needs a deliberate decision.

## Tool observations (no changes made)

- **Diverging smooth-preview mismatch (dashboard bug, minor):** for even n
  (the 32-stop smooth strip), the dashboard's `divergingHcl()` rvals bottom
  out at 1/31 instead of 0, so each arm never quite reaches cream — its
  smooth diverging gradients differ slightly from the real R construction
  near the center (up to ~11/255 per channel mid-arm). The 7-class binned
  output — everything the picks are based on — matches R exactly (verified
  across all 36 candidates). Worth a one-line fix in `divergingHcl()`
  whenever the tool is next touched.
- The review browser couldn't deliver click events to card buttons
  (coordinate-mapping issue in the automation pane), so pick/copy buttons
  were pressed by invoking the buttons' own click handlers; sliders, the
  CVD dropdown, and note fields were driven through normal form input.
  State was verified after every action and survives reload.

## Picks JSON (paste into localStorage to reproduce dashboard state)

Key: `hdatools-ramp-lab-v1`

```json
{
  "overrides": {
    "hda-seq-blue-cream-standard": {"h1": 259.2288, "c1": 64, "l1": 26, "l2": 95, "power": 0.85, "hc": 80, "cc": 10},
    "hda-div-blue-vs-coral-standard": {"h1": 259.2288, "h2": 20.415, "c1": 76, "l1": 26, "l2": 95, "power": 0.9, "hc": 80, "cc": 10},
    "hfv-div-leaf-experimental-hfv-secondary-vs-berry-standard": {"h1": 118.4931, "h2": 343.9945, "c1": 68, "l1": 26, "l2": 95, "power": 0.95, "hc": 80, "cc": 10},
    "pha-seq-red-cream-standard": {"h1": 19.6527, "c1": 84, "l1": 28, "l2": 95, "power": 0.95, "hc": 80, "cc": 10},
    "pha-div-dark-blue-vs-red-standard": {"h1": 243.4067, "h2": 19.6527, "c1": 72, "l1": 26, "l2": 95, "power": 0.9, "hc": 80, "cc": 10}
  },
  "picks": {
    "hda:sequential": {"id": "hda-seq-blue-cream-standard", "note": "PICK (Claude review): Blue std base, chroma 60->64, power 1->0.85. See REVIEW.md."},
    "hda:diverging": {"id": "hda-div-blue-vs-coral-standard", "note": "PICK (Claude review): Blue vs Coral std, chroma 70->76, l1 28->26, power 1->0.9. See REVIEW.md."},
    "hfv:sequential": {"id": "hfv-seq-leaf-experimental-hfv-secondary-cream-standard", "note": "PICK (Claude review): Leaf std at generated defaults (tuning explored and rejected on CVD evidence). See REVIEW.md."},
    "hfv:diverging": {"id": "hfv-div-leaf-experimental-hfv-secondary-vs-berry-standard", "note": "PICK (Claude review): Leaf vs Berry std, chroma 62->68, l1 28->26, power 1->0.95. See REVIEW.md."},
    "pha:sequential": {"id": "pha-seq-red-cream-standard", "note": "PICK (Claude review): Red std, chroma 90->84, power 1->0.95. See REVIEW.md."},
    "pha:diverging": {"id": "pha-div-dark-blue-vs-red-standard", "note": "PICK (Claude review): Dark Blue vs Red std, chroma 65->72, l1 28->26, power 1->0.9. See REVIEW.md."}
  },
  "notes": {}
}
```

(The in-dashboard notes as actually recorded are longer; the full text lives
in the per-slot sections above.)
