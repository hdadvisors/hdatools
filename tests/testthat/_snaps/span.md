# span helpers error on unknown color name

    Code
      hda_span("x", "Magenta")
    Condition
      Error:
      ! "Magenta" is not a valid HDA color name. Valid names: Blue, Green, Yellow, Coral, Lavender, Sea Green.

---

    Code
      hfv_span("x", "Neon")
    Condition
      Error:
      ! "Neon" is not a valid HFV color name. Valid names: Shadow, Sky, Lilac, Grass, Berry, Desert, Leaf, Cerulean.

---

    Code
      pha_span("x", "Gold")
    Condition
      Error:
      ! "Gold" is not a valid PHA color name. Valid names: Green, Light Blue, Orange, Red, Purple, Dark Blue.

---

    Code
      vha_span("x", "Magenta")
    Condition
      Error:
      ! "Magenta" is not a valid VHA color name. Valid names: Dark Turq, Light Green, Yellow, Light Turq, Grey, Light Blue.

