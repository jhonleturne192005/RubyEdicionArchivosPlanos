#gem install gtk2

bff=nil
nombre_archivo=""
modificar_archivo_bandera=false

def leer_archivos(ruta)
    cadena=""
    file = File.open(ruta)
    file.readlines.each do |line|
      cadena.concat(line)
    end
    return cadena;
end


def escribir_archivo(nombre_archivo,data)
    File.open("#{nombre_archivo}.txt", 'w') do |file|
      file.write(data)
    end
end

def modificar_archivo(nombre_archivo,data)
    File.open("#{nombre_archivo}.txt", 'a') do |file|
      file.write(data)
    end 
end


def message(data)
      _message=Gtk::MessageDialog.new(
        parent  = nil,
        flags   =  0,
        type    = :info,
        buttons =:ok,
        message = data,
      )
      _message.run
      _message.destroy
end



#https://ruby-doc.org/core-2.6.3/File.html
#buscar en la pagina: File.basename
def obtener_nombre_archivo(ruta_absoluta)
  return File.basename(ruta_absoluta, ".*")   
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
  
  font_estilo_titulo = Pango::FontDescription.new('Sans Bold')
  font_estilo_titulo.set_size 24 * Pango::SCALE
  @label_titulo=Gtk::Label.new "EDICIÓN DE ARCHIVOS PLANOS"
  @label_titulo.override_font(font_estilo_titulo)
  fixed.put @label_titulo, 145, 10 
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
      nombre_archivo=obtener_nombre_archivo(a)
      @txtNombreArchivo.text=nombre_archivo
      modificar_archivo_bandera=true
      puts "nombre del archivo es: #{nombre_archivo}"
      puts leer_archivos(a) # ta imprimiendo en la consola
      iter = bff.get_iter_at(:offset => 0)
      bff.insert(iter, leer_archivos(a))
      dialog.destroy
      message("Archivo leido correctamente")
    elsif dialog.run == Gtk::ResponseType::CANCEL
      dialog.destroy
    end
    
    
  end
  fixed.put @btn_file, 20, 50 

  
  @label_nombre_archivo=Gtk::Label.new "Nombre archivo"
  fixed.put @label_nombre_archivo, 20, 90 
  
  
  @txtNombreArchivo=Gtk::Entry.new()
  fixed.put @txtNombreArchivo, 20, 110 


  @label_nombre_archivo=Gtk::Label.new "Contenido archivo"
  fixed.put @label_nombre_archivo, 20, 155


  #las entradas de texto se ingresan mediante buffer pero solo para TextView
  bff = Gtk::TextBuffer.new
  @txtEntrada=Gtk::TextView.new(buffer=bff)
  #bff.set_text("This is the beginning\n")
  @txtEntrada.set_size_request(300,200)
  fixed.put @txtEntrada, 20, 175
  

  @btn_guardar = Gtk::Button.new(:label => 'Guardar')
  @btn_guardar.signal_connect "clicked" do |widget|
    
    puts "ha presionado el boton de guardar datos"
    
    #el boolean es para añadir o no el texto invisible
    contenido_archivo=bff.get_text(bff.start_iter, bff.end_iter,true) 
    puts contenido_archivo
    nombre_archivo=@txtNombreArchivo.text
    puts nombre_archivo
    
    if modificar_archivo_bandera
      modificar_archivo(nombre_archivo,contenido_archivo)
      modificar_archivo_bandera=false
      message("Archivo modificado correctamente")
    else
      #escribe el archivo
      escribir_archivo(nombre_archivo,contenido_archivo)
      message("Archivo guardado correctamente")
    end
    
  end
  
  fixed.put @btn_guardar, 650, 525 
  
  window.show_all
end

status = app.run([$0] + ARGV)
puts status


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


