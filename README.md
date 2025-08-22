# 🖥️ Pandas Color Printer & CamoufoxDf

## `pip install pandascamoufox`

This project provides:

- **`CamoufoxDf` wrapper**: Extract DOM elements from a [Camoufox](https://github.com/daijro/camoufox) browser session into a Pandas DataFrame, including both element attributes and bound methods for direct interaction (e.g., click, hover, type).

---

## ✨ Features

- Use `CamoufoxDf` to fetch DOM elements into a `DataFrame` with:
  - All element attributes (id, classes, styles, geometry, dataset, etc.)
  - Pre-bound executable methods (`click`, `hover`, `type`, `screenshot`, etc.)

---

## ⚠️ Important Notes

- ❌ **Does not work inside IPython or Jupyter Notebook**
  This is due to **async conflicts** between IPython and Camoufox (Playwright).
  Attempting to run inside IPython will result in event-loop errors.

- ✅ **Recommended Environment**
  To use this effectively, run it inside:
  - [VTM Terminal](https://github.com/directvt/vtm) — for advanced terminal rendering
  - [ptpython](https://github.com/prompt-toolkit/ptpython) — for an enhanced interactive REPL

---

## 🚀 Usage

```py
from pandascamoufox import CamoufoxDf
from camoufox.utils import DefaultAddons

cfox = CamoufoxDf(
    humanize=False,
    headless=False,
        **{"exclude_addons": [DefaultAddons.UBO]}
)

cfox.page.goto("https://bet365.com")
df = cfox.get_df("*")
print(df)
```


