# INTEGRAL by Citrus

### A collection of helpful frameworks, functions, and extensions for glua along with adding support for my personal glua standard

**Class library** <br />
Use `Class:Create("ClassName")` to create a class. <br />
This functions similarly to classes in other languages and allows for flexible and useful object-oriented behavior. <br />

**Loader library** <br />
Use `SetLoaderRoot("Root")` or `GamemodeLoaderRoot(GM)` to set the loader's root. <br />
Then use `LoadLibrary("LibraryName")` to load the library relative to the loader's root automatically. <br />
See sh_loader.lua for more details. <br />

**Color library** <br />
Numerous global colors to reference for consistency between projects. <br />
Use `util.ColorCopy(source, dest, copyAlpha)` to copy the r, g, b, and optionally alpha from "source" to "dest" color. <br />
Use `util.CopyColor(col)` to return a new color object with the same r, g, b, and a as "col." <br />
Use `util.ColorModulate(col)` to return the r, g, b of col as three separate values. <br />
Use `util.ModulateColor(r, g, b)` to return a new color with respective r, g, b. <br />

**Emitter.Add() adjusted** <br />
Accepts a table as its third argument that will automatically adjust the particle created based on its values. <br />
See cl_emitter.lua for more details. <br />

**Player validation library** <br />
Use `IsValidPlayer(obj)` to check if obj is a valid player. <br />
Use `IsValidLivingPlayer(obj)` to check if obj is a valid living player. <br />

**Math library extension** <br />
Use `math.Remainder(num)` to return only the decimal part of a number. <br />

**Vector library extension** <br />
Use `VectorRandNorm()` to return a new normalized random vector. <br />

**Table library extension** <br />
Use `table.ToAssoc(tab)` to return a new table where all its keys are the values of the input table, and all the values are true. <br />
Use `table.IsAssoc(tab)` to return true if a table is "assoc" (all keys point to a value of true). <br />
Use `table.ToKeyValues(tab)` to return a new sequential table containing all the keys of the input table. <br />
Use `table.ForEach(tab, Callback)` to run Callback(k, v) on every k, v pair in tab. <br />
Use `table.Map(tab, Callback)` to return a new table containing all the key values from tab and their associated the return value from Callback(k, v). <br />
Use `table.MapSeq(tab, Callback)` to return a new sequential table containing all the return values from Callback(k, v) on every k, v pair in tab. <br />
Use `table.Filter(tab, Predicate)` to return a new table only containing the k, v pairs of which Predicate(k, v) returns true. <br />
Use `table.FilterSeq(tab, Predicate)` to return a new sequential table containing the values of which Predicate(k, v) returns true. <br />
Use `table.Mirror(tab)` to return a new table with the same k, v pairs. <br />
Use `table.IsIdentical(tab1, tab2)` to return if tab1 is functionally the same as tab2. <br />
Use `table.Distrubute(data)` to distrubute the workload of expensive operations over time. <br />

**Various minor performance improvements that shouldn't break many addons or gamemodes** <br />

**Personal glua standard support** <br />
Global functions added to match more consistent formatting, such as PascalStyleCasing function names. <br />
