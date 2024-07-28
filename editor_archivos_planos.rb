#gem install gtk3
require 'gtk3'

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

def escribir_archivo(nombre_archivo,data,ruta)
  puts "escrutra"
    puts "#{ruta+"/"+nombre_archivo}.txt"
    File.open("#{ruta+"/"+nombre_archivo}.txt", 'w') do |file|
      file.write(data)
    end
end

def modificar_archivo(nombre_archivo,data,ruta)
    File.open("#{ruta+"/"+nombre_archivo}.txt", 'a') do |file|
      file.write(data)
    end 
end

def directorio_existente(ruta)
    return File.file?(ruta)
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

def obtener_nombre_archivo(ruta_absoluta)
  return File.basename(ruta_absoluta, ".*")   
end

def limpiar(control_nombre_archivo,bff)
  control_nombre_archivo.text=""
  bff.set_text("")
end

def directorio_open_file_dialog(tipo="text/plain")
  
  if (tipo=="text/plain")
    dialog= Gtk::FileChooserDialog.new(
    :title => "Seleccionar archivo",
    :parent => nil,
    :action =>  Gtk::FileChooserAction::OPEN,
    :buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT],
                [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])
    
    filter=Gtk::FileFilter.new
    filter.add_pattern("*.txt")
    filter.set_name("Text Files (*.txt)")
    dialog.add_filter(filter)
    return dialog
  end

  return Gtk::FileChooserDialog.new(
    :title => "Seleccionar archivo",
    :parent => nil, 
    :action => tipo,
    :buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT],
                [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])
end

app = Gtk::Application.new("org.gtk.example", :flags_none)

app.signal_connect "activate" do |application|

  window = Gtk::ApplicationWindow.new(application)
  window.set_title("EDICION DE UN ARCHIVO DE TEXTO PLANO")
  window.set_default_size(800, 600)
  window.set_border_width(10)
  window.set_resizable(false)
  
  color=Gdk::RGBA.new
  color.parse('#90CAF9')
  
  window.override_background_color(0,color)

  fixed=Gtk::Fixed.new
  window.add(fixed)
  
  font_estilo_titulo = Pango::FontDescription.new('Sans Bold')
  font_estilo_titulo.set_size 24 * Pango::SCALE
  @label_titulo=Gtk::Label.new "EDICIÓN DE ARCHIVOS PLANOS"
  @label_titulo.override_font(font_estilo_titulo)
  fixed.put @label_titulo, 145, -1 

  @btn_file = Gtk::Button.new(:label => 'Seleccionar archivo')
  @btn_file.signal_connect "clicked" do |widget|
    
    dialog = directorio_open_file_dialog()
    
    if dialog.run == Gtk::ResponseType::ACCEPT
      limpiar(@txtNombreArchivo,bff)
      a=dialog.filename
      nombre_archivo=obtener_nombre_archivo(a)
      @txtNombreArchivo.text=nombre_archivo
      modificar_archivo_bandera=true
      iter = bff.get_iter_at(:offset => 0)
      bff.insert(iter, leer_archivos(a))
      dialog.destroy
      message("Archivo leido correctamente")
    elsif dialog.run == Gtk::ResponseType::CANCEL
      dialog.destroy
    end
  end
  fixed.put @btn_file, 625, 110
  

  @label_nombre_archivo=Gtk::Label.new "Nombre archivo"
  fixed.put @label_nombre_archivo, 20, 90 
  
  @txtNombreArchivo=Gtk::Entry.new()
  @txtNombreArchivo.set_size_request(300,20)
  fixed.put @txtNombreArchivo, 20, 110 

  @label_nombre_archivo=Gtk::Label.new "Contenido archivo"
  fixed.put @label_nombre_archivo, 20, 155

  bff = Gtk::TextBuffer.new
  @txtEntrada=Gtk::TextView.new(buffer=bff)
 
  scroll=Gtk::ScrolledWindow.new
  scroll.set_policy(Gtk::PolicyType::ALWAYS, Gtk::PolicyType::ALWAYS)
  scroll.add(@txtEntrada)
  scroll.set_size_request(740,325)
  fixed.put scroll, 20, 175
  
  @btn_guardar = Gtk::Button.new(:label => 'Guardar')
  @btn_guardar.signal_connect "clicked" do |widget|

    contenido_archivo=bff.get_text(bff.start_iter, bff.end_iter,true) 
    puts contenido_archivo
    nombre_archivo=@txtNombreArchivo.text
    puts nombre_archivo
    
    if nombre_archivo.strip!="" && contenido_archivo.strip!=""
      dialog = directorio_open_file_dialog(Gtk::FileChooserAction::SELECT_FOLDER)
      if dialog.run == Gtk::ResponseType::ACCEPT
        ruta=dialog.filename
        if modificar_archivo_bandera
          modificar_archivo(nombre_archivo,contenido_archivo,ruta)
          modificar_archivo_bandera=false
          message("Archivo modificado correctamente")
          limpiar(@txtNombreArchivo,bff)
        else
          if !directorio_existente("#{ruta+nombre_archivo}.txt")
              escribir_archivo(nombre_archivo,contenido_archivo,ruta)
              message("Archivo guardado correctamente")
              limpiar(@txtNombreArchivo,bff)
          else
            message("Error ya existe un archivo con ese nombre por favor escriba un nuevo nombre de archivo")
          end
        end
        dialog.destroy
      elsif dialog.run == Gtk::ResponseType::CANCEL
        dialog.destroy
      end

    else
      message("Error el contenido del archivo o nombre estan vacios")
    end
  
  end
  
  fixed.put @btn_guardar, 675, 525 
  window.show_all
end

status = app.run([$0] + ARGV)
puts status