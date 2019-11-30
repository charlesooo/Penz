# encoding: UTF-8
#---------------------------------------------------------------------
# Copyright 2019,Zhouxi
#---------------------------------------------------------------------
#v0.1.0   @2019-11-24
module Zhouxi
  module Penz
    class Penz

def update_html
    
html_New = "
<!DOCTYPE html>
<html><head><meta charset=utf-8></head>
<style type=text/css>
table.idz {
    font-family: verdana,arial,sans-serif;
    font-size:12px;
    border-collapse:collapse;
    width:100%;
    user-select: none
}
table.idz td.c {
    width:35%;
    text-align: center;
    border:1px solid black;
}
table.idz td.u {
    width:20%;
    height:20px;
    text-align: right;
    padding-right:10px;
    border:1px solid black;
}
</style>
<body>
<script>
function chang_color() 
{
  var h = Number(document.getElementById('h').value)/360;
  var s = Number(document.getElementById('s').value);
  var l = Number(document.getElementById('l').value);
  if(s == 0) {r=g=b=Math.round(l*255);} 
  else {
    function hsl2rgb(p, q, t) {
      if(t<0) t+= 1;
      if(t>1) t-= 1;
      if(t<1/6) return p+(q-p)*6*t;
      if(t<1/2) return q;
      if(t<2/3) return p+(q-p)*(2/3-t)*6;
      return p;
    }
    var q = l<0.5 ? l*(1+s) : l+s-l*s;
    var p = 2*l-q;
    r = Math.round(hsl2rgb(p, q, h+1/3) * 255);
    g = Math.round(hsl2rgb(p, q, h) * 255);
    b = Math.round(hsl2rgb(p, q, h-1/3) * 255);
  }
  var xx= 'background-color:rgb('+[r,g,b]+')';
  document.getElementById('color').style = xx;
}

function sendData() {sketchup.getData(event.currentTarget.id)}

function newColor() {sketchup.newColor(event.currentTarget.style.backgroundColor)}
</script>

<table class=idz>
<tr>
<td>H</td>
<td><input type=range id=h min=0 max=360 step=1 value=180 onchange =chang_color()></td>
<td class=c rowspan=3 id=color style='background-color:rgb(#{rand(55)+200},#{rand(55)+200},#{rand(55)+200})'; onclick=newColor() >New</td>
</tr>
<tr>
<td>S</td>
<td><input type=range id=s min=0 max=1 step=0.01 value=0.5 onchange =chang_color()></td>
</tr>
<tr>
<td>L</td>
<td><input type=range id=l min=0 max=1 step=0.01 value=0.5 onchange =chang_color()></td>
</tr>
</table>
"

@on_edge = []
num = 0
Sketchup.active_model.materials.each{ |m| @on_edge << m if m.name =~ /OnEdge/}
@on_edge.sort_by!{ |m| m.color.to_i}

html_Panel = "<br><table class=idz>"
@on_edge.each{ |m| 
c = m.color.to_a
c = "(#{c[0]},#{c[1]},#{c[2]})"
num += 1
html_Panel += "
<tr><td class=u id=#{num} style ='background-color:rgb#{c}' onclick=sendData() >#{num}</td></tr>
"
}
html_Panel +="</table></body></html>"
html_New += html_Panel
end

def initial_dialog
    html = update_html
    @dialog = UI::HtmlDialog.new({
        :dialog_title => "Color Panel",
        :scrollable => false,
        :resizable => false,
        :width => 300,
        :height => 160+23*@on_edge.count,
        :left => 85,
        :top => 100,
        :style => UI::HtmlDialog::STYLE_DIALOG
    })
    @dialog.add_action_callback("getData"){|action_context,data|
    begin
        num = data.to_i - 1
        Sketchup.active_model.materials.current=@on_edge[num]
        update_dialog
    rescue
        update_dialog
    end
    }
    @dialog.add_action_callback("newColor"){|action_context,data|
    begin
        n = data.scan(/\d+/)
        new = Sketchup.active_model.materials.add('OnEdge')
        new.color = Sketchup::Color.new(n[0].to_i,n[1].to_i,n[2].to_i)
        Sketchup.active_model.materials.current = new
        update_dialog
    rescue
        update_dialog
    end
    }
    @dialog.set_html(html)
    @dialog.show if !@dialog.visible?
end

def update_dialog
    html = update_html
    if @dialog
        @dialog.set_html(html)
        @dialog.set_size(300, 160+23*@on_edge.count)
        @dialog.show if !@dialog.visible?
        dummy = UI::HtmlDialog.new({:width => 1,:height => 1,:style => UI::HtmlDialog::STYLE_UTILITY})
        dummy.show
        dummy.close
    else
        initial_dialog
    end
end

#----------------------Color panel above---Penz below-----------------

def initialize
    Sketchup.active_model.rendering_options["EdgeColorMode"] = 0
    path = Sketchup.find_support_file("penz.svg", "Plugins/zhouxi_Penz")
    @penz = UI.create_cursor(path, 0, 0)
    @n = 30 # 默认颜色变化幅度
    initial_dialog
end
    
def enableVCB?
    false
end

def activate
    Sketchup.active_model.rendering_options["EdgeColorMode"] = 0
    @ip = Sketchup.active_model.active_view.inputpoint(0, 0)
    update_dialog
end
    
def onSetCursor
  UI.set_cursor(@penz) if @penz
end

def deactivate(view)
    @dialog.close if @dialog
    view.invalidate
end

def onKeyDown(key, repeat, flags, view)
    mat = Sketchup.active_model.materials.current
    clr = mat.color if mat 
    n=@n
    case key
    when 187
        clr.red+n>255 ? clr.red=255 : clr.red+=n
        clr.green+n>255 ? clr.green=255 : clr.green+=n
        clr.blue+n>255 ? clr.blue=255 : clr.blue+=n
        mat.color = clr
        update_dialog
    when 189
        clr.red-n<0 ? clr.red=0 : clr.red-=n
        clr.green-n<0 ? clr.green=0 : clr.green-=n
        clr.blue-n<0 ? clr.blue=0 : clr.blue-=n
        mat.color = clr
        update_dialog
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
   
    #-------------------------------------Toolbar-----------------------
    toolbar = UI::Toolbar.new "Penz"
    cmd = UI::Command.new("Penz") { Sketchup.active_model.select_tool Penz.new } 
    cmd.small_icon = "icon.svg"
    cmd.large_icon = "icon.svg"
    cmd.status_bar_text = ("+/- Change the Color\n[ / ] Change the speed")
    cmd.tooltip = "Penz"
    toolbar = toolbar.add_item cmd
    toolbar.show
  
    #-------------------------------------Menu--------------------------
    my_notice = UI::HtmlDialog.new({
    :dialog_title => "CatchingUp",
    :scrollable => false,
    :resizable => false,
    :width => 180,
    :height => 250,
    :left => 85,
    :top => 100,
    :style => UI::HtmlDialog::STYLE_DIALOG
        })
  path = Sketchup.find_support_file("QRcode.png", "Plugins/zhouxi_Penz")
  notice = "
<!DOCTYPE html><html><head></head>
<body>
<p><a href='https://catchingup.lofter.com' target='_blank' >
<img src='#{path}' alt='Zhou.xiii@qq.com' width=148 height=148></a></p>
<p style=font-size:10px;text-align:center>Copyright 2019,Zhouxi<br>All rights reserved</p>
</body>
</html>"
  my_notice.set_html(notice)
  my_notice.show if rand(9)==0
  my_menu = UI.menu('Plugins')
  my_menu.add_item("Catching Up with Penz") {my_notice.show}
   
    end # class
  end
end
