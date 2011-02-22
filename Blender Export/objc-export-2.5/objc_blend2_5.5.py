# 
# 
# Name: 'Objective-C Header (.h)'
# 
# 

bl_addon_info = {
    'name': 'Export: Objective-C header (.h)',
    'author': 'Jeff, Paul',
    'version': '1.1',
    'blender': (2, 5, 5),
    'location': 'File > Export',
    'description': 'Export Objective C header file (.h)',
    'warning': '', # used for warning icon and text in addons panel
    'wiki_url': '',
    'tracker_url': '',
    'category': 'Import/Export'}

import bpy
import os
import operator

def write_objc(filepath,context):    
    out = open(filepath, 'w')
    current_scene = bpy.context.scene
    objs = current_scene.objects

    #i know there has to be an easier way to do this, but i'm too lazy to look it up
    for next_obj in objs:
        if next_obj.type == 'MESH':
            mesh = next_obj

    print("Writing Object")
        
    for i in current_scene.objects:
        i.select = False #deselect all objects
    mesh.select = True
    current_scene.objects.active = mesh #set the mesh object to current
    bpy.ops.object.mode_set(mode='EDIT') #Operators
    bpy.ops.mesh.select_all(action='SELECT')#select all the face/vertex/edge
    bpy.ops.mesh.quads_convert_to_tris() #Operators
    current_scene.update()
    bpy.ops.object.mode_set(mode='OBJECT') # set it in object
    
    mesh = mesh.data
    
    objectname = mesh.name
    basename = objectname.capitalize()

    out.write('#import "OpenGLCommon.h"\n\n\n')
        
    if len(mesh.uv_textures) > 0:
        out.write('static const TexturedVertexData3D %sVertexData[] = {\n' % basename)
        #for face in uv: #loop through the faces
        uv_layer = mesh.active_uv_texture
        for face in mesh.faces:
            faceUV = uv_layer.data[face.index]
            i=0
            for index in face.verts:
                if len(face.verts) == 3:
                    vert = mesh.verts[index]
                    out.write('\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
                    out.write('/*n:*/{%f, %f, %f}, ' % (vert.normal.x, vert.normal.y, vert.normal.z))
                    out.write('/*t:*/{%f, %f}' % ( faceUV.uv[i][0], faceUV.uv[i][1] ) )
                    out.write('},\n')
                    i+=1
        out.write('};\n\n')
    elif len(mesh.vertex_colors) > 0:
        out.write('static const ColoredVertexData3D %sVertexData[] = {\n' % basename)
        color_layer = mesh.active_vertex_color
        for face in mesh.faces:
            if len(face.verts) == 3:
                faceC = color_layer.data[face.index]
                i=0
                for index in face.verts:
                    vert = mesh.verts[index]
                    out.write('\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
                    out.write('/*n:*/{%f, %f, %f}, ' % (vert.normal.x, vert.normal.y, vert.normal.z))
                    out.write('/*c:*/{%f, %f, %f, %f}' % ( faceC.color1[i], faceC.color2[i], faceC.color3[i], faceC.color4[i]) )
                    out.write('},\n')
                    i+=1
        out.write('};\n\n')
    else:
        out.write
        out.write('static const VertexData3D %sVertexData[] = {\n' % basename)
        for face in mesh.faces:
            if len(face.verts) == 3:
                for index in face.verts:
                    vert = mesh.verts[index]
                    out.write('\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
                    out.write('/*n:*/{%f, %f, %f} ' % (vert.normal.x, vert.normal.y, vert.normal.z))
                    out.write('},\n')
        out.write('};\n\n')
    
    #if editmode: Window.EditMode(1)
    out.write('#define k%sNumberOfVertices\t%i\n' % (basename, len(mesh.faces) * 3) )

    out.write('// Drawing Code:\n')
    out.write('// glEnableClientState(GL_VERTEX_ARRAY);\n')
    if len(mesh.uv_textures) > 0:
        out.write('// glEnableClientState(GL_TEXTURE_COORD_ARRAY);\n')
    elif len(mesh.vertex_colors) > 0:
        out.write('// glEnableClientState(GL_COLOR_ARRAY);\n')
        out.write('// glEnable(GL_COLOR_MATERIAL)\n')
    out.write('// glEnableClientState(GL_NORMAL_ARRAY);\n')
    out.write('// glVertexPointer(3, GL_FLOAT, sizeof(')
    if len(mesh.uv_textures) > 0:
        out.write('TexturedVertexData3D')
    elif len(mesh.vertex_colors) > 0:
        out.write('ColoredVertexData3D')
    else:
        out.write('VertexData3D')
    out.write('), &%sVertexData[0].vertex);\n' % basename)
    out.write('// glNormalPointer(GL_FLOAT, sizeof(')
    if len(mesh.uv_textures) > 0:
        out.write('TexturedVertexData3D')
    elif len(mesh.vertex_colors) > 0:
        out.write('ColoredVertexData3D')
    else:
        out.write('VertexData3D')
    out.write('), &%sVertexData[0].normal);\n' % basename)
    if len(mesh.uv_textures) > 0:
        out.write('// glTexCoordPointer(2, GL_FLOAT, sizeof(TexturedVertexData3D), &%sVertexData[0].texCoord);\n' % basename)
    elif len(mesh.vertex_colors) > 0:
        out.write('// glColorPointer(4, GL_FLOAT, sizeof(ColoredVertexData3D), &%sVertexData[0].color);\n' % basename)
    out.write('// glDrawArrays(GL_TRIANGLES, 0, k%sNumberOfVertices);\n' % basename)
    out.write('// glDisableClientState(GL_VERTEX_ARRAY);\n')
    if len(mesh.uv_textures) > 0:
        out.write('// glDisableClientState(GL_TEXTURE_COORD_ARRAY);\n')
    elif len(mesh.vertex_colors) > 0:
        out.write('// glDisableClientState(GL_NORMAL_ARRAY);\n')
        out.write('// glDisable(GL_COLOR_MATERIAL);\n')
    out.write('// glDisableClientState(GL_NORMAL_ARRAY);\n\n\n')
    
    out.close()

class ObjCExporter(bpy.types.Operator):
    #"""Export to Objectiv C header (.h)"""

    bl_idname = "export.objc"
    bl_label = "Export ObjC"
    
    filepath = StringProperty(subtype='FILE_PATH')
    # filepath = bpy.props.StringProperty(name="File Path", description="Filepath used for exporting the header file", maxlen= 1024, default= "")

    def poll(self, context):
        return context.active_object != None

    def execute(self, context):
        print("Executing")
        print(self.filepath)
        write_objc(self.filepath,context)
        return{'FINISHED'}

    def invoke(self, context, event):
        wm = context.window_manager
        wm.add_fileselect(self)
        return {'RUNNING_MODAL'}

def menu_func(self, context):
    default_path = os.path.splitext(bpy.data.filepath)[0] + ".h"
    self.layout.operator("export.objc", text="ObjectiveC header (.h)").filepath = default_path    

def register():
    bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
    bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
    register()

#filename = os.path.splitext(bpy.data.filepath)[0] + ".h"
#context = bpy.context
#write_objc(filename,context)