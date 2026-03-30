project('thorvg.example',
  'cpp',
  version: '1.0',
  default_options: ['buildtype=debugoptimized', 'cpp_std=c++14', 'optimization=3',  'b_sanitize=none'],
  license : 'MIT')

fs = import('fs')
example_dir = meson.current_source_dir()
if host_machine.system() == 'windows'
  example_dir = example_dir.replace('\\', '/')
endif
add_project_arguments('-DEXAMPLE_DIR="@0@/res"'.format(example_dir), language : 'cpp')

thorvg_proj = subproject('thorvg', default_options: [
  # 'buildtype=debug',
  # 'optimization=0',
  'engines=sw,gl,wg',
  'loaders=all',
  'savers=all',
  'bindings=capi',
  'extra=lottie_exp',
  'b_sanitize=none',
#  'threads=false'
  # 'log=true'
])
thorvg_dep = thorvg_proj.get_variable('thorvg_dep')

subdir('src')