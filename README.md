# vim-ripgrep

    :Rg <string|pattern>

Word under cursor will be searched if no argument is passed to `Rg`

## configuration


| Setting              | Default                   | Details
| ---------------------|---------------------------|----------
| g:rg_binary          | rg                        | path to rg
| g:rg_format          | %f:%l:%c:%m               | value of grepformat 
| g:rg_opts            | --vimgrep                 | options passed to rg
| g:rg_highlight       | false                     | true if you want matches highlighted
| g:rg_highlight_type  | 'Debug'                   | highlight group used to highlight query
| g:rg_derive_root     | false                     | true if you want to find project root from cwd
| g:rg_root_types      | ['.git']                  | list of files/dir found in project root
| g:rg_window_location | botright                  | quickfix window location
| g:rg_loclist         | 0                         | use location list instead of quickfix
    
## misc

Show root search dir

    :RgRoot
