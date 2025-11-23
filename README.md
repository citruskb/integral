# INTEGRAL by Citrus

### A collection of helpful frameworks, functions, and extensions for glua along with adding support for my personal glua standard

**Class library**
Use `Class:Create("ClassName")` to create a class.
This functions similarly to classes in other languages and allows for flexible and useful object-oriented behavior.

**Loader library**
Use `SetLoaderRoot("Root")` or `GamemodeLoaderRoot(GM)` to set the loader's root.
Then use `LoadLibrary("LibraryName")` to load the library relative to the loader's root automatically.
See sh_loader.lua for more details.

**Color library**
Numerous global colors to reference for consistency between projects.
Use `util.ColorCopy(source, dest, copyAlpha)` to copy the r, g, b, and optionally alpha from "source" to "dest" color.
Use `util.CopyColor(col)` to return a new color object with the same r, g, b, and a as "col."
Use `util.ColorModulate(col)` to return the r, g, b of col as three separate values.
Use `util.ModulateColor(r, g, b)` to return a new color with respective r, g, b.

**Emitter.Add() adjusted**
Accepts a table as its third argument that will automatically adjust the particle created based on its values.
See cl_emitter.lua for more details.

**Player validation library**
Use `IsValidPlayer(obj)` to check if obj is a valid player.
Use `IsValidLivingPlayer(obj)` to check if obj is a valid living player.

**Math library extension**
Use `math.Remainder(num)` to return only the decimal part of a number.

**Vector library extension**
Use `VectorRandNorm()` to return a new normalized random vector.

**Table library extension**
Use `table.ToAssoc(tab)` to return a new table where all its keys are the values of the input table, and all the values are true.
Use `table.IsAssoc(tab)` to return true if a table is "assoc" (all keys point to a value of true).
Use `table.ToKeyValues(tab)` to return a new sequential table containing all the keys of the input table.
Use `table.ForEach(tab, Callback)` to run Callback(k, v) on every k, v pair in tab.
Use `table.Map(tab, Callback)` to return a new table containing all the key values from tab and their associated the return value from Callback(k, v).
Use `table.MapSeq(tab, Callback)` to return a new sequential table containing all the return values from Callback(k, v) on every k, v pair in tab.
Use `table.Filter(tab, Predicate)` to return a new table only containing the k, v pairs of which Predicate(k, v) returns true.
Use `table.FilterSeq(tab, Predicate)` to return a new sequential table containing the values of which Predicate(k, v) returns true.
Use `table.Mirror(tab)` to return a new table with the same k, v pairs.
Use `table.IsIdentical(tab1, tab2)` to return if tab1 is functionally the same as tab2.
Use `table.Distrubute(data)` to distrubute the workload of expensive operations over time.

**Various minor performance improvements that shouldn't break many addons or gamemodes**

**Personal glua standard support**
Global functions added to match more consistent formatting, such as PascalStyleCasing function names.
