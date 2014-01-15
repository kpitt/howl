-- Copyright 2012-2013 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE.md)

import File from howl.fs
import Sandbox from howl.aux

find_file = (dir, base) ->
  for ext in *{'bc', 'lua', 'moon'}
    path = dir\join "#{base}.#{ext}"
    return path if path.exists

  error "Failed to find file '#{base}' in '#{dir}'"

load_file = (file, sandbox, ...) ->
  chunk = assert loadfile file
  sandbox chunk, ...

new = (dir, name, sandbox_options = {}) ->
  loaded = {}
  loading = {}
  box = Sandbox {}, sandbox_options

  box\put {
    "#{name}_file": (rel_path) -> dir / rel_path

    "#{name}_load": (rel_path, ...) ->
      rel_path = rel_path\gsub '%.', File.separator
      error 'Cyclic dependency in ' .. dir / rel_path if loading[rel_path]
      return loaded[rel_path] if loaded[rel_path]
      loading[rel_path] = true
      path = dir / rel_path
      path = find_file dir, rel_path unless path.exists
      mod = load_file path, box, ...
      loading[rel_path] = false
      loaded[rel_path] = mod
      mod
  }
  box

return new