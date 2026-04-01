meson setup builddir-thorvg --wipe -Dthorvg_subproject=thorvg -Dthreads=true
meson compile -C builddir-thorvg

meson setup builddir-thorvg-nonthread --wipe -Dthorvg_subproject=thorvg -Dthreads=false
meson compile -C builddir-thorvg-nonthread


meson setup builddir-thorvg-main  --wipe -Dthorvg_subproject=thorvg-main -Dthreads=true
meson compile -C builddir-thorvg-main

meson setup builddir-thorvg-main-nonthread --wipe -Dthorvg_subproject=thorvg-main -Dthreads=false
meson compile -C builddir-thorvg-main-nonthread
