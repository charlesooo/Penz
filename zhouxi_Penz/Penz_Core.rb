# encoding: UTF-8
#---------------------------------------------------------------------
# Copyright 2019,Zhouxi
#---------------------------------------------------------------------
#v0.1.0   @2019-11-24
module Zhouxi
  module Penz
    
class Penz

def enableVCB?
    false
end

def activate
    Sketchup.active_model.rendering_options["EdgeColorMode"] = 0
    @ip = Sketchup.active_model.active_view.inputpoint(0, 0)
    @n = 30 # 默认颜色变化幅度
    cursor_path = "E:/Ruby Project/penz.svg"
    @penz = UI.create_cursor(cursor_path, 0, 0)
end
    
def onSetCursor
  UI.set_cursor(@penz)
end

def deactivate(view)
    view.invalidate
end

def onKeyDown(key, repeat, flags, view)
    pp key
    mat = Sketchup.active_model.materials.current
    clr = mat.color if mat 
    n=@n
    case key
    when 187
        clr.red+n>255 ? clr.red=255 : clr.red+=n
        clr.green+n>255 ? clr.green=255 : clr.green+=n
        clr.blue+n>255 ? clr.blue=255 : clr.blue+=n
        mat.color = clr
    when 189
        clr.red-n<0 ? clr.red=0 : clr.red-=n
        clr.green-n<0 ? clr.green=0 : clr.green-=n
        clr.blue-n<0 ? clr.blue=0 : clr.blue-=n
        mat.color = clr
    when 219
        @n-=1 if @n>1
        Sketchup.status_text = "颜色变化幅度 = #{@n}"
    when 221
        @n+=1 if @n<51
        Sketchup.status_text = "颜色变化幅度 = #{@n}"
    end
end

def onMouseMove(flags, x, y, view)
    @ip = view.inputpoint(x, y)
    view.invalidate
    c_mat = Sketchup.active_model.materials.current
    if flags==1
      ph = view.pick_helper
      ph.do_pick(x,y)
      edge = ph.picked_edge
      edge.material = c_mat if edge != nil
    end
end

def redraw_edges(vtx,ents)
    edges = []
    edg0 = vtx.edges[0]
    if @ip.vertex.edges.count == 2 && edg0.line[1].parallel?(vtx.edges[1].line[1]) 
        edg0.all_connected.each{|e| 
        if e.is_a?Sketchup::Edge
            st = e.start.position
            ed = e.end.position
            vtp = vtx.position
            vct1 = st.vector_to(vtp)
            vct2 = ed.vector_to(vtp)
            if vct1!=[0,0,0] && vct2!=[0,0,0]
                edges << [st,ed,e.material] if vct1.parallel?(vct2)
            end
        end}
    vct = edg0.line[1]+[1,1,1]
    pt = vtx.position.offset(vct,1)
    ents.add_line(vtx.position,pt).erase!
    edges.each{ |e| ents.add_line(e[0],e[1]).material=e[2] }
    end
end

def onLButtonDoubleClick(flags, x, y, view) 
        pt =  @ip.transformation.invert! * @ip.position 
    if @ip.edge 
        @ip.edge.split(pt)
    end 
    if @ip.vertex
        if @ip.vertex.edges[0].parent.is_a?Sketchup::ComponentDefinition
            ents = @ip.vertex.edges[0].parent.instances[0].entities
        else
            ents = Sketchup.active_model.entities 
        end
        redraw_edges(@ip.vertex,ents)
    end
end

def draw(view)
    c = Sketchup.active_model.materials.current
    c == nil ? c='black' : c=c.color
    view.draw_points @ip.position, 6, 2, c if @ip
end

  #Toolbar
  toolbar = UI::Toolbar.new "Penz"
  cmd = UI::Command.new("Penz") { Sketchup.active_model.select_tool Penz.new } 
  cmd.small_icon = "icon.svg"
  cmd.large_icon = "icon.svg"
  cmd.status_bar_text = ("+/- Change the Color\n[ / ] Change the speed")
  cmd.tooltip = "Penz"
  toolbar = toolbar.add_item cmd
  toolbar.show
  
  #Menu
my_notice = UI::HtmlDialog.new(
    {
        :dialog_title => "WeChat Official Account",
        :scrollable => false,
        :resizable => false,
        :width => 180,
        :height => 240,
        :left => 85,
        :top => 100,
        :style => UI::HtmlDialog::STYLE_DIALOG
        })

notice = "
<!DOCTYPE html><html><head></head>
<body>
<img src='https://mmbiz.qpic.cn/mmbiz_png/SR6P0eHtonZOcEQT218U12XMCEGll94Ag5C3I0gRtXqWqMGFnm60icC7icYdJDzCN1sldJaFpqfFrrLrhicDhmlBw/0?wx_fmt=png' alt='<br>Zhou.xiii@qq.com' width=148 height=148>
<p style=font-size:10px;text-align:center>Copyright 2019,Zhouxi<br>All rights reserved</p>
</body>
</html>"

my_menu = UI.menu('Plugins')
my_menu.add_item("Catching Up with Penz") {
   my_notice.set_html(notice)
   my_notice.show
   }

end # class
    
  end
end
