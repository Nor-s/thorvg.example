project('thorvg.example',
  'cpp',
  version: '1.0',
  default_options: ['buildtype=release', 'cpp_std=c++14', 'optimization=s',  'b_sanitize=none', 'default_library=static'],
  license : 'MIT')


fs = import('fs')
example_dir = meson.current_source_dir()
if host_machine.system() == 'windows'
  example_dir = example_dir.replace('\\', '/')
endif
add_project_arguments('-DEXAMPLE_DIR="@0@/res"'.format(example_dir), language : 'cpp')

# Get options
threads_opt = get_option('threads')
thorvg_subproject = get_option('thorvg_subproject')

thorvg_proj = subproject(thorvg_subproject, default_options: [
  'buildtype=release',
  'optimization=s',
  'engines=sw,gl',
  'loaders=all',
  'savers=all',
  'bindings=capi',
  'extra=lottie_exp,openmp',
  'b_sanitize=none',
  'threads=' + (threads_opt ? 'true' : 'false'),
  'default_library=static'
  # 'log=true'
])
thorvg_dep = thorvg_proj.get_variable('thorvg_dep')

subdir('src')