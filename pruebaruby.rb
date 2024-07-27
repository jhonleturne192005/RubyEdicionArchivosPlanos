#gem install gtk2

bff=nil

def leer_archivos(ruta)
    cadena=""
    file = File.open(ruta)
    file.readlines.each do |line|
      cadena.concat(line)
    end
    return cadena;
end


require 'gtk3'

app = Gtk::Application.new("org.gtk.example", :flags_none)

app.signal_connect "activate" do |application|
 # create a new window, and set its title
  window = Gtk::ApplicationWindow.new(application)
  window.set_title("EDICION DE UN ARCHIVO DE TEXTO PLANO")
  window.set_default_size(800, 600)
  window.set_border_width(10)

  color=Gdk::RGBA.new
  color.parse('#67BB6A')
  
  window.override_background_color(0,color)

  fixed=Gtk::Fixed.new
  window.add(fixed)
  
  #fixed.put txtEntrada, x,y 

  @btn_file = Gtk::Button.new(:label => 'Seleccionar archivo')
  @btn_file.signal_connect "clicked" do |widget|
    puts "Hello World"
    dialog = Gtk::FileChooserDialog.new(
    :title => "Seleccionar archivo",
    :parent => nil, 
    :content_type => "text/plain",
    :buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT],
                [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])
    
    if dialog.run == Gtk::ResponseType::ACCEPT
      a=dialog.filename
      puts leer_archivos(a)
      iter = bff.get_iter_at(:offset => 0)
      bff.insert(iter, leer_archivos(a))
      #@txtEntrada.set_text(leer_archivos(a))
      #_message=Gtk::MessageDialog.new(
      #  parent  = nil,
      #  flags   =  0,
      #  type    = :info,
      #  buttons =:ok,
      #  message = a,
      #)
      #_message.run
      #_message.destroy
      dialog.destroy
    elsif dialog.run == Gtk::ResponseType::CANCEL
      dialog.destroy
    end
    
    
  end
  fixed.put @btn_file, 20, 40 

  
  bff = Gtk::TextBuffer.new
  @txtEntrada=Gtk::TextView.new(buffer=bff)
  bff.set_text("This is the beginning\n")
  @txtEntrada.set_size_request(300,200)
  fixed.put @txtEntrada, 20, 80 
  

  window.show_all
end

status = app.run([$0] + ARGV)
puts status


