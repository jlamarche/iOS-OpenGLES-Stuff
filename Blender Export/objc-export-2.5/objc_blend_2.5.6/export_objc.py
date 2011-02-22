# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

# <pep8 compliant>

import os
import time
import shutil

import bpy
import mathutils

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
            for index in face.vertices:
                if len(face.vertices) == 3:
                    vert = mesh.vertices[index]
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
            if len(face.vertices) == 3:
                faceC = color_layer.data[face.index]
                i=0
                for index in face.vertices:
                    vert = mesh.vertices[index]
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
            if len(face.vertices) == 3:
                for index in face.vertices:
                    vert = mesh.vertices[index]
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


def save(operator, context, filepath="",
         use_triangles=False,
         use_edges=True,
         use_normals=False,
         use_hq_normals=False,
         use_uvs=True,
         use_materials=True,
         copy_images=False,
         use_modifiers=True,
         use_rotate_x90=True,
         use_blen_objects=True,
         group_by_object=False,
         group_by_material=False,
         keep_vertex_order=False,
         use_vertex_groups=False,
         use_nurbs=True,
         use_selection=True,
         use_all_scenes=False,
         use_animation=False,
         ):

    write_objc(filepath,context)
    
    return {'FINISHED'}
