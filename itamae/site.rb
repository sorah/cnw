node[:basedir] = File.expand_path('..', __FILE__)
node[:secrets] = MitamaeSecrets::Store.new(File.join(node[:basedir],'secrets'))

include_recipe './vars.rb'
include_recipe './site/functions.rb'
include_recipe './site/mitamae_ext.rb'

