module CommunityExtensions
  module PLY
    module Exporter

      PREF_KEY = 'CommunityExtensions\PLY\Exporter'.freeze
      def self.export

      PLY_ASCII = 'ASCII'.freeze
      PLY_BINARY = 'Binary'.freeze

      OPTIONS = {
        'export_format' => PLY_ASCII,
        'export_units' => 'Model Units'
      }

      def self.file_extension
        'ply'
      end

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

        File.open("C:/Users/Jim/tmp/ply-export.ply", 'w') {|f|
          f.write("ply\n")
          f.write("format ascii 1.0\n")
          f.write("element vertex #{h.size}\n")
          f.write("property float x\n")
          f.write("property float y\n")
          f.write("property float z\n")
          f.write("element face #{flist.size}\n")
          f.write("property list uint int vertex_indices\n")
          f.write("end_header\n")
          h.each do |vertex, index|
            f.write(vertex.position.to_a.join(" "))
            f.write("\n")
          end
          flist.each do |lst|
            len = lst.length
            f.write("#{len} ")
            f.write(lst.join(' '))
            f.write("\n")
          end
        }

      end # d export

      unless file_loaded?(__FILE__)
        UI.menu('File').add_item('Export PLY...', 17) {
          export()
        }
        file_loaded(__FILE__)
      end

    end # m Exporter
  end # m PLY
end # m CommunityExtensions
