task :git_submodules do
  system 'git submodule init 2>&1'
  system 'git submodule update 2>&1'
end