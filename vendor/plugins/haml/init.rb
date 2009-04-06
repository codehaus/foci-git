################################################################################
#  Copyright (c) 2004-2009, by OpenXource, LLC. All rights reserved.
#
#  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF OPENXOURCE
#
#  The copyright notice above does not evidence any
#  actual or intended publication of such source code.
################################################################################
require 'rubygems'
begin
  require File.join(File.dirname(__FILE__), 'lib', 'haml') # From here
rescue LoadError
  require 'haml' # From gem
end

# Load Haml and Sass
Haml.init_rails(binding)
