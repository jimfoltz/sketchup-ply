module CommunityExtensions
  module PLY
    module Exporter

      PREF_KEY = 'CommunityExtensions\PLY\Exporter'.freeze

      PLY_ASCII = 'ASCII'.freeze
      PLY_BINARY = 'Binary'.freeze

      OPTIONS = {
        'export_format' => PLY_ASCII,
        'export_units' => 'Model Units'
      }

      def self.file_extension
        'ply'
      end

      def self.model_name
        title = Sketchup.active_model.title
        title = "Untitled-#{Time.now.to_i.to_s(16)}" if title.empty?
        title
      end

      def self.select_export_file
        template  = PLY.translate('%s file location')
        file_name = "#{model_name()}.#{file_extension()}"
        dlg_title = sprintf(template, file_name)
        directory = nil
        path = UI.savepanel(dlg_title, directory, file_name)
      end

      def self.do_options
        path = select_export_file
        return if path.nil?
        export(path)
      end

      def self.export(path, options = OPTIONS)
        file = File.new(path , 'w')  
        model = Sketchup.active_model
        flist = []
        h = {}
        vi = 0
        sel = model.selection
        model.entities.each {|entity|
          next unless entity.class == Sketchup::Face
          tflist = []
          entity.vertices.each { |v|
            if h.has_key?(v)
              tflist << h[v]
            else
              h[v] = vi
              tflist << vi
              vi += 1
            end
          }
          flist << tflist
        }
        h = h.sort_by{|k, v| v}

        file.write("ply\n")
        file.write("format ascii 1.0\n")
        file.write("comment SketchUp PLY Exporter\n")
        file.write("comment Generated: #{Time.now}\n")
        file.write("element vertex #{h.size}\n")
        file.write("property float x\n")
        file.write("property float y\n")
        file.write("property float z\n")
        file.write("element face #{flist.size}\n")
        file.write("property list uint int vertex_indices\n")
        file.write("end_header\n")
        h.each do |vertex, index|
          file.write(vertex.position.to_a.join(" "))
          file.write("\n")
        end
        flist.each do |lst|
          len = lst.length
          file.write("#{len} ")
          file.write(lst.join(' '))
          file.write("\n")
        end
        file.close

      end # d export

      unless file_loaded?(__FILE__)
        UI.menu('File').add_item('Export PLY...', 17) {
          do_options()
        }
        file_loaded(__FILE__)
      end

    end # m Exporter
  end # m PLY
end # m CommunityExtensions
