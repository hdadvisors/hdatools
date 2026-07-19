# focus palette errors on invalid color name

    Code
      hda_focus_pal("Magenta", n = 3)
    Condition
      Error:
      ! "Magenta" is not a valid HDA color name. Valid names: Blue, Green, Yellow, Coral, Lavender, Sea Green.

---

    Code
      hfv_focus_pal("Neon", n = 3)
    Condition
      Error:
      ! "Neon" is not a valid HFV color name. Valid names: Shadow, Sky, Lilac, Grass, Berry, Desert, Leaf, Cerulean.

---

    Code
      pha_focus_pal("Gold", n = 3)
    Condition
      Error:
      ! "Gold" is not a valid PHA color name. Valid names: Green, Light Blue, Orange, Red, Purple, Dark Blue.

---

    Code
      vha_focus_pal("Magenta", n = 3)
    Condition
      Error:
      ! "Magenta" is not a valid VHA color name. Valid names: Dark Turq, Light Green, Yellow, Light Turq, Grey, Light Blue.

# focus palette errors on invalid n

    Code
      hda_focus_pal("Blue", n = 0)
    Condition
      Error:
      ! `n` must be a positive integer.

---

    Code
      hda_focus_pal("Blue", n = -1)
    Condition
      Error:
      ! `n` must be a positive integer.

---

    Code
      hda_focus_pal("Blue", n = "two")
    Condition
      Error:
      ! `n` must be a positive integer.

