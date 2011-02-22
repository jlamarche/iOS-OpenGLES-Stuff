# 
# 
# Name: 'Objective-C Header (.h)'
# 
# 

# <pep8 compliant>

# To support reload properly, try to access a package var, if it's there, reload everything
if "bpy" in locals():
    import imp
    if "export_objc" in locals():
        imp.reload(export_objc)


import bpy
from bpy.props import *
from io_utils import ExportHelper

class ExportOBJC(bpy.types.Operator, ExportHelper):
    '''Export to Objectiv C header (.h)'''
    bl_idname = "export_scene.objc"
    bl_label = "Export ObjC"
    bl_options = {'PRESET'}
    
    filename_ext = ".h"
    filter_glob = StringProperty(default="*.h", options={'HIDDEN'})
    
    filepath = bpy.props.StringProperty(name="File Path", description="Filepath used for exporting the header file", maxlen= 1024, default= "")
       
    def execute(self, context):
        keywords = self.as_keywords(ignore=("TX_XROT90", "TX_YROT90", "TX_ZROT90", "TX_SCALE", "check_existing", "filter_glob"))
        import io_scene_objc.export_objc
        return io_scene_objc.export_objc.save(self, context, **keywords)
        
def menu_func_export(self, context):
    self.layout.operator(ExportOBJC.bl_idname, text="ObjectiveC header (.h)")   

def register():
    bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
    bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()

#filename = os.path.splitext(bpy.data.filepath)[0] + ".h"
#context = bpy.context
#write_objc(filename,context)