local sources = {}

sources.completions = require("cmp_tidal.source-completions").new()
sources.samples = require("cmp_tidal.source-samples").new()

return sources
