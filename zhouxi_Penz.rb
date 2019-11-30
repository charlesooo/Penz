# encoding: UTF-8
#-----------------------------------------------------------------------------
# Copyright 2019,Zhouxi

# WARRANTY:
#  THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#-----------------------------------------------------------------------------
# Name        :   Penz
# Description :   Paint all the edges
# Usage       :   "+/- Change the Color & [ / ] Change the speed
# Arthor      :   Zhouxi
# E-mail      :   zhou.xiii@qq.com
# Date        :   11/25/2019
#-----------------------------------------------------------------------------

# DEPENDANCIES:
require 'sketchup.rb'
require 'extensions.rb'

module Zhouxi
  module Penz

ext = SketchupExtension.new("Penz" , "zhouxi_Penz/Penz_Core.rb" )
ext.description="Paint all the edges"
ext.version = "0.1.0"
ext.creator = "Zhouxi"
ext.copyright = "© 2019,Zhouxi All Rights Reserved"
      # REGISTER THE EXTENSION WITH SKETCHUP:
Sketchup.register_extension ext,true

  end
end
